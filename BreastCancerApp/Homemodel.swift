import Foundation

class HomeModel {
    static let moods: [Mood] = [
        Mood(imageName: "ExcitedImage", title: "Excited"),
        Mood(imageName: "HappyImage", title: "Happy"),
        Mood(imageName: "SadImage", title: "Sad"),
        Mood(imageName: "TiredImage", title: "Tired"),
        Mood(imageName: "AnxiousImage", title: "Anxious"),
    ]

    static var quote: String {
        DailyQuoteLoader.shared.todayQuote()
    }

    private static let fallbackBreathingImageName = "BreathingSessionsImage"
    private static let journalingImageName = "Journal"

    // MARK: - Breathing helpers

    private static func preferredBreathingTitle(for moodKey: String) -> String {
        switch moodKey.lowercased() {
        case "happy": return "Inner Calm"
        case "sad": return "Healing Reflections"
        case "anxious": return "Calmer Mind"
        case "tired": return "Gentle Recharge"
        case "excited": return "Morning Appreciation"
        default: return "Gentle Focus"
        }
    }

    private static func breathingItem(
        for moodKey: String,
        from content: HomeMoodSuggestionContent
    ) -> HomeMoodSuggestionItem? {
        let preferred = preferredBreathingTitle(for: moodKey)
        return content.breathing.first(where: {
            $0.title.caseInsensitiveCompare(preferred) == .orderedSame
        }) ?? content.breathing.first
    }

    private static func breathingImageName(for breathingTitle: String) -> String {
        let sessions = BreathingDataManager().getAllSessions()
        return sessions.first(where: {
            $0.title.caseInsensitiveCompare(breathingTitle) == .orderedSame
        })?.imageName ?? fallbackBreathingImageName
    }

    // MARK: - Generic helpers

    private static func subtitle(
        for item: HomeMoodSuggestionItem,
        fallback: String
    ) -> String {
        let value = item.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? fallback : value
    }

    private static func normalizedTitle(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func hobbyImageName(for hobby: HomeMoodSuggestionItem) -> String {
        let value = hobby.image?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "Cooking" : value
    }

    private static func randomItem(
        from items: [HomeMoodSuggestionItem],
        avoidingTitles: Set<String>
    ) -> HomeMoodSuggestionItem? {
        guard !items.isEmpty else { return nil }
        let filtered = items.filter { !avoidingTitles.contains(normalizedTitle($0.title)) }
        return (filtered.isEmpty ? items : filtered).randomElement()
    }

    // MARK: - Journal (separate cell)

    static func initialJournalSuggestion(for moodKey: String) -> Suggestion {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
              let journaling = content.journaling.first
        else {
            return fallbackJournalSuggestion
        }
        return Suggestion(
            imageName: journalingImageName,
            title: journaling.title,
            subtitle: subtitle(for: journaling, fallback: "Start Writing...")
        )
    }

    static func journalSuggestion(for moodKey: String) -> Suggestion {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
              let journaling = content.journaling.first
        else {
            return fallbackJournalSuggestion
        }
        return Suggestion(
            imageName: journalingImageName,
            title: journaling.title,
            subtitle: subtitle(for: journaling, fallback: "Start Writing...")
        )
    }

    static func randomJournalSuggestion(
        for moodKey: String,
        avoidingTitles: Set<String> = []
    ) -> Suggestion {
        let ctx = AppContext.current(moodKey: moodKey)
        let avoidingIDs = Set(avoidingTitles)
        let promptTitle: String
        if let jsonPrompt = HobbyActivityLoader.shared.selectJournalPrompt(
            ctx: ctx,
            avoidingIDs: avoidingIDs
        ) {
            promptTitle = jsonPrompt.title
        } else {
            promptTitle = HomeContextEngine.selectJournalPrompt(
                for: moodKey,
                avoiding: avoidingTitles
            )
        }
        return Suggestion(
            imageName: journalingImageName,
            title: promptTitle,
            subtitle: "Start Writing..."
        )
    }

    // MARK: - Suggested For You (only breathing + hobby)

    static func initialSuggestion(for moodKey: String) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return fallbackSuggestedForYou
        }
        var output: [Suggestion] = []
        if let breathing = breathingItem(for: moodKey, from: content) {
            output.append(Suggestion(
                imageName: breathingImageName(for: breathing.title),
                title: breathing.title,
                subtitle: subtitle(for: breathing, fallback: "A soft breathing session.")
            ))
        }
        if let hobby = content.hobby.first {
            output.append(Suggestion(
                imageName: hobbyImageName(for: hobby),
                title: hobby.title,
                subtitle: subtitle(for: hobby, fallback: "Enjoy this hobby at your own pace.")
            ))
        }
        return output.isEmpty ? fallbackSuggestedForYou : output
    }

    static func suggestions(for moodKey: String) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return fallbackSuggestedForYou
        }
        var output: [Suggestion] = []
        if let breathing = breathingItem(for: moodKey, from: content) {
            output.append(Suggestion(
                imageName: breathingImageName(for: breathing.title),
                title: breathing.title,
                subtitle: subtitle(for: breathing, fallback: "A soft breathing session.")
            ))
        }
        if let hobby = content.hobby.first {
            output.append(Suggestion(
                imageName: hobbyImageName(for: hobby),
                title: hobby.title,
                subtitle: subtitle(for: hobby, fallback: "Enjoy this hobby at your own pace.")
            ))
        }
        return output.isEmpty ? fallbackSuggestedForYou : output
    }

    static func randomSuggestions(
        for moodKey: String,
        avoidingBreathingTitles: Set<String> = [],
        avoidingHobbyTitles: Set<String> = []
    ) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return fallbackSuggestedForYou
        }
        var output: [Suggestion] = []
        if let breathing = randomItem(from: content.breathing, avoidingTitles: avoidingBreathingTitles) {
            output.append(Suggestion(
                imageName: breathingImageName(for: breathing.title),
                title: breathing.title,
                subtitle: subtitle(for: breathing, fallback: "A soft breathing session.")
            ))
        }
        if let hobby = randomItem(from: content.hobby, avoidingTitles: avoidingHobbyTitles) {
            output.append(Suggestion(
                imageName: hobbyImageName(for: hobby),
                title: hobby.title,
                subtitle: subtitle(for: hobby, fallback: "Enjoy this hobby at your own pace.")
            ))
        }
        return output.isEmpty ? fallbackSuggestedForYou : output
    }

    // MARK: - Fallbacks

    private static let fallbackJournalSuggestion = Suggestion(
        imageName: "Journal",
        title: "Write about someone who brings joy and why they matter.",
        subtitle: "Start Writing..."
    )

    private static let fallbackSuggestedForYou: [Suggestion] = [
        Suggestion(
            imageName: "BreathingSessionsImage",
            title: "Gentle Focus",
            subtitle: "A soft breathing session to keep your energy steady."
        ),
        Suggestion(
            imageName: "Cooking",
            title: "Cooking",
            subtitle: "Make a snack you love and enjoy the process."
        ),
    ]

    // MARK: - Articles

    // MARK: - Articles

    static let articles: [Article] = [
        Article(
            imageName: "article_1_hero",
            title: "Understanding Breast Cancer: Basics and Treatment Options",
            subtitle: "Early detection and advances in treatment have significantly improved survival rates."
        ),
        Article(
            imageName: "article_2_hero",
            title: "Managing Physical Side Effects of Breast Cancer Treatment",
            subtitle: "Understanding what to expect and how to cope can help patients maintain comfort and quality of life."
        ),
        Article(
            imageName: "article_3_hero",
            title: "Post-Treatment Recovery and Follow-Up Care",
            subtitle: "Recovery continues beyond the final treatment session."
        ),
        Article(
            imageName: "article_4_hero",
            title: "Nutrition and Healthy Eating During and After Treatment",
            subtitle: "Good nutrition plays an important role in supporting the body during and after breast cancer treatment."
        ),
        Article(
            imageName: "article_5_hero",
            title: "Physical Activity and Exercise During Breast Cancer Recovery",
            subtitle: "Physical activity is an important part of recovery during and after breast cancer treatment."
        ),
    ]

    // MARK: - Hobby check

    static func isHobbySuggestion(title: String) -> Bool {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else { return false }
        return HomeMoodSuggestionLoader.shared.root?.moods.values.contains { content in
            content.hobby.contains {
                $0.title.caseInsensitiveCompare(normalizedTitle) == .orderedSame
            }
        } ?? false
    }
}

// MARK: - Mood header text (used by HomeViewController)

extension HomeModel {
    static func moodHeaderText(for moodKey: String, hasUserSelectedMood: Bool) -> String {
        guard hasUserSelectedMood else { return "How are you feeling right now?" }
        switch moodKey.lowercased() {
        case "anxious": return "Take a breath - you're safe here"
        case "sad": return "Let's take this gently today"
        case "tired": return "Energy feels low - We've got you"
        case "happy": return "Keep the good energy going"
        case "excited": return "Great to see you feeling excited!"
        default: return "How are you feeling right now?"
        }
    }
}
