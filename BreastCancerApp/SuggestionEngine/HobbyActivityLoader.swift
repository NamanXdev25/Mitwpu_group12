

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
    let ageRange:     [Int]
    let weight:       Int
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

    }

    // MARK: - JSON loader with comment stripping
    private func load<T: Decodable>(resource: String, type: T.Type) -> T? {
        guard let url     = Bundle.main.url(forResource: resource, withExtension: "json"),
              let rawData = try? Data(contentsOf: url),
              let rawText = String(data: rawData, encoding: .utf8) else {
            return nil
        }

        let cleaned = rawText.replacingOccurrences(
            of: #"(?m)\s*//[^\n]*"#,
            with: "",
            options: .regularExpression
        )

        guard let cleanData = cleaned.data(using: .utf8) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(T.self, from: cleanData)
        } catch {
            return nil
        }
    }

    // MARK: - Hobby selection

    func selectActivity(
        category:    String? = nil,
        ctx:         AppContext,
        avoidingIDs: Set<String> = []
    ) -> HobbyActivity? {
        var pool = activities

        if let cat = category {
            pool = pool.filter { normalize($0.category) == normalize(cat) }
        }

        let filtered = pool.filter { !avoidingIDs.contains($0.id) }
        pool = filtered.isEmpty ? pool : filtered

        guard !pool.isEmpty else { return nil }

        let scored = pool.map { ($0, scoreActivity($0, ctx: ctx)) }
            .filter { $0.1 > 0 }

        if scored.isEmpty {
            let genericPool = pool.filter { $0.phaseTags.isEmpty && $0.moodTags.isEmpty }
            let genericScored = genericPool.map { ($0, scoreActivity($0, ctx: ctx)) }
            return weightedRandomActivity(from: genericScored.isEmpty
                ? pool.map { ($0, 10) }
                : genericScored)
        }

        return weightedRandomActivity(from: scored)
    }

    // MARK: - Journal prompt selection

    func selectJournalPrompt(
        ctx:         AppContext,
        avoidingIDs: Set<String> = []
    ) -> JournalPromptItem? {
        let filtered = journalPool.filter { !avoidingIDs.contains($0.id) }
        let pool     = filtered.isEmpty ? journalPool : filtered

        guard !pool.isEmpty else { return nil }

        let scored = pool.map { ($0, scoreJournal($0, ctx: ctx)) }
            .filter { $0.1 > 0 }

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

    private func scoreActivity(_ a: HobbyActivity, ctx: AppContext) -> Int {
        let phase = normalize(ctx.effectiveTreatmentType)
        let mood  = normalize(ctx.moodKey)
        let age   = ctx.age

        let phaseIsKnown = phase != "general"
            || ctx.isPostTreatment
            || ctx.isEarlyDiagnosis
            || ctx.isInActiveTreatment

        let effectivePhaseKey: String
        if ctx.isPostTreatment       { effectivePhaseKey = "posttreatment" }
        else if ctx.isEarlyDiagnosis { effectivePhaseKey = "earlydiagnosis" }
        else                         { effectivePhaseKey = phase }

        if !a.phaseTags.isEmpty {
            guard phaseIsKnown else { return 0 }
            let normalisedPhaseTags = a.phaseTags.map { normalize($0) }
            guard normalisedPhaseTags.contains(effectivePhaseKey) else { return 0 }
        }

        let moodIsSelected = mood != "general"
        if moodIsSelected && !a.moodTags.isEmpty {
            let normalisedMoodTags = a.moodTags.map { normalize($0) }
            guard normalisedMoodTags.contains(mood) else { return 0 }
        }

        var w = 10 * max(1, a.weight)

        if !a.phaseTags.isEmpty {
            w += 30
        }

        if moodIsSelected && !a.moodTags.isEmpty {
            w += 20
        }

        for tag in a.symptomTags {
            if phaseTypicallyProducesSymptom(normalize(tag), for: ctx) {
                w += 25
            }
        }

        if a.ageRange.count == 2 {
            if age >= a.ageRange[0] && age <= a.ageRange[1] {
                w += 15
            } else {
                w -= 10
            }
        }

        let onboardingCategories = ctx.hobbies.map { normalize($0) }
        if onboardingCategories.contains(normalize(a.category)) {
            w += 20
        }

        w += UserActivityStore.shared.hobbyWeight(for: a.title) * 4

        return max(1, w)
    }

    // MARK: - Phase → typical symptom inference
    private func phaseTypicallyProducesSymptom(_ symptom: String, for ctx: AppContext) -> Bool {
        let s = symptom
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

    private func scoreJournal(_ p: JournalPromptItem, ctx: AppContext) -> Int {
        let phase = normalize(ctx.effectiveTreatmentType)
        let mood  = normalize(ctx.moodKey)
        let age   = ctx.age

        let phaseIsKnown = phase != "general"
            || ctx.isPostTreatment
            || ctx.isEarlyDiagnosis
            || ctx.isInActiveTreatment

        let effectivePhaseKey: String
        if ctx.isPostTreatment       { effectivePhaseKey = "posttreatment" }
        else if ctx.isEarlyDiagnosis { effectivePhaseKey = "earlydiagnosis" }
        else                         { effectivePhaseKey = phase }

        if !p.phaseTags.isEmpty {
            guard phaseIsKnown else { return 0 }
            let normTags = p.phaseTags.map { normalize($0) }
            guard normTags.contains(effectivePhaseKey) else { return 0 }
        }

        let conditionSpecificSymptoms: Set<String> = [
            "lymphedema", "hot flashes", "hot flush",
            "hair loss", "hair", "nausea", "brain fog", "fog", "insomnia", "sleep"
        ]
        for tag in p.symptomTags {
            let t = normalize(tag)
            if conditionSpecificSymptoms.contains(t) {
                guard phaseIsKnown && phaseTypicallyProducesSymptom(t, for: ctx) else { return 0 }
            }
        }

        let moodIsSelected = mood != "general"
        if moodIsSelected && !p.moodTags.isEmpty {
            let normMoodTags = p.moodTags.map { normalize($0) }
            guard normMoodTags.contains(mood) else { return 0 }
        }

        var w = 10

        if !p.phaseTags.isEmpty { w += 30 }

        if moodIsSelected && !p.moodTags.isEmpty { w += 20 }

        for tag in p.symptomTags {
            if phaseTypicallyProducesSymptom(normalize(tag), for: ctx) {
                w += 25
            }
        }

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
