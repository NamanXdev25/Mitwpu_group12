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
//                → +30 if current phase matches, –10 if set but doesn't match
//                → empty array means generic (valid for all phases, no boost)
//
//    moodTags    e.g. ["tired", "sad"]
//                → +20 if current mood matches, –5 if set but doesn't match
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
        return weightedRandomJournal(from: scored)
    }

    // MARK: - Activity scoring
    //
    // This is where every tag on every activity gets evaluated against
    // the live AppContext. The result is a score that reflects how well
    // this specific activity matches THIS user's phase, mood, symptoms, age.

    private func scoreActivity(_ a: HobbyActivity, ctx: AppContext) -> Int {
        var w = 10 * max(1, a.weight)

        let phase = normalize(ctx.effectiveTreatmentType)
        let mood  = normalize(ctx.moodKey)
        let age   = ctx.age

        // ── Phase tags ──────────────────────────────────────────────────────
        let effectivePhaseKey: String
        if ctx.isPostTreatment       { effectivePhaseKey = "posttreatment" }
        else if ctx.isEarlyDiagnosis { effectivePhaseKey = "earlydiagnosis" }
        else                         { effectivePhaseKey = phase }

        if !a.phaseTags.isEmpty {
            let normalisedPhaseTags = a.phaseTags.map { normalize($0) }
            if normalisedPhaseTags.contains(effectivePhaseKey) {
                w += 30   // ✅ written for the user's current phase
            } else {
                w -= 10   // ❌ phase-specific but wrong phase — deprioritise
            }
        }
        // Generic activities (empty phaseTags) get neither boost nor penalty.

        // ── Mood tags ───────────────────────────────────────────────────────
        if !a.moodTags.isEmpty {
            let normalisedMoodTags = a.moodTags.map { normalize($0) }
            if normalisedMoodTags.contains(mood) {
                w += 20   // ✅ matches current mood
            } else {
                w -= 5    // ❌ mood-specific but wrong mood
            }
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

    // MARK: - Journal scoring (same tag logic)

    private func scoreJournal(_ p: JournalPromptItem, ctx: AppContext) -> Int {
        var w = 10

        let phase = normalize(ctx.effectiveTreatmentType)
        let mood  = normalize(ctx.moodKey)
        let age   = ctx.age

        let effectivePhaseKey: String
        if ctx.isPostTreatment       { effectivePhaseKey = "posttreatment" }
        else if ctx.isEarlyDiagnosis { effectivePhaseKey = "earlydiagnosis" }
        else                         { effectivePhaseKey = phase }

        // Phase
        if !p.phaseTags.isEmpty {
            let normTags = p.phaseTags.map { normalize($0) }
            if normTags.contains(effectivePhaseKey) { w += 30 } else { w -= 8 }
        }

        // Mood
        if !p.moodTags.isEmpty {
            let normTags = p.moodTags.map { normalize($0) }
            if normTags.contains(mood) { w += 20 } else { w -= 5 }
        }

        // Symptom tags — phase-inferred (same logic as activity scoring)
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
