//
//  HomeSuggestionEngine.swift
//  BreastCancerApp
//

// Picks breathing + hobby suggestions using a weighted algorithm.
//
// WEIGHT BANDS — breathing:
//   Phase × Mood combo   : +36–50  (highest — most personalised breathing signal)
//   Phase match          : +15–32  (journey phase)
//   Mood match           : +10–20  (current feeling)
//   Tap history          : ×4
//   Base                 : 10
//
// WEIGHT BANDS — hobby (tag-driven via HobbyActivityLoader):
//   Phase tag match      : +30     (activity.phaseTags contains current phase)
//   Mood tag match       : +20     (activity.moodTags contains current mood)
//   Symptom tag match    : +25 ×n  (phase-typical symptoms baked into activity tags)
//   Age range match      : +15
//   Onboarding category  : +20
//   Tap history          : ×4
//   Wrong phase penalty  : –10
//   Wrong mood penalty   : –5
//   Outside age range    : –10
//   Base                 : 10
//
// NOTE: We do NOT ask users for symptoms during treatment.
// Symptom awareness for hobbies/journal comes from the phaseTags + symptomTags
// baked into hobbyActivities.json and journalPrompts.json — e.g. all activities
// tagged ["chemotherapy"] were written for patients experiencing nausea/fatigue.
// Breathing suggestions are scored by phase + mood only (no symptom input).

import Foundation

struct HomeSuggestionEngine {

    // MARK: - Default suggestions (before mood selected)

    static func defaultSuggestions(
        avoiding recentBreathing: Set<String>,
        avoiding recentHobbyIDs:  Set<String>
    ) -> [Suggestion] {
        let ctx = AppContext.current(moodKey: "general")
        var result: [Suggestion] = []
        if let b = pickDefaultBreathing(ctx: ctx, avoiding: recentBreathing) { result.append(b) }
        if let h = pickDefaultHobby(ctx: ctx, avoidingIDs: recentHobbyIDs)   { result.append(h) }
        return result.isEmpty ? fallback() : result
    }

    // MARK: - Mood-based suggestions (after mood selected)

    static func moodSuggestions(
        for moodKey: String,
        avoiding recentBreathing: Set<String>,
        avoiding recentHobbyIDs:  Set<String>
    ) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return defaultSuggestions(avoiding: recentBreathing, avoiding: recentHobbyIDs)
        }

        let ctx = AppContext.current(moodKey: moodKey)
        var result: [Suggestion] = []

        // ── Breathing ──────────────────────────────────────────────────────
        // Scored by phase + mood only. No symptom input from user.
        let breathingCandidates = buildBreathingCandidates(from: content.breathing, moodKey: moodKey, ctx: ctx)
        let breathingFiltered   = breathingCandidates.filter { !recentBreathing.contains($0.title.lowercased()) }
        let breathingPool       = breathingFiltered.isEmpty ? breathingCandidates : breathingFiltered

        if let picked = weightedRandom(from: breathingPool),
           let item   = content.breathing.first(where: { normalize($0.title) == normalize(picked.title) }) {
            let subtitle = breathingSubtitleOverride(title: item.title, moodKey: moodKey, ctx: ctx)
                        ?? item.description
                        ?? "A calming breathing session."
            result.append(Suggestion(
                imageName: breathingImageName(for: item.title),
                title:     item.title,
                subtitle:  subtitle
            ))
        }

        // ── Hobby ──────────────────────────────────────────────────────────
        // Tag-driven via HobbyActivityLoader. Activities have phaseTags,
        // moodTags, symptomTags (typical for that phase), ageRange.
        // The loader reads all tags and scores against current AppContext.
        if let activity = HobbyActivityLoader.shared.selectActivity(
            ctx:         ctx,
            avoidingIDs: recentHobbyIDs
        ) {
            result.append(Suggestion(
                imageName: activity.image,
                title:     activity.title,
                subtitle:  activity.subtitle
            ))
        }

        return result.isEmpty ? fallback() : result
    }

    // MARK: - Journal prompt

    /// Returns the best journal prompt for the current context.
    /// Replaces HomeModel.randomJournalSuggestion — call this instead.
    static func journalPrompt(
        for moodKey: String,
        avoidingIDs: Set<String> = []
    ) -> JournalPromptItem? {
        let ctx = AppContext.current(moodKey: moodKey)
        return HobbyActivityLoader.shared.selectJournalPrompt(ctx: ctx, avoidingIDs: avoidingIDs)
    }

    // MARK: - Breathing candidate scoring

    private static func buildBreathingCandidates(
        from items: [HomeMoodSuggestionItem],
        moodKey: String,
        ctx: AppContext
    ) -> [WeightedItem] {
        items.map { item in
            var w = 10
            w += breathingPhaseScore(title: item.title, ctx: ctx)
            w += breathingMoodScore(title: item.title, moodKey: moodKey)
            w += breathingMoodPhaseComboScore(title: item.title, moodKey: moodKey, ctx: ctx)
            w += UserActivityStore.shared.breathingWeight(for: item.title) * 4
            return WeightedItem(title: item.title, weight: max(1, w), tags: [])
        }
    }

    // Phase → preferred breathing (weight 15–32)
    private static func breathingPhaseScore(title: String, ctx: AppContext) -> Int {
        let t = normalize(title)
        switch ctx.effectiveTreatmentType {

        case "chemotherapy":
            // Chemo patients typically have nausea + fatigue — nausea relief
            // and gentle recharge are clinically the most helpful breathing types.
            // We don't ask for symptoms but we know what chemo patients feel.
            switch t {
            case "gentle recharge":      return 32
            case "deep rest":            return 28
            case "inner calm":           return 22
            case "gentle focus":         return 18
            case "healing reflections":  return 15
            default:                     return 0
            }

        case "surgery":
            switch t {
            case "healing reflections":  return 32
            case "gentle recharge":      return 26
            case "deep rest":            return 22
            case "inner calm":           return 18
            default:                     return 0
            }

        case "radiation":
            switch t {
            case "inner calm":           return 32
            case "calmer mind":          return 26
            case "gentle recharge":      return 20
            case "healing reflections":  return 16
            default:                     return 0
            }

        case "hormone":
            switch t {
            case "calmer mind":          return 30
            case "inner calm":           return 24
            case "morning appreciation": return 20
            case "gentle focus":         return 16
            default:                     return 0
            }

        case "immunotherapy", "targeted":
            switch t {
            case "gentle recharge":      return 28
            case "inner calm":           return 24
            case "calmer mind":          return 20
            default:                     return 0
            }

        case "stemcell":
            switch t {
            case "deep rest":            return 32
            case "gentle recharge":      return 28
            case "healing reflections":  return 22
            case "inner calm":           return 18
            default:                     return 0
            }

        case "earlyDiagnosis":
            switch t {
            case "gentle focus":         return 28
            case "calmer mind":          return 24
            case "healing reflections":  return 18
            case "inner calm":           return 15
            default:                     return 0
            }

        default:
            if ctx.isPostTreatment {
                switch t {
                case "healing reflections":  return 26
                case "morning appreciation": return 22
                case "gentle focus":         return 18
                default:                     return 0
                }
            }
            if ctx.isEarlyDiagnosis {
                switch t {
                case "gentle focus":         return 26
                case "inner calm":           return 20
                case "calmer mind":          return 16
                default:                     return 0
                }
            }
            return 0
        }
    }

    // Mood → preferred breathing (weight 10–20)
    private static func breathingMoodScore(title: String, moodKey: String) -> Int {
        let t = normalize(title)
        switch moodKey.lowercased() {
        case "anxious":
            switch t {
            case "calmer mind":          return 20
            case "gentle focus":         return 16
            case "inner calm":           return 14
            default:                     return 0
            }
        case "tired":
            switch t {
            case "gentle recharge":      return 20
            case "deep rest":            return 18
            case "inner calm":           return 12
            default:                     return 0
            }
        case "sad":
            switch t {
            case "healing reflections":  return 20
            case "deep rest":            return 16
            case "gentle focus":         return 14
            case "inner calm":           return 10
            default:                     return 0
            }
        case "happy":
            switch t {
            case "morning appreciation": return 20
            case "gentle focus":         return 16
            case "inner calm":           return 12
            default:                     return 0
            }
        case "excited":
            switch t {
            case "gentle focus":         return 20
            case "morning appreciation": return 16
            case "calmer mind":          return 12
            case "inner calm":           return 10
            default:                     return 0
            }
        default: return 0
        }
    }

    // Mood × Phase combos for breathing (weight 36–50, highest band)
    private static func breathingMoodPhaseComboScore(title: String, moodKey: String, ctx: AppContext) -> Int {
        let t = normalize(title)
        let m = moodKey.lowercased()

        if m == "anxious" && ctx.isInActiveTreatment {
            if t == "calmer mind"          { return 50 }
            if t == "inner calm"           { return 40 }
        }
        if m == "tired" && ctx.effectiveTreatmentType == "chemotherapy" {
            if t == "deep rest"            { return 50 }
            if t == "gentle recharge"      { return 44 }
        }
        if m == "tired" && ctx.effectiveTreatmentType == "stemcell" {
            if t == "deep rest"            { return 50 }
            if t == "gentle recharge"      { return 44 }
        }
        if m == "tired" && ctx.isInActiveTreatment {
            if t == "deep rest"            { return 36 }
            if t == "gentle recharge"      { return 30 }
        }
        if m == "sad" && ctx.isInActiveTreatment {
            if t == "healing reflections"  { return 44 }
            if t == "gentle focus"         { return 36 }
        }
        if m == "sad" && ctx.isPostTreatment {
            if t == "healing reflections"  { return 44 }
            if t == "morning appreciation" { return 36 }
        }
        if m == "happy" && ctx.isPostTreatment {
            if t == "morning appreciation" { return 44 }
            if t == "healing reflections"  { return 36 }
        }
        if m == "excited" && ctx.isPostTreatment {
            if t == "morning appreciation" { return 44 }
            if t == "gentle focus"         { return 36 }
        }
        if m == "anxious" && ctx.isEarlyDiagnosis {
            if t == "calmer mind"          { return 44 }
            if t == "gentle focus"         { return 36 }
        }
        if m == "happy" && ctx.isEarlyDiagnosis {
            if t == "morning appreciation" { return 36 }
            if t == "gentle focus"         { return 28 }
        }
        return 0
    }

    // MARK: - Breathing subtitle overrides

    private static func breathingSubtitleOverride(title: String, moodKey: String, ctx: AppContext) -> String? {
        let t     = normalize(title)
        let m     = moodKey.lowercased()
        let phase = ctx.effectiveTreatmentType

        // Mood × Phase combos (highest specificity)
        if m == "anxious" && ctx.isInActiveTreatment && t == "calmer mind" {
            return "Slow your exhale to quiet the fear around treatment."
        }
        if m == "tired" && phase == "chemotherapy" && t == "gentle recharge" {
            return "A gentle reset when chemo leaves your body drained."
        }
        if m == "tired" && phase == "chemotherapy" && t == "deep rest" {
            return "A soft session to let your body fully rest after chemo."
        }
        if m == "tired" && phase == "stemcell" && t == "deep rest" {
            return "A gentle session for deep rest during your recovery."
        }
        if m == "sad" && ctx.isInActiveTreatment && t == "healing reflections" {
            return "A soft rhythm to hold you through the hard days of treatment."
        }
        if m == "happy" && ctx.isPostTreatment && t == "morning appreciation" {
            return "Breathe in the progress you have made. You earned this."
        }
        if m == "excited" && ctx.isPostTreatment && t == "morning appreciation" {
            return "Channel your excitement into gratitude for how far you have come."
        }
        if m == "anxious" && ctx.isEarlyDiagnosis && t == "calmer mind" {
            return "Steady breaths to help you take things one day at a time."
        }

        // Phase-only overrides
        switch phase {
        case "chemotherapy":
            if t == "gentle recharge"      { return "A mild reset when chemo leaves your body drained." }
            if t == "deep rest"            { return "Let your body rest deeply between treatment sessions." }
            if t == "inner calm"           { return "A soft session to quieten everything chemo stirs up." }
        case "surgery":
            if t == "healing reflections"  { return "A soft session to support your body as it heals from surgery." }
            if t == "gentle recharge"      { return "Light breathing to replenish energy during post-surgery rest." }
        case "radiation":
            if t == "inner calm"           { return "Calming breath to ease the tension that radiation can build up." }
            if t == "calmer mind"          { return "Steady breaths to keep your mind quiet between sessions." }
        case "hormone":
            if t == "calmer mind"          { return "Steady breaths to balance the emotional shifts from hormone therapy." }
        case "immunotherapy", "targeted":
            if t == "gentle recharge"      { return "A mild reset for the fatigue that comes with this treatment." }
        case "stemcell":
            if t == "deep rest"            { return "A deep rest session to support your recovery." }
        case "earlyDiagnosis":
            if t == "gentle focus"         { return "A grounding session to help you stay present amid uncertainty." }
            if t == "calmer mind"          { return "Slow breaths to quiet the worry of waiting." }
        default:
            if ctx.isPostTreatment && t == "healing reflections" {
                return "A soft session to breathe through what you have been through."
            }
        }

        return nil
    }

    // MARK: - Default breathing (before mood selected)

    private static func pickDefaultBreathing(ctx: AppContext, avoiding: Set<String>) -> Suggestion? {
        let preferred: String
        switch ctx.effectiveTreatmentType {
        case "chemotherapy":          preferred = "Gentle Recharge"
        case "surgery":               preferred = "Healing Reflections"
        case "radiation":             preferred = "Inner Calm"
        case "hormone":               preferred = "Calmer Mind"
        case "immunotherapy",
             "targeted":              preferred = "Gentle Recharge"
        case "stemcell":              preferred = "Deep Rest"
        case "earlyDiagnosis":        preferred = "Gentle Focus"
        default:
            preferred = ctx.isPostTreatment ? "Healing Reflections" : "Morning Appreciation"
        }

        let title = avoiding.contains(preferred.lowercased())
            ? alternateBreathing(excluding: preferred, also: avoiding)
            : preferred

        let subtitle = defaultBreathingSubtitle(title: title, ctx: ctx)
        return Suggestion(imageName: breathingImageName(for: title), title: title, subtitle: subtitle)
    }

    private static func alternateBreathing(excluding: String, also avoiding: Set<String>) -> String {
        let options = ["Gentle Focus", "Inner Calm", "Calmer Mind",
                       "Gentle Recharge", "Deep Rest", "Morning Appreciation",
                       "Healing Reflections", "Nausea Relief"]
        return options.first { $0 != excluding && !avoiding.contains($0.lowercased()) }
            ?? "Gentle Focus"
    }

    private static func defaultBreathingSubtitle(title: String, ctx: AppContext) -> String {
        switch ctx.effectiveTreatmentType {
        case "chemotherapy":
            return "A gentle breathing session to help your body rest and recover."
        case "surgery":
            return "A soft session to support your body as it heals."
        case "radiation":
            return "Calming breath to ease the tension that builds during treatment."
        case "hormone":
            return "Steady breaths to balance the emotional shifts from hormone therapy."
        case "immunotherapy", "targeted":
            return "A mild breathing reset for treatment fatigue."
        case "stemcell":
            return "A deep rest session to support your recovery."
        case "earlyDiagnosis":
            return "A grounding session to help you stay present amid uncertainty."
        default:
            if ctx.isPostTreatment {
                return "A soft session to breathe through what you have been through."
            }
            switch normalize(title) {
            case "morning appreciation": return "A warm breathing ritual to lift your spirits."
            case "gentle focus":         return "A grounding session to start your day."
            default:                     return "A gentle breathing session for your day."
            }
        }
    }

    // MARK: - Default hobby (before mood selected)

    private static func pickDefaultHobby(ctx: AppContext, avoidingIDs: Set<String>) -> Suggestion? {
        guard let activity = HobbyActivityLoader.shared.selectActivity(
            ctx:         ctx,
            avoidingIDs: avoidingIDs
        ) else { return fallbackHobby() }

        return Suggestion(imageName: activity.image, title: activity.title, subtitle: activity.subtitle)
    }

    // MARK: - Shared helpers

    private static func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func breathingImageName(for title: String) -> String {
        let sessions = BreathingDataManager().getAllSessions()
        return sessions.first(where: {
            $0.title.caseInsensitiveCompare(title) == .orderedSame
        })?.imageName ?? "BreathingSessionsImage"
    }

    private static func fallback() -> [Suggestion] {
        [
            Suggestion(imageName: "BreathingSessionsImage", title: "Gentle Focus",
                       subtitle: "A soft breathing session to ground your day."),
            Suggestion(imageName: "Cooking", title: "Make a warm drink",
                       subtitle: "Make something warm and sit with it slowly.")
        ]
    }

    private static func fallbackHobby() -> Suggestion {
        Suggestion(imageName: "Reading", title: "Read a page of something light",
                   subtitle: "Read just a page or two of something calming.")
    }
}
