//
//  HomeContextEngine.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/03/26.
//

// A snapshot of everything we know about the user right now.
// Built once per suggestion/prompt call so all engines read consistent data.

import Foundation

struct AppContext {
    let moodKey: String
    let treatmentState: String        // "Ongoing" | "Completed" | "Observation" | "Not Specified"
    let journeyPhase: String          // "Diagnosed" | "Waiting for Result" | "Treatment" | "Post-Treatment"
    let treatmentName: String         // e.g. "Chemotherapy", "Surgery", "Not started yet"
    let cancerStage: String           // "Stage II" etc.
    let age: Int
    let gender: String
    let hobbies: [String]
    let onboardingTreatmentPhase: String?  // from OnboardingData e.g. "Chemotherapy", "Surgery"

    static func current(moodKey: String) -> AppContext {
        let profile  = UserProfileDataSource.shared.userProfile
        let onboard  = OnboardingData.shared
        let journey  = JourneyState.shared
        return AppContext(
            moodKey:                 moodKey,
            treatmentState:          profile.treatmentState,
            journeyPhase:            journey.currentStepTitle,
            treatmentName:           journey.currentTreatmentName,
            cancerStage:             profile.cancerStage,
            age:                     profile.age,
            gender:                  profile.gender,
            hobbies:                 onboard.selectedHobbies,
            onboardingTreatmentPhase: onboard.currentTreatmentPhase
        )
    }

    // MARK: - Convenience flags
    var isInActiveTreatment: Bool {
        treatmentState == "Ongoing" || journeyPhase == "Treatment"
    }
    var isPostTreatment: Bool {
        treatmentState == "Completed" || journeyPhase == "Post-Treatment"
    }
    var isEarlyDiagnosis: Bool {
        journeyPhase == "Diagnosed" || journeyPhase == "Waiting for Result"
    }

    // MARK: - Effective treatment type
    // Combines Journey screen data (higher priority) with Onboarding data (fallback)
    var effectiveTreatmentType: String {
        // Journey screen data first — this is the most current and specific
        let name = treatmentName.lowercased()
        if name.contains("chemo")      { return "chemotherapy" }
        if name.contains("surg")       { return "surgery" }
        if name.contains("radiation")  { return "radiation" }
        if name.contains("hormone")    { return "hormone" }
        if name.contains("immunother") { return "immunotherapy" }
        if name.contains("targeted")   { return "targeted" }
        if name.contains("stem")       { return "stemcell" }

        // Onboarding phase as fallback
        let phase = (onboardingTreatmentPhase ?? "").lowercased()
        if phase.contains("chemo")     { return "chemotherapy" }
        if phase.contains("surg")      { return "surgery" }
        if phase.contains("radiation") { return "radiation" }
        if phase.contains("hormone")   { return "hormone" }
        if phase.contains("diagnosed") { return "earlyDiagnosis" }

        return "general"
    }
}

// MARK: - Weighted item for random selection
struct WeightedItem {
    let title: String
    var weight: Int
    let tags: [String]
}

// MARK: - Weighted random selection
func weightedRandom(from items: [WeightedItem]) -> WeightedItem? {
    guard !items.isEmpty else { return nil }
    let total = items.reduce(0) { $0 + $1.weight }
    guard total > 0 else { return items.randomElement() }
    var roll = Int.random(in: 0..<total)
    for item in items {
        roll -= item.weight
        if roll < 0 { return item }
    }
    return items.last
}

// MARK: - Journal Prompt Engine
struct HomeContextEngine {

    // MARK: - Public entry point
    static func selectJournalPrompt(
        for moodKey: String,
        avoiding recentTitles: Set<String>
    ) -> String {
        let ctx = AppContext.current(moodKey: moodKey)
        var candidates = buildAllPrompts(for: ctx)

        // Filter recently shown if we still have enough variety
        let filtered = candidates.filter { !recentTitles.contains($0.title.lowercased()) }
        if filtered.count >= 3 { candidates = filtered }

        return weightedRandom(from: candidates)?.title
            ?? "What does this moment feel like, and what do you need from yourself right now?"
    }

    // MARK: - Build all prompt candidates
    private static func buildAllPrompts(for ctx: AppContext) -> [WeightedItem] {
        var all: [WeightedItem] = []

        // Layer 1 — Mood prompts from JSON (base weight 10)
        if let content = HomeMoodSuggestionLoader.shared.moodContent(for: ctx.moodKey) {
            for item in content.journaling {
                all.append(WeightedItem(title: item.title, weight: 10, tags: ["mood"]))
            }
        }

        // Layer 2 — Phase-specific prompts (weight 20–30, HIGHER PRIORITY)
        all.append(contentsOf: phasePrompts(for: ctx))

        // Layer 3 — Mood × phase combos (weight 35–40, HIGHEST PRIORITY)
        all.append(contentsOf: moodPhaseComboPrompts(for: ctx))

        return all
    }

    // MARK: - Phase-specific prompt bank (weight 20–28)
    private static func phasePrompts(for ctx: AppContext) -> [WeightedItem] {
        var p: [WeightedItem] = []

        switch ctx.effectiveTreatmentType {

        case "chemotherapy":
            p += [
                WeightedItem(title: "What helped you get through today, even in a small way?", weight: 26, tags: ["phase"]),
                WeightedItem(title: "How is your body feeling right now after treatment?", weight: 25, tags: ["phase"]),
                WeightedItem(title: "What is one thing you are proud of yourself for today?", weight: 24, tags: ["phase"]),
                WeightedItem(title: "What does rest look like for you right now?", weight: 23, tags: ["phase"]),
                WeightedItem(title: "What would you tell a friend going through chemotherapy today?", weight: 22, tags: ["phase"]),
                WeightedItem(title: "What part of your day took the most courage?", weight: 21, tags: ["phase"]),
            ]

        case "surgery":
            p += [
                WeightedItem(title: "How does your body feel as it heals today?", weight: 26, tags: ["phase"]),
                WeightedItem(title: "What small sign of recovery did you notice today?", weight: 25, tags: ["phase"]),
                WeightedItem(title: "What are you being patient with yourself about right now?", weight: 24, tags: ["phase"]),
                WeightedItem(title: "What comfort or support helped you most today?", weight: 22, tags: ["phase"]),
                WeightedItem(title: "What does healing feel like in your body today?", weight: 21, tags: ["phase"]),
            ]

        case "radiation":
            p += [
                WeightedItem(title: "How did your body respond to treatment today?", weight: 26, tags: ["phase"]),
                WeightedItem(title: "What gave you comfort during today's session?", weight: 25, tags: ["phase"]),
                WeightedItem(title: "What does your body need from you most right now?", weight: 24, tags: ["phase"]),
                WeightedItem(title: "What routine is helping you stay steady during radiation?", weight: 22, tags: ["phase"]),
            ]

        case "hormone":
            p += [
                WeightedItem(title: "What emotion surprised you today?", weight: 25, tags: ["phase"]),
                WeightedItem(title: "How are you relating to your body's changes right now?", weight: 24, tags: ["phase"]),
                WeightedItem(title: "What feels steady or reliable in your life right now?", weight: 23, tags: ["phase"]),
            ]

        case "earlyDiagnosis":
            p += [
                WeightedItem(title: "What feels most uncertain right now, and what feels solid?", weight: 27, tags: ["phase"]),
                WeightedItem(title: "What question is taking up most of your mental energy today?", weight: 26, tags: ["phase"]),
                WeightedItem(title: "Who or what is making this period feel more manageable?", weight: 25, tags: ["phase"]),
            ]

        default: break
        }

        // Journey-phase-based prompts (use journeyPhase directly)
        switch ctx.journeyPhase {
        case "Diagnosed", "Waiting for Result":
            p += [
                WeightedItem(title: "What would help you feel more prepared for what is ahead?", weight: 24, tags: ["phase"]),
                WeightedItem(title: "What are you holding onto that gives you strength right now?", weight: 23, tags: ["phase"]),
            ]
        case "Post-Treatment":
            p += [
                WeightedItem(title: "What does life feel like now that treatment is behind you?", weight: 27, tags: ["phase"]),
                WeightedItem(title: "What are you slowly reclaiming for yourself?", weight: 26, tags: ["phase"]),
                WeightedItem(title: "What fear or worry has eased, even slightly?", weight: 24, tags: ["phase"]),
                WeightedItem(title: "What part of yourself do you want to reconnect with?", weight: 23, tags: ["phase"]),
            ]
        default: break
        }

        return p
    }

    // MARK: - Mood × phase combo prompts (weight 35–40, highest)
    private static func moodPhaseComboPrompts(for ctx: AppContext) -> [WeightedItem] {
        var p: [WeightedItem] = []
        let mood = ctx.moodKey.lowercased()
        let type = ctx.effectiveTreatmentType

        if mood == "anxious" && ctx.isInActiveTreatment {
            p += [
                WeightedItem(title: "What is your mind most worried about with today's treatment?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What is one thing that is within your control right now?", weight: 38, tags: ["combo"]),
                WeightedItem(title: "What would feel like a safe, small step forward today?", weight: 36, tags: ["combo"]),
            ]
        }
        if mood == "tired" && type == "chemotherapy" {
            p += [
                WeightedItem(title: "What has chemo fatigue taken from you today — and what do you still have?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What is the smallest act of self-care you can offer yourself right now?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "tired" && ctx.isInActiveTreatment {
            p += [
                WeightedItem(title: "What would real rest look like for you after today?", weight: 36, tags: ["combo"]),
            ]
        }
        if mood == "sad" && ctx.isInActiveTreatment {
            p += [
                WeightedItem(title: "What part of your normal life do you miss most right now?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What would feel like a small act of kindness toward yourself today?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "happy" && ctx.isPostTreatment {
            p += [
                WeightedItem(title: "What does this happiness feel like knowing what you have been through?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What moment today felt like a gift after everything?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "excited" && ctx.isPostTreatment {
            p += [
                WeightedItem(title: "What are you looking forward to that you could not have imagined during treatment?", weight: 40, tags: ["combo"]),
            ]
        }
        if mood == "happy" && ctx.isEarlyDiagnosis {
            p += [
                WeightedItem(title: "What is giving you hope today despite the uncertainty ahead?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "anxious" && ctx.isEarlyDiagnosis {
            p += [
                WeightedItem(title: "What is the one thing you most wish you knew right now?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What is helping you take things one day at a time?", weight: 37, tags: ["combo"]),
            ]
        }

        return p
    }
}
