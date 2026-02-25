import UIKit

// MARK: - Home Section Types
enum HomeSectionType: Int, CaseIterable {
    case title = 0
    case quote
    case mood
    case suggestion
    case articles
}

// MARK: - Item Model for Diffable Data Source
struct HomeItem: Hashable {
    let id = UUID()
    let type: ItemType

    enum ItemType: Hashable {
        case title
        case quote(String)
        case mood
        case suggestion(Suggestion)
        case article(Article)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HomeItem, rhs: HomeItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mood Model
struct Mood: Hashable {
    let imageName: String
    let title: String
}

// MARK: - Suggestion Model
struct Suggestion: Hashable {
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Article Model
struct Article: Hashable {
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Home Data Model
class HomeModel {

    // MARK: - Mood Data
    static let moods: [Mood] = [
        Mood(imageName: "ExcitedImage", title: "Excited"),
        Mood(imageName: "HappyImage", title: "Happy"),
        Mood(imageName: "SadImage", title: "Sad"),
        Mood(imageName: "TiredImage", title: "Tired"),
        Mood(imageName: "AnxiousImage", title: "Anxious")
    ]

    // MARK: - Quote Data
    static let quote = "My body and I are working together beautifully"

    // MARK: - Suggestion Images (fixed per category)
    private static let breathingImageName = "BreathingSessionsImage"
    private static let journalingImageName = "Journal"
    private static let hobbyImageName = "Cooking"

    // Different breathing title per mood
    private static func preferredBreathingTitle(for moodKey: String) -> String {
        switch moodKey.lowercased() {
        case "happy":
            return "Inner Calm"
        case "sad":
            return "Healing Reflections"
        case "anxious":
            return "Calmer Mind"
        case "tired":
            return "Gentle Recharge"
        case "excited":
            return "Morning Appreciation"
        default:
            return "Gentle Focus"
        }
    }

    private static func breathingItem(
        for moodKey: String,
        from content: HomeMoodSuggestionContent
    ) -> HomeMoodSuggestionItem? {
        let preferred = preferredBreathingTitle(for: moodKey)
        return content.breathing.first(where: { $0.title == preferred }) ?? content.breathing.first
    }

    // Initial load -> only breathing suggestion
    static func initialSuggestion(for moodKey: String) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
              let breathing = breathingItem(for: moodKey, from: content) else {
            return [
                Suggestion(
                    imageName: breathingImageName,
                    title: "Gentle Focus",
                    subtitle: "A soft breathing session to keep your energy steady."
                )
            ]
        }

        return [
            Suggestion(
                imageName: breathingImageName,
                title: breathing.title,
                subtitle: breathing.description
            )
        ]
    }

    // After mood tap -> breathing + journaling + hobby (3 cards)
    static func suggestions(for moodKey: String) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return fallbackSuggestions
        }

        var output: [Suggestion] = []

        if let breathing = breathingItem(for: moodKey, from: content) {
            output.append(
                Suggestion(
                    imageName: breathingImageName,
                    title: breathing.title,
                    subtitle: breathing.description
                )
            )
        }

        if let journaling = content.journaling.first {
            output.append(
                Suggestion(
                    imageName: journalingImageName,
                    title: journaling.title,
                    subtitle: journaling.description
                )
            )
        }

        if let hobby = content.hobby.first {
            output.append(
                Suggestion(
                    imageName: hobbyImageName,
                    title: hobby.title,
                    subtitle: hobby.description
                )
            )
        }

        return output.isEmpty ? fallbackSuggestions : output
    }

    private static let fallbackSuggestions: [Suggestion] = [
        Suggestion(
            imageName: "BreathingSessionsImage",
            title: "Gentle Focus",
            subtitle: "A soft breathing session to keep your energy steady."
        ),
        Suggestion(
            imageName: "Journal",
            title: "Today’s small win",
            subtitle: "Describe a tiny success and how it improved your mood."
        ),
        Suggestion(
            imageName: "Cooking",
            title: "Cooking",
            subtitle: "Make a snack you love and enjoy the process."
        )
    ]

    // MARK: - Articles Data
    static let articles: [Article] = [
        Article(
            imageName: "article_image_1",
            title: "Debunking Common Breast Cancer Myths",
            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
        ),
        Article(
            imageName: "article_image_2",
            title: "Implications of Dense Breast Tissue",
            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
        )
    ]
}
