import Foundation

struct AppContext {
    let moodKey: String
    let treatmentState: String
    let journeyPhase: String
    let treatmentName: String
    let cancerStage: String
    let age: Int
    let gender: String
    let hobbies: [String]
    let onboardingTreatmentPhase: String?

    let isDiagnosisCompleted: Bool
    let isWaitCompleted: Bool

    static func current(moodKey: String) -> AppContext {
        let profile = UserProfileDataSource.shared.userProfile
        let onboard = OnboardingData.shared
        let journey = JourneyState.shared
        return AppContext(
            moodKey: moodKey,
            treatmentState: profile.treatmentState,
            journeyPhase: journey.currentStepTitle,
            treatmentName: journey.currentTreatmentName,
            cancerStage: profile.cancerStage,
            age: profile.age,
            gender: profile.gender,
            hobbies: onboard.selectedHobbies,
            onboardingTreatmentPhase: onboard.currentTreatmentPhase,
            isDiagnosisCompleted: journey.isDiagnosisCompleted,
            isWaitCompleted: journey.isWaitCompleted
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
        guard isDiagnosisCompleted else { return false }
        return journeyPhase == "Diagnosed" || journeyPhase == "Waiting for Result"
    }

    var isPhaseUnknown: Bool {
        effectiveTreatmentType == "general"
            && !isPostTreatment
            && !isEarlyDiagnosis
            && !isInActiveTreatment
    }

    // MARK: - Effective treatment type

    var effectiveTreatmentType: String {
        let name = treatmentName.lowercased()
        if name.contains("chemo") { return "chemotherapy" }
        if name.contains("surg") { return "surgery" }
        if name.contains("radiation") { return "radiation" }
        if name.contains("hormone") { return "hormone" }
        if name.contains("immunother") { return "immunotherapy" }
        if name.contains("targeted") { return "targeted" }
        if name.contains("stem") { return "stemcell" }

        let phase = (onboardingTreatmentPhase ?? "").lowercased()
        if phase.contains("chemo") { return "chemotherapy" }
        if phase.contains("surg") { return "surgery" }
        if phase.contains("radiation") { return "radiation" }
        if phase.contains("hormone") { return "hormone" }
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
    var roll = Int.random(in: 0 ..< total)
    for item in items {
        roll -= item.weight
        if roll < 0 { return item }
    }
    return items.last
}

// MARK: - Journal Prompt Engine

enum HomeContextEngine {
    // MARK: - Public entry point

    static func selectJournalPrompt(
        for moodKey: String,
        avoiding recentTitles: Set<String>
    ) -> String {
        let ctx = AppContext.current(moodKey: moodKey)
        var candidates = buildAllPrompts(for: ctx)

        let filtered = candidates.filter { !recentTitles.contains($0.title.lowercased()) }
        if filtered.count >= 3 { candidates = filtered }

        return weightedRandom(from: candidates)?.title
            ?? "What does this moment feel like, and what do you need from yourself right now?"
    }

    // MARK: - Build all prompt candidates

    private static func buildAllPrompts(for ctx: AppContext) -> [WeightedItem] {
        var all: [WeightedItem] = []

        if let content = HomeMoodSuggestionLoader.shared.moodContent(for: ctx.moodKey) {
            for item in content.journaling {
                all.append(WeightedItem(title: item.title, weight: 10, tags: ["mood"]))
            }
        }

        if !ctx.isPhaseUnknown {
            all.append(contentsOf: phasePrompts(for: ctx))
        }

        if !ctx.isPhaseUnknown {
            all.append(contentsOf: moodPhaseComboPrompts(for: ctx))
        }

        all.append(contentsOf: generalPrompts(for: ctx))

        return all
    }

    // MARK: - General prompts (no phase/mood restriction, weight 8–15)

    private static func generalPrompts(for ctx: AppContext) -> [WeightedItem] {
        let baseWeight = ctx.isPhaseUnknown ? 15 : 8
        return [
            WeightedItem(title: "How are you really doing today — not the answer you give people, but the honest one?", weight: baseWeight, tags: ["general"]),
            WeightedItem(title: "What is one thing you are proud of yourself for today?", weight: baseWeight, tags: ["general"]),
            WeightedItem(title: "What does your body need most right now?", weight: baseWeight, tags: ["general"]),
            WeightedItem(title: "Who is on your team right now — the people who are truly with you through this?", weight: baseWeight, tags: ["general"]),
            WeightedItem(title: "What is one small, specific thing you are grateful for today?", weight: baseWeight, tags: ["general"]),
            WeightedItem(title: "What would you want to remember about today a year from now?", weight: baseWeight, tags: ["general"]),
            WeightedItem(title: "What fear can you name today that you haven't said out loud yet?", weight: baseWeight, tags: ["general"]),
            WeightedItem(title: "Write about a small moment of beauty or kindness you witnessed or felt today.", weight: baseWeight, tags: ["general"]),
        ]
    }

    // MARK: - Phase-specific prompt bank (weight 20–28)

    private static func phasePrompts(for ctx: AppContext) -> [WeightedItem] {
        var p: [WeightedItem] = []
        let mood = ctx.moodKey.lowercased()

        switch ctx.effectiveTreatmentType {
        case "chemotherapy":
            appendChemotherapyPrompts(to: &p, mood: mood)
        case "surgery":
            appendSurgeryPrompts(to: &p, mood: mood, isInActiveTreatment: ctx.isInActiveTreatment)
        case "radiation":
            appendRadiationPrompts(to: &p, mood: mood)
        case "hormone":
            appendHormonePrompts(to: &p, mood: mood)
        case "earlyDiagnosis":
            appendEarlyDiagnosisPrompts(to: &p, mood: mood)
        default: break
        }

        if ctx.isDiagnosisCompleted {
            appendJourneyPhasePrompts(to: &p, mood: mood, journeyPhase: ctx.journeyPhase)
        }

        return p
    }

    private static func appendChemotherapyPrompts(to p: inout [WeightedItem], mood: String) {
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["sad", "tired", "anxious", "happy"],
            title: "What helped you get through today, even in a small way?", weight: 26
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["tired", "sad"],
            title: "How is your body feeling right now after treatment?", weight: 25
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["happy", "excited"],
            title: "What is one thing you are proud of yourself for today?", weight: 24
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["tired", "sad"],
            title: "What does rest look like for you right now?", weight: 23
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["sad", "anxious"],
            title: "What would you tell a friend going through chemotherapy today?", weight: 22
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["anxious", "sad", "tired"],
            title: "What part of your day took the most courage?", weight: 21
        )
    }

    private static func appendSurgeryPrompts(to p: inout [WeightedItem], mood: String, isInActiveTreatment: Bool) {
        if isInActiveTreatment {
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["tired", "sad"],
                title: "How does your body feel as it heals today?", weight: 26
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["anxious", "sad", "tired"],
                title: "What are you being patient with yourself about right now?", weight: 25
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "sad"],
                title: "What comfort or support helped you most today?", weight: 24
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "excited"],
                title: "What small sign of your body's strength did you notice today?", weight: 22
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["tired", "sad"],
                title: "What does healing feel like in your body today?", weight: 21
            )
        } else {
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "sad"],
                title: "What has this experience taught you about patience and your own strength?", weight: 26
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "excited"],
                title: "What small sign of recovery did you notice today?", weight: 25
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "excited", "sad"],
                title: "What are you slowly reclaiming for yourself?", weight: 23
            )
        }
    }

    private static func appendRadiationPrompts(to p: inout [WeightedItem], mood: String) {
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["tired", "sad", "anxious"],
            title: "How did your body respond to treatment today?", weight: 26
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["sad", "anxious", "tired"],
            title: "What gave you comfort during today's session?", weight: 25
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["tired", "sad"],
            title: "What does your body need from you most right now?", weight: 24
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["happy", "tired"],
            title: "What routine is helping you stay steady during radiation?", weight: 22
        )
    }

    private static func appendHormonePrompts(to p: inout [WeightedItem], mood: String) {
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["sad", "anxious", "happy"],
            title: "What emotion surprised you today?", weight: 25
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["sad", "anxious", "tired"],
            title: "How are you relating to your body's changes right now?", weight: 24
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["happy", "tired"],
            title: "What feels steady or reliable in your life right now?", weight: 23
        )
    }

    private static func appendEarlyDiagnosisPrompts(to p: inout [WeightedItem], mood: String) {
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["anxious", "sad"],
            title: "What feels most uncertain right now, and what feels solid?", weight: 27
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["anxious", "tired"],
            title: "What question is taking up most of your mental energy today?", weight: 26
        )
        appendIfMoodMatches(
            &p, mood: mood, compatibleMoods: ["happy", "sad", "anxious"],
            title: "Who or what is making this period feel more manageable?", weight: 25
        )
    }

    private static func appendJourneyPhasePrompts(to p: inout [WeightedItem], mood: String, journeyPhase: String) {
        switch journeyPhase {
        case "Diagnosed", "Waiting for Result":
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["anxious", "sad", "tired"],
                title: "What would help you feel more prepared for what is ahead?", weight: 24
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "sad", "anxious"],
                title: "What are you holding onto that gives you strength right now?", weight: 23
            )
        case "Post-Treatment":
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "excited", "sad"],
                title: "What does life feel like now that treatment is behind you?", weight: 27
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "excited"],
                title: "What are you slowly reclaiming for yourself?", weight: 26
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["anxious", "sad"],
                title: "What fear or worry has eased, even slightly?", weight: 24
            )
            appendIfMoodMatches(
                &p, mood: mood, compatibleMoods: ["happy", "excited", "sad"],
                title: "What part of yourself do you want to reconnect with?", weight: 23
            )
        default: break
        }
    }

    // MARK: - Mood filtering helper

    private static func appendIfMoodMatches(
        _ array: inout [WeightedItem],
        mood: String,
        compatibleMoods: [String],
        title: String,
        weight: Int
    ) {
        if mood == "general" || compatibleMoods.contains(mood) {
            array.append(WeightedItem(title: title, weight: weight, tags: ["phase"]))
        }
    }

    // MARK: - Mood × phase combo prompts

    private static func moodPhaseComboPrompts(for ctx: AppContext) -> [WeightedItem] {
        var p: [WeightedItem] = []
        let mood = ctx.moodKey.lowercased()

        appendActiveTreatmentComboPrompts(to: &p, mood: mood, ctx: ctx)
        appendPostTreatmentComboPrompts(to: &p, mood: mood, ctx: ctx)
        appendEarlyDiagnosisComboPrompts(to: &p, mood: mood, ctx: ctx)

        return p
    }

    private static func appendActiveTreatmentComboPrompts(to p: inout [WeightedItem], mood: String, ctx: AppContext) {
        guard ctx.isInActiveTreatment else { return }

        if mood == "anxious" {
            p += [
                WeightedItem(title: "What is your mind most worried about with today's treatment?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What is one thing that is within your control right now?", weight: 38, tags: ["combo"]),
                WeightedItem(title: "What would feel like a safe, small step forward today?", weight: 36, tags: ["combo"]),
            ]
        }
        if mood == "tired" {
            if ctx.effectiveTreatmentType == "chemotherapy" {
                p += [
                    WeightedItem(title: "What has chemo fatigue taken from you today — and what do you still have?", weight: 40, tags: ["combo"]),
                    WeightedItem(title: "What is the smallest act of self-care you can offer yourself right now?", weight: 38, tags: ["combo"]),
                ]
            }
            p += [
                WeightedItem(title: "What would real rest look like for you after today?", weight: 36, tags: ["combo"]),
            ]
        }
        if mood == "sad" {
            p += [
                WeightedItem(title: "What part of your normal life do you miss most right now?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What would feel like a small act of kindness toward yourself today?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "excited" {
            p += [
                WeightedItem(title: "What is making you feel excited or hopeful today despite treatment?", weight: 38, tags: ["combo"]),
                WeightedItem(title: "Write about the good energy you are feeling today — hold onto it.", weight: 36, tags: ["combo"]),
            ]
        }
        if mood == "happy" {
            p += [
                WeightedItem(title: "What brought a genuine smile to your face today during treatment?", weight: 38, tags: ["combo"]),
                WeightedItem(title: "Write a note to yourself about today's good feeling — something to return to on harder days.", weight: 36, tags: ["combo"]),
            ]
        }
    }

    private static func appendPostTreatmentComboPrompts(to p: inout [WeightedItem], mood: String, ctx: AppContext) {
        guard ctx.isPostTreatment else { return }

        if mood == "happy" {
            p += [
                WeightedItem(title: "What does this happiness feel like knowing what you have been through?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What moment today felt like a gift after everything?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "excited" {
            p += [
                WeightedItem(title: "What are you looking forward to that you could not have imagined during treatment?", weight: 40, tags: ["combo"]),
            ]
        }
        if mood == "tired" {
            p += [
                WeightedItem(title: "Post-treatment fatigue is real — what does your energy feel like today?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "sad" {
            p += [
                WeightedItem(title: "Treatment is over but the sadness isn't — what is weighing on you today?", weight: 40, tags: ["combo"]),
            ]
        }
        if mood == "anxious" {
            p += [
                WeightedItem(title: "What is your anxiety most focused on now that treatment is behind you?", weight: 40, tags: ["combo"]),
            ]
        }
    }

    private static func appendEarlyDiagnosisComboPrompts(to p: inout [WeightedItem], mood: String, ctx: AppContext) {
        guard ctx.isEarlyDiagnosis else { return }

        if mood == "happy" {
            p += [
                WeightedItem(title: "What is giving you hope today despite the uncertainty ahead?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "anxious" {
            p += [
                WeightedItem(title: "What is the one thing you most wish you knew right now?", weight: 40, tags: ["combo"]),
                WeightedItem(title: "What is helping you take things one day at a time?", weight: 37, tags: ["combo"]),
            ]
        }
        if mood == "excited" {
            p += [
                WeightedItem(title: "Something is giving you positive energy today despite everything — what is it?", weight: 38, tags: ["combo"]),
            ]
        }
        if mood == "sad" {
            p += [
                WeightedItem(title: "What part of your diagnosis feels heaviest to carry right now?", weight: 40, tags: ["combo"]),
            ]
        }
        if mood == "tired" {
            p += [
                WeightedItem(title: "The weight of a diagnosis can be exhausting — what kind of tired are you feeling today?", weight: 38, tags: ["combo"]),
            ]
        }
    }
}
