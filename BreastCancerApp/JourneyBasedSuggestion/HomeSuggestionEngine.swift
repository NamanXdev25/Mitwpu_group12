//
//  HomeSuggestionEngine.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/03/26.
//

// Picks breathing + hobby suggestions using a weighted algorithm.
// Journey/phase data gets the highest priority weights.

import Foundation

struct HomeSuggestionEngine {

    // MARK: - Default suggestions (before mood selected)
    static func defaultSuggestions(
        avoiding recentBreathing: Set<String>,
        avoiding recentHobby: Set<String>
    ) -> [Suggestion] {
        let ctx = AppContext.current(moodKey: "general")
        var result: [Suggestion] = []

        if let b = pickDefaultBreathing(ctx: ctx, avoiding: recentBreathing) { result.append(b) }
        if let h = pickDefaultHobby(ctx: ctx, avoiding: recentHobby)         { result.append(h) }

        return result.isEmpty ? fallback() : result
    }

    // MARK: - Mood-based suggestions (after mood selected)
    static func moodSuggestions(
        for moodKey: String,
        avoiding recentBreathing: Set<String>,
        avoiding recentHobby: Set<String>
    ) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return defaultSuggestions(avoiding: recentBreathing, avoiding: recentHobby)
        }

        let ctx = AppContext.current(moodKey: moodKey)
        print("Context — phase: \(ctx.journeyPhase), treatment: \(ctx.treatmentName), type: \(ctx.effectiveTreatmentType), state: \(ctx.treatmentState), age: \(ctx.age), hobbies: \(ctx.hobbies)")

        // --- Breathing ---
        let breathingItems = buildBreathingCandidates(from: content.breathing, moodKey: moodKey, ctx: ctx)
        let breathingFiltered = breathingItems.filter { !recentBreathing.contains($0.title.lowercased()) }
        let breathingPool = breathingFiltered.isEmpty ? breathingItems : breathingFiltered
        let pickedBreathing = weightedRandom(from: breathingPool)

        // --- Hobby ---
        let hobbyItems = buildHobbyCandidates(from: content.hobby, ctx: ctx)
        let hobbyFiltered = hobbyItems.filter { !recentHobby.contains($0.title.lowercased()) }
        let hobbyPool = hobbyFiltered.isEmpty ? hobbyItems : hobbyFiltered
        let pickedHobby = weightedRandom(from: hobbyPool)

        var result: [Suggestion] = []

        if let picked = pickedBreathing,
           let item = content.breathing.first(where: { $0.title.lowercased() == picked.title.lowercased() }) {
            result.append(Suggestion(
                imageName: breathingImageName(for: item.title),
                title: item.title,
                subtitle: item.description ?? "A calming breathing session."
            ))
        }

        if let picked = pickedHobby,
           let item = content.hobby.first(where: { $0.title.lowercased() == picked.title.lowercased() }) {
            result.append(Suggestion(
                imageName: hobbyImage(for: item),
                title: item.title,
                subtitle: item.description ?? "Enjoy this activity at your own pace."
            ))
        }

        return result.isEmpty ? fallback() : result
    }

    // MARK: - Breathing candidate scoring
    // Weight bands:
    //   Phase match   : +30  (highest — journey data priority)
    //   Mood match    : +20
    //   User activity : +4–12 (scales with tap count)
    //   Base          : 10
    private static func buildBreathingCandidates(
        from items: [HomeMoodSuggestionItem],
        moodKey: String,
        ctx: AppContext
    ) -> [WeightedItem] {
        items.map { item in
            var w = 10

            // Phase priority (highest weight band)
            w += breathingPhaseScore(title: item.title, ctx: ctx)

            // Mood priority (second band)
            w += breathingMoodScore(title: item.title, moodKey: moodKey)

            // User engagement (scales existing interest)
            w += UserActivityStore.shared.breathingWeight(for: item.title) * 4

            return WeightedItem(title: item.title, weight: max(1, w), tags: [])
        }
    }

    private static func breathingPhaseScore(title: String, ctx: AppContext) -> Int {
        let t = title.lowercased()
        switch ctx.effectiveTreatmentType {
        case "chemotherapy":
            if t == "nausea relief"     { return 30 }
            if t == "gentle recharge"   { return 22 }
            if t == "gentle focus"      { return 18 }
            if t == "inner calm"        { return 15 }
        case "surgery":
            if t == "healing reflections" { return 30 }
            if t == "gentle recharge"     { return 25 }
            if t == "deep rest"           { return 20 }
        case "radiation":
            if t == "inner calm"        { return 30 }
            if t == "calmer mind"       { return 25 }
            if t == "gentle recharge"   { return 18 }
        case "hormone":
            if t == "calmer mind"       { return 28 }
            if t == "inner calm"        { return 22 }
            if t == "morning appreciation" { return 18 }
        case "earlyDiagnosis":
            if t == "gentle focus"      { return 28 }
            if t == "calmer mind"       { return 22 }
            if t == "healing reflections" { return 18 }
        default:
            if ctx.isPostTreatment {
                if t == "healing reflections" { return 25 }
                if t == "morning appreciation" { return 20 }
            }
            if ctx.isEarlyDiagnosis {
                if t == "gentle focus"  { return 25 }
                if t == "inner calm"    { return 18 }
            }
        }
        return 0
    }

    private static func breathingMoodScore(title: String, moodKey: String) -> Int {
        let t = title.lowercased()
        switch moodKey.lowercased() {
        case "anxious":
            if t == "calmer mind"     { return 20 }
            if t == "gentle focus"    { return 16 }
            if t == "inner calm"      { return 14 }
        case "tired":
            if t == "gentle recharge" { return 20 }
            if t == "deep rest"       { return 18 }
            if t == "inner calm"      { return 12 }
        case "sad":
            if t == "healing reflections" { return 20 }
            if t == "gentle focus"        { return 16 }
            if t == "deep rest"           { return 12 }
        case "happy":
            if t == "morning appreciation" { return 20 }
            if t == "inner calm"           { return 14 }
        case "excited":
            if t == "gentle focus"         { return 20 }
            if t == "morning appreciation" { return 16 }
            if t == "calmer mind"          { return 12 }
        default: break
        }
        return 0
    }

    // MARK: - Hobby candidate scoring
    // Weight bands:
    //   Phase appropriateness : +25  (journey data priority)
    //   Onboarding hobby match: +20
    //   User engagement       : +4–12
    //   Base                  : 10
    private static func buildHobbyCandidates(
        from items: [HomeMoodSuggestionItem],
        ctx: AppContext
    ) -> [WeightedItem] {
        let onboardingSet = Set(ctx.hobbies.map { $0.lowercased() })
        let topEngaged    = Set(UserActivityStore.shared.topHobbies(limit: 5))

        return items.map { item in
            var w = 10
            let key = item.title.lowercased()

            // Phase appropriateness (highest band — journey data priority)
            w += hobbyPhaseScore(key: key, ctx: ctx)

            // Onboarding hobby match (second band)
            if onboardingSet.contains(key) { w += 20 }

            // Top engaged by the user
            if topEngaged.contains(key)    { w += 12 }

            // Activity weight (scales with tap history)
            w += UserActivityStore.shared.hobbyWeight(for: key) * 4

            return WeightedItem(title: item.title, weight: max(1, w), tags: [])
        }
    }

    private static func hobbyPhaseScore(key: String, ctx: AppContext) -> Int {
        switch ctx.effectiveTreatmentType {

        case "chemotherapy":
            // Low-energy hobbies strongly preferred during chemo
            switch key {
            case "listening to calming music": return 25
            case "reading":                    return 22
            case "meditation":                 return 22
            case "watching movies":            return 20
            case "drawing":                    return 15
            case "crafting":                   return 12
            case "talking to family":          return 15
            case "walking":                    return -5  // penalise high-energy
            case "cooking":                    return 8
            default:                           return 0
            }

        case "surgery":
            switch key {
            case "listening to calming music": return 25
            case "watching movies":            return 23
            case "reading":                    return 22
            case "meditation":                 return 20
            case "talking to family":          return 18
            case "drawing":                    return 12
            case "walking":                    return -8
            default:                           return 0
            }

        case "radiation":
            switch key {
            case "meditation":                 return 25
            case "listening to calming music": return 22
            case "reading":                    return 20
            case "drawing":                    return 18
            case "gardening":                  return 15
            case "walking":                    return 8
            default:                           return 0
            }

        case "hormone":
            switch key {
            case "gardening":                  return 22
            case "walking":                    return 20
            case "talking to family":          return 20
            case "cooking":                    return 18
            case "reading":                    return 15
            default:                           return 0
            }

        default:
            if ctx.isPostTreatment {
                switch key {
                case "walking":    return 22
                case "gardening":  return 20
                case "cooking":    return 18
                case "drawing":    return 15
                default:           return 0
                }
            }
            if ctx.isEarlyDiagnosis {
                switch key {
                case "meditation":                 return 22
                case "listening to calming music": return 20
                case "reading":                    return 18
                case "talking to family":          return 18
                default:                           return 0
                }
            }
            return 0
        }
    }

    // MARK: - Default breathing (no mood selected yet)
    private static func pickDefaultBreathing(ctx: AppContext, avoiding: Set<String>) -> Suggestion? {
        let preferred: String
        switch ctx.effectiveTreatmentType {
        case "chemotherapy":   preferred = "Nausea Relief"
        case "surgery":        preferred = "Healing Reflections"
        case "radiation":      preferred = "Inner Calm"
        case "hormone":        preferred = "Calmer Mind"
        case "earlyDiagnosis": preferred = "Gentle Focus"
        default:
            preferred = ctx.isPostTreatment ? "Healing Reflections" : "Morning Appreciation"
        }

        let title = avoiding.contains(preferred.lowercased())
            ? alternateBreathing(excluding: preferred, also: avoiding)
            : preferred

        let sessions = BreathingDataManager().getAllSessions()
        let imgName = sessions.first(where: {
            $0.title.caseInsensitiveCompare(title) == .orderedSame
        })?.imageName ?? "BreathingSessionsImage"

        let subtitle = defaultBreathingSubtitle(title: title, ctx: ctx)
        return Suggestion(imageName: imgName, title: title, subtitle: subtitle)
    }

    private static func alternateBreathing(excluding: String, also avoiding: Set<String>) -> String {
        let options = ["Gentle Focus", "Inner Calm", "Calmer Mind",
                       "Gentle Recharge", "Deep Rest", "Morning Appreciation",
                       "Healing Reflections", "Nausea Relief"]
        return options.first { $0 != excluding && !avoiding.contains($0.lowercased()) }
            ?? "Gentle Focus"
    }

    private static func defaultBreathingSubtitle(title: String, ctx: AppContext) -> String {
        switch title {
        case "Nausea Relief":        return "Gentle breathing to ease nausea and fatigue."
        case "Healing Reflections":  return "A soft session to support your healing."
        case "Inner Calm":           return "Calming breath to ease tension from treatment."
        case "Calmer Mind":          return "Steady breaths to quiet the mind."
        case "Gentle Focus":         return "A grounding session to start your day."
        case "Morning Appreciation": return "A warm breathing ritual to lift your spirits."
        default:                     return "A gentle breathing session for your day."
        }
    }

    // MARK: - Default hobby (no mood selected yet)
    private static func pickDefaultHobby(ctx: AppContext, avoiding: Set<String>) -> Suggestion? {
        // Priority 1: top engaged hobbies from past activity
        let topEngaged = UserActivityStore.shared.topHobbies(limit: 3)

        // Priority 2: onboarding hobbies
        let onboarding = ctx.hobbies.map { $0.lowercased() }

        // Priority 3: phase-appropriate defaults
        let phaseDefaults = defaultHobbiesForPhase(ctx: ctx)

        // Merge in priority order, deduplicate
        var candidates: [String] = []
        var seen = Set<String>()
        for h in (topEngaged + onboarding + phaseDefaults) {
            if seen.insert(h).inserted { candidates.append(h) }
        }

        // Filter recently shown
        let filtered = candidates.filter { !avoiding.contains($0) }
        let final = filtered.isEmpty ? candidates : filtered
        guard let chosen = final.first else { return fallbackHobby() }

        // Look up in JSON for image + subtitle
        if let item = findHobbyItem(titled: chosen) {
            return Suggestion(
                imageName: hobbyImage(for: item),
                title: item.title,
                subtitle: item.description ?? "Enjoy this at your own pace."
            )
        }
        return Suggestion(imageName: "Cooking", title: chosen.capitalized,
                          subtitle: "A gentle activity for your day.")
    }

    private static func defaultHobbiesForPhase(ctx: AppContext) -> [String] {
        switch ctx.effectiveTreatmentType {
        case "chemotherapy":
            return ["listening to calming music", "reading", "meditation", "watching movies"]
        case "surgery":
            return ["listening to calming music", "watching movies", "reading", "meditation"]
        case "radiation":
            return ["meditation", "listening to calming music", "reading", "drawing"]
        case "hormone":
            return ["walking", "gardening", "talking to family", "cooking"]
        default:
            if ctx.isPostTreatment   { return ["walking", "gardening", "cooking", "drawing"] }
            if ctx.isEarlyDiagnosis  { return ["meditation", "listening to calming music", "talking to family"] }
            return ["reading", "meditation", "cooking", "listening to calming music"]
        }
    }

    // MARK: - Helpers
    private static func findHobbyItem(titled: String) -> HomeMoodSuggestionItem? {
        guard let root = HomeMoodSuggestionLoader.shared.root else { return nil }
        for content in root.moods.values {
            if let match = content.hobby.first(where: { $0.title.lowercased() == titled.lowercased() }) {
                return match
            }
        }
        return nil
    }

    private static func hobbyImage(for item: HomeMoodSuggestionItem) -> String {
        let v = item.image?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return v.isEmpty ? "Cooking" : v
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
            Suggestion(imageName: "Cooking", title: "Cooking",
                       subtitle: "Make something warm and nourishing.")
        ]
    }

    private static func fallbackHobby() -> Suggestion {
        Suggestion(imageName: "Reading", title: "Reading",
                   subtitle: "Read a page of something light and calming.")
    }
}
