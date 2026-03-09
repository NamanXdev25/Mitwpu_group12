//
//  HobbyActivityLoader.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/03/26.
//

//  Loads HobbyActivities.json and JournalPrompts.json.
//  Scores every activity/prompt against AppContext using their tags, then
//  returns the best one via weighted random selection.
//
//  HOW TAGS DRIVE WHAT GETS SHOWN:
//
//  Every activity in HobbyActivities.json has:
//    phaseTags   e.g. ["chemotherapy", "stemcell"]
//                → HARD GATE: if non-empty, must match user's phase or score = 0
//                → empty array means generic (valid for all phases, no boost)
//
//    moodTags    e.g. ["tired", "sad"]
//                → HARD GATE: if non-empty, must contain user's mood or score = 0
//                → empty array means mood-agnostic
//
//    symptomTags e.g. ["nausea", "fatigue"]
//                → +25 per symptom that matches user's active symptoms
//                → match is substring-based ("nausea" matches "Nausea & Vomiting")
//
//    ageRange    e.g. [18, 55]
//                → +15 if user's age falls within range, –10 if outside
//
//  Combined with onboarding hobby match (+20) and tap history (+4–12),
//  a chemo patient, age 42, mood tired, with nausea symptom, who likes reading,
//  will almost always see:
//    "Read just 1–2 pages — something light" (reading_003)
//    or "Listen and do nothing else — just listen" (music_listen_001)
//  rather than "Try a splatter painting" (painting_013, tagged [18,45], postTreatment)
//
//  HARD GATE SUMMARY (items MUST pass all gates or they are excluded):
//    Gate 1 — Phase: if phaseTags non-empty, user's phase must match
//    Gate 2 — Mood:  if moodTags non-empty, user's mood must match
//                     (mood "general" = no mood selected → mood-tagged items still allowed)
//    Gate 3 — Symptom (journals only): condition-specific symptoms require confirmed phase

import Foundation

// MARK: - Models

struct HobbyActivity: Codable {
    let id:           String
    let category:     String
    let title:        String
    let subtitle:     String
    let image:        String
    let moodTags:     [String]
    let phaseTags:    [String]
    let symptomTags:  [String]
    let ageRange:     [Int]       // [minAge, maxAge] inclusive
    let weight:       Int         // base multiplier (1 = normal, 2 = strongly preferred)
}

struct JournalPromptItem: Codable {
    let id:           String
    let title:        String
    let moodTags:     [String]
    let phaseTags:    [String]
    let symptomTags:  [String]
    let ageRange:     [Int]
}

private struct HobbyActivityRoot: Codable  { let activities: [HobbyActivity]     }
private struct JournalPromptRoot: Codable  { let prompts:    [JournalPromptItem]  }

// MARK: - Loader

final class HobbyActivityLoader {

    static let shared = HobbyActivityLoader()

    private(set) var activities:   [HobbyActivity]      = []
    private(set) var journalPool:  [JournalPromptItem]   = []

    private init() {
        activities  = load(resource: "HobbyActivities", type: HobbyActivityRoot.self)?.activities ?? []
        journalPool = load(resource: "JournalPrompts",  type: JournalPromptRoot.self)?.prompts    ?? []

        if activities.isEmpty  { print("⚠️ HobbyActivityLoader: HobbyActivities.json missing or invalid") }
        if journalPool.isEmpty { print("⚠️ HobbyActivityLoader: JournalPrompts.json missing or invalid") }
    }

    // MARK: - JSON loader with comment stripping
    //
    // Both HobbyActivities.json and JournalPrompts.json contain // comments
    // for readability. Standard JSONDecoder rejects comments, so we strip
    // all single-line // comments before decoding — same approach used by
    // HomeMoodSuggestionLoader.
    private func load<T: Decodable>(resource: String, type: T.Type) -> T? {
        guard let url     = Bundle.main.url(forResource: resource, withExtension: "json"),
              let rawData = try? Data(contentsOf: url),
              let rawText = String(data: rawData, encoding: .utf8) else {
            print("⚠️ HobbyActivityLoader: could not find \(resource).json in bundle")
            return nil
        }

        // Strip single-line // comments (handles inline and full-line comments)
        let cleaned = rawText.replacingOccurrences(
            of: #"(?m)\s*//[^\n]*"#,
            with: "",
            options: .regularExpression
        )

        guard let cleanData = cleaned.data(using: .utf8) else {
            print("⚠️ HobbyActivityLoader: re-encoding failed for \(resource).json")
            return nil
        }

        do {
            return try JSONDecoder().decode(T.self, from: cleanData)
        } catch {
            print("⚠️ HobbyActivityLoader: decode error in \(resource).json —", error)
            return nil
        }
    }

    // MARK: - Hobby selection

    /// Returns the highest-scoring HobbyActivity for the given AppContext.
    /// - `category`: optional filter (e.g. "drawing"). nil = all categories.
    /// - `avoidingIDs`: IDs of activities shown recently (prevent repetition).
    func selectActivity(
        category:    String? = nil,
        ctx:         AppContext,
        avoidingIDs: Set<String> = []
    ) -> HobbyActivity? {
        var pool = activities

        if let cat = category {
            pool = pool.filter { normalize($0.category) == normalize(cat) }
        }

        // Remove recently shown, but fall back to full pool if everything was shown
        let filtered = pool.filter { !avoidingIDs.contains($0.id) }
        pool = filtered.isEmpty ? pool : filtered

        guard !pool.isEmpty else { return nil }

        let scored = pool.map { ($0, scoreActivity($0, ctx: ctx)) }
            .filter { $0.1 > 0 }  // Drop items that failed hard gates (score = 0)

        // If all items were gated out, fall back to generic items only
        if scored.isEmpty {
            let genericPool = pool.filter { $0.phaseTags.isEmpty && $0.moodTags.isEmpty }
            let genericScored = genericPool.map { ($0, scoreActivity($0, ctx: ctx)) }
            return weightedRandomActivity(from: genericScored.isEmpty
                ? pool.map { ($0, 10) }  // absolute fallback
                : genericScored)
        }

        return weightedRandomActivity(from: scored)
    }

    // MARK: - Journal prompt selection

    /// Returns the highest-scoring JournalPromptItem for the given AppContext.
    /// - `avoidingIDs`: IDs of prompts shown recently (prevent repetition).
    func selectJournalPrompt(
        ctx:         AppContext,
        avoidingIDs: Set<String> = []
    ) -> JournalPromptItem? {
        let filtered = journalPool.filter { !avoidingIDs.contains($0.id) }
        let pool     = filtered.isEmpty ? journalPool : filtered

        guard !pool.isEmpty else { return nil }

        let scored = pool.map { ($0, scoreJournal($0, ctx: ctx)) }
            .filter { $0.1 > 0 }  // Drop items that failed hard gates (score = 0)

        // If all items were gated out, fall back to generic prompts
        if scored.isEmpty {
            let genericPool = pool.filter { $0.phaseTags.isEmpty && $0.moodTags.isEmpty && $0.symptomTags.isEmpty }
            let genericScored = genericPool.map { ($0, 10) }
            return weightedRandomJournal(from: genericScored.isEmpty
                ? pool.filter { $0.phaseTags.isEmpty && $0.symptomTags.isEmpty }.map { ($0, 10) }
                : genericScored)
        }

        return weightedRandomJournal(from: scored)
    }

    // MARK: - Activity scoring
    //
    // This is where every tag on every activity gets evaluated against
    // the live AppContext. The result is a score that reflects how well
    // this specific activity matches THIS user's phase, mood, symptoms, age.
    //
    // HARD GATES (return 0 = excluded):
    //   Gate 1: Phase — if phaseTags non-empty, user's phase must match
    //   Gate 2: Mood  — if moodTags non-empty, user's mood must match
    //                    (skipped when mood is "general" i.e. no mood selected)

    private func scoreActivity(_ a: HobbyActivity, ctx: AppContext) -> Int {
        let phase = normalize(ctx.effectiveTreatmentType)
        let mood  = normalize(ctx.moodKey)
        let age   = ctx.age

        // ── Resolve the user's confirmed phase key ───────────────────────────
        let phaseIsKnown = phase != "general"
            || ctx.isPostTreatment
            || ctx.isEarlyDiagnosis
            || ctx.isInActiveTreatment

        let effectivePhaseKey: String
        if ctx.isPostTreatment       { effectivePhaseKey = "posttreatment" }
        else if ctx.isEarlyDiagnosis { effectivePhaseKey = "earlydiagnosis" }
        else                         { effectivePhaseKey = phase }

        // ── HARD GATE 1: Phase ──────────────────────────────────────────────
        // Activities with phaseTags set are designed for a specific clinical
        // context. If we don't know the user's phase, or the phase doesn't
        // match, exclude the activity entirely.
        if !a.phaseTags.isEmpty {
            guard phaseIsKnown else { return 0 }  // phase unknown → exclude
            let normalisedPhaseTags = a.phaseTags.map { normalize($0) }
            guard normalisedPhaseTags.contains(effectivePhaseKey) else { return 0 }  // wrong phase → exclude
        }

        // ── HARD GATE 2: Mood ───────────────────────────────────────────────
        // Activities with moodTags set are designed for specific emotional
        // states. If the user selected a mood that doesn't match, exclude.
        // When mood is "general" (no mood selected yet), skip this gate —
        // mood-tagged items are still allowed in the default/pre-mood pool.
        let moodIsSelected = mood != "general"
        if moodIsSelected && !a.moodTags.isEmpty {
            let normalisedMoodTags = a.moodTags.map { normalize($0) }
            guard normalisedMoodTags.contains(mood) else { return 0 }  // wrong mood → exclude
        }

        // ── Scoring (only reached if hard gates passed) ──────────────────────
        var w = 10 * max(1, a.weight)

        // Phase match boost (already confirmed matching at this point)
        if !a.phaseTags.isEmpty {
            w += 30   // ✅ written for the user's current phase
        }

        // Mood match boost (already confirmed matching at this point)
        if moodIsSelected && !a.moodTags.isEmpty {
            w += 20   // ✅ matches current mood
        }

        // ── Symptom tags — phase-inferred, NOT user-entered ─────────────────
        // We don't ask users for symptoms. Instead, symptomTags on activities
        // represent symptoms typical for their phaseTags. We boost the activity
        // if that symptom is medically expected in the user's current phase.
        // e.g. "nausea" is typical for chemo → chemo patient gets +25 for
        // any activity tagged ["nausea"], without asking them if they have it.
        for tag in a.symptomTags {
            if phaseTypicallyProducesSymptom(normalize(tag), for: ctx) {
                w += 25   // +25 per phase-relevant symptom tag — can stack
            }
        }

        // ── Age range ───────────────────────────────────────────────────────
        if a.ageRange.count == 2 {
            if age >= a.ageRange[0] && age <= a.ageRange[1] {
                w += 15   // ✅ within intended age range
            } else {
                w -= 10   // ❌ outside age range
            }
        }

        // ── Onboarding hobby category match ─────────────────────────────────
        let onboardingCategories = ctx.hobbies.map { normalize($0) }
        if onboardingCategories.contains(normalize(a.category)) {
            w += 20
        }

        // ── Tap history engagement ───────────────────────────────────────────
        w += UserActivityStore.shared.hobbyWeight(for: a.title) * 4

        return max(1, w)
    }

    // MARK: - Phase → typical symptom inference
    // Returns true if a symptom is commonly experienced in the user's current phase.
    // Medical knowledge baked in — no user input required.
    private func phaseTypicallyProducesSymptom(_ symptom: String, for ctx: AppContext) -> Bool {
        let s = symptom // already normalised by caller
        switch normalize(ctx.effectiveTreatmentType) {
        case "chemotherapy":
            return ["nausea", "fatigue", "tiredness", "hair loss", "hair",
                    "brain fog", "fog", "pain", "anxiety", "fear"].contains(s)
        case "surgery":
            return ["pain", "fatigue", "tiredness", "anxiety",
                    "fear", "insomnia", "sleep"].contains(s)
        case "radiation":
            return ["fatigue", "tiredness", "pain",
                    "anxiety", "insomnia", "sleep"].contains(s)
        case "hormone":
            return ["hot flashes", "hot flush", "joint pain", "pain",
                    "insomnia", "sleep", "anxiety", "mood"].contains(s)
        case "immunotherapy", "targeted":
            return ["fatigue", "tiredness", "nausea", "pain", "anxiety"].contains(s)
        case "stemcell":
            return ["fatigue", "tiredness", "pain", "nausea", "anxiety",
                    "insomnia", "sleep", "brain fog", "fog"].contains(s)
        default:
            if ctx.isPostTreatment  { return ["anxiety", "fear", "fatigue", "tiredness"].contains(s) }
            if ctx.isEarlyDiagnosis { return ["anxiety", "fear", "insomnia", "sleep"].contains(s) }
            return false
        }
    }

    // MARK: - Journal scoring
    //
    // SAFETY RULE: Journal prompts that reference a specific treatment phase
    // (e.g. "during chemo", "since surgery", "survivorship") or a specific
    // symptom (e.g. lymphedema, hot flashes, nausea, hair loss) or a specific
    // mood (e.g. "sad", "anxious") must ONLY be shown when the user's context
    // actually confirms that phase, symptom, or mood.
    //
    // HARD GATES (return 0 = excluded):
    //   Gate 1 — Phase:   if phaseTags non-empty, user's phase must match
    //   Gate 2 — Symptom: condition-specific symptoms require confirmed phase context
    //   Gate 3 — Mood:    if moodTags non-empty, user's mood must match
    //                      (skipped when mood is "general" i.e. no mood selected)

    private func scoreJournal(_ p: JournalPromptItem, ctx: AppContext) -> Int {
        let phase = normalize(ctx.effectiveTreatmentType)
        let mood  = normalize(ctx.moodKey)
        let age   = ctx.age

        // ── Resolve the user's confirmed phase key ───────────────────────────
        // "general" means no journey data — we treat it as unknown.
        let phaseIsKnown = phase != "general"
            || ctx.isPostTreatment
            || ctx.isEarlyDiagnosis
            || ctx.isInActiveTreatment

        let effectivePhaseKey: String
        if ctx.isPostTreatment       { effectivePhaseKey = "posttreatment" }
        else if ctx.isEarlyDiagnosis { effectivePhaseKey = "earlydiagnosis" }
        else                         { effectivePhaseKey = phase }

        // ── HARD GATE 1: Phase-specific prompts require a known, matching phase ──
        // Prompts with phaseTags set (e.g. ["chemotherapy"]) are written for
        // a specific clinical context. If we don't know the user's phase, or
        // the phase doesn't match, we must not show them.
        if !p.phaseTags.isEmpty {
            guard phaseIsKnown else { return 0 }      // phase unknown → exclude
            let normTags = p.phaseTags.map { normalize($0) }
            guard normTags.contains(effectivePhaseKey) else { return 0 } // wrong phase → exclude
        }

        // ── HARD GATE 2: Symptom-specific prompts require confirmed symptom context ──
        // Some prompts are written for specific symptoms (lymphedema, hot flashes,
        // hair loss, nausea, brain fog, insomnia) that are NOT universal.
        // We only show these if the user's known phase typically produces that symptom.
        // If phase is unknown, none of these can be confirmed → exclude.
        let conditionSpecificSymptoms: Set<String> = [
            "lymphedema", "hot flashes", "hot flush",
            "hair loss", "hair", "nausea", "brain fog", "fog", "insomnia", "sleep"
        ]
        for tag in p.symptomTags {
            let t = normalize(tag)
            if conditionSpecificSymptoms.contains(t) {
                // This prompt is written for a specific symptom.
                // Only show it if the user's phase plausibly produces this symptom.
                guard phaseIsKnown && phaseTypicallyProducesSymptom(t, for: ctx) else { return 0 }
            }
        }

        // ── HARD GATE 3: Mood-specific prompts require matching mood ─────────
        // Prompts with moodTags set are designed for specific emotional states.
        // If the user selected a mood that doesn't match, exclude the prompt.
        // When mood is "general" (no mood selected), skip this gate.
        let moodIsSelected = mood != "general"
        if moodIsSelected && !p.moodTags.isEmpty {
            let normMoodTags = p.moodTags.map { normalize($0) }
            guard normMoodTags.contains(mood) else { return 0 }  // wrong mood → exclude
        }

        // ── Scoring (only reached if ALL hard gates passed) ──────────────────
        var w = 10

        // Phase match boost (prompt already confirmed to match phase at this point)
        if !p.phaseTags.isEmpty { w += 30 }

        // Mood match boost (prompt already confirmed to match mood at this point)
        if moodIsSelected && !p.moodTags.isEmpty { w += 20 }

        // Symptom tags — boost if phase-typical (already confirmed safe above)
        for tag in p.symptomTags {
            if phaseTypicallyProducesSymptom(normalize(tag), for: ctx) {
                w += 25
            }
        }

        // Age
        if p.ageRange.count == 2 {
            if age >= p.ageRange[0] && age <= p.ageRange[1] { w += 10 } else { w -= 8 }
        }

        return max(1, w)
    }

    // MARK: - Weighted random helpers

    private func weightedRandomActivity(from scored: [(HobbyActivity, Int)]) -> HobbyActivity? {
        let total = scored.reduce(0) { $0 + $1.1 }
        guard total > 0 else { return scored.randomElement()?.0 }
        var r = Int.random(in: 0..<total)
        for (item, weight) in scored {
            r -= weight
            if r < 0 { return item }
        }
        return scored.last?.0
    }

    private func weightedRandomJournal(from scored: [(JournalPromptItem, Int)]) -> JournalPromptItem? {
        let total = scored.reduce(0) { $0 + $1.1 }
        guard total > 0 else { return scored.randomElement()?.0 }
        var r = Int.random(in: 0..<total)
        for (item, weight) in scored {
            r -= weight
            if r < 0 { return item }
        }
        return scored.last?.0
    }

    // MARK: - Helpers

    private func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var allCategories: [String] {
        Array(Set(activities.map { $0.category })).sorted()
    }
}
