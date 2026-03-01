////import Foundation
////
////class HomeModel {
////
////    static let moods: [Mood] = [
////        Mood(imageName: "ExcitedImage", title: "Excited"),
////        Mood(imageName: "HappyImage", title: "Happy"),
////        Mood(imageName: "SadImage", title: "Sad"),
////        Mood(imageName: "TiredImage", title: "Tired"),
////        Mood(imageName: "AnxiousImage", title: "Anxious")
////    ]
////
////    static let quote = "My body and I are working together beautifully"
////
////    private static let breathingImageName = "BreathingSessionsImage"
////    private static let journalingImageName = "Journal"
////    private static let hobbyImageName = "Cooking"
////
////    private static func preferredBreathingTitle(for moodKey: String) -> String {
////        switch moodKey.lowercased() {
////        case "happy": return "Inner Calm"
////        case "sad": return "Healing Reflections"
////        case "anxious": return "Calmer Mind"
////        case "tired": return "Gentle Recharge"
////        case "excited": return "Morning Appreciation"
////        default: return "Gentle Focus"
////        }
////    }
////
////    private static func breathingItem(for moodKey: String, from content: HomeMoodSuggestionContent) -> HomeMoodSuggestionItem? {
////        let preferred = preferredBreathingTitle(for: moodKey)
////        return content.breathing.first(where: { $0.title == preferred }) ?? content.breathing.first
////    }
////
////    // MARK: - Journal (separate cell)
////
////    static func initialJournalSuggestion(for moodKey: String) -> Suggestion {
////        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
////              let journaling = content.journaling.first else {
////            return fallbackJournalSuggestion
////        }
////
////        return Suggestion(
////            imageName: journalingImageName,
////            title: journaling.title,
////            subtitle: journaling.description
////        )
////    }
////
////    static func journalSuggestion(for moodKey: String) -> Suggestion {
////        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
////              let journaling = content.journaling.first else {
////            return fallbackJournalSuggestion
////        }
////
////        return Suggestion(
////            imageName: journalingImageName,
////            title: journaling.title,
////            subtitle: journaling.description
////        )
////    }
////
////    // MARK: - Suggested For You (only breathing + hobby)
////
////    static func initialSuggestion(for moodKey: String) -> [Suggestion] {
////        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
////            return fallbackSuggestedForYou
////        }
////
////        var output: [Suggestion] = []
////
////        if let breathing = breathingItem(for: moodKey, from: content) {
////            output.append(
////                Suggestion(
////                    imageName: breathingImageName,
////                    title: breathing.title,
////                    subtitle: breathing.description
////                )
////            )
////        }
////
////        if let hobby = content.hobby.first {
////            output.append(
////                Suggestion(
////                    imageName: hobbyImageName,
////                    title: hobby.title,
////                    subtitle: hobby.description
////                )
////            )
////        }
////
////        return output.isEmpty ? fallbackSuggestedForYou : output
////    }
////
////    static func suggestions(for moodKey: String) -> [Suggestion] {
////        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
////            return fallbackSuggestedForYou
////        }
////
////        var output: [Suggestion] = []
////
////        if let breathing = breathingItem(for: moodKey, from: content) {
////            output.append(
////                Suggestion(
////                    imageName: breathingImageName,
////                    title: breathing.title,
////                    subtitle: breathing.description
////                )
////            )
////        }
////
////        if let hobby = content.hobby.first {
////            output.append(
////                Suggestion(
////                    imageName: hobbyImageName,
////                    title: hobby.title,
////                    subtitle: hobby.description
////                )
////            )
////        }
////
////        return output.isEmpty ? fallbackSuggestedForYou : output
////    }
////
////    private static let fallbackJournalSuggestion = Suggestion(
////        imageName: "Journal",
////        title: "Write about someone who brings joy and why they matter.",
////        subtitle: "Start Writing..."
////    )
////
////    private static let fallbackSuggestedForYou: [Suggestion] = [
////        Suggestion(
////            imageName: "BreathingSessionsImage",
////            title: "Gentle Focus",
////            subtitle: "A soft breathing session to keep your energy steady."
////        ),
////        Suggestion(
////            imageName: "Cooking",
////            title: "Cooking",
////            subtitle: "Make a snack you love and enjoy the process."
////        )
////    ]
////
////    static let articles: [Article] = [
////        Article(
////            imageName: "article_image_1",
////            title: "Debunking Common Breast Cancer Myths",
////            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
////        ),
////        Article(
////            imageName: "article_image_2",
////            title: "Implications of Dense Breast Tissue",
////            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
////        )
////    ]
////}
//
//import Foundation
//
//class HomeModel {
//
//    static let moods: [Mood] = [
//        Mood(imageName: "ExcitedImage", title: "Excited"),
//        Mood(imageName: "HappyImage", title: "Happy"),
//        Mood(imageName: "SadImage", title: "Sad"),
//        Mood(imageName: "TiredImage", title: "Tired"),
//        Mood(imageName: "AnxiousImage", title: "Anxious")
//    ]
//
//    static let quote = "My body and I are working together beautifully"
//
//    private static let fallbackBreathingImageName = "BreathingSessionsImage"
//    private static let journalingImageName = "Journal"
//    private static let hobbyImageName = "Cooking"
//
//    private static func preferredBreathingTitle(for moodKey: String) -> String {
//        switch moodKey.lowercased() {
//        case "happy": return "Inner Calm"
//        case "sad": return "Healing Reflections"
//        case "anxious": return "Calmer Mind"
//        case "tired": return "Gentle Recharge"
//        case "excited": return "Morning Appreciation"
//        default: return "Gentle Focus"
//        }
//    }
//
//    private static func breathingItem(for moodKey: String, from content: HomeMoodSuggestionContent) -> HomeMoodSuggestionItem? {
//        let preferred = preferredBreathingTitle(for: moodKey)
//        return content.breathing.first(where: { $0.title.caseInsensitiveCompare(preferred) == .orderedSame })
//            ?? content.breathing.first
//    }
//
//    // Take image from Breathing feature using breathing title
//    private static func breathingImageName(for breathingTitle: String) -> String {
//        let sessions = BreathingDataManager().getAllSessions()
//        if let match = sessions.first(where: { $0.title.caseInsensitiveCompare(breathingTitle) == .orderedSame }) {
//            return match.imageName
//        }
//        return fallbackBreathingImageName
//    }
//
//    // MARK: - Journal (separate cell)
//
//    static func initialJournalSuggestion(for moodKey: String) -> Suggestion {
//        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
//              let journaling = content.journaling.first else {
//            return fallbackJournalSuggestion
//        }
//
//        return Suggestion(
//            imageName: journalingImageName,
//            title: journaling.title,
//            subtitle: journaling.description
//        )
//    }
//
//    static func journalSuggestion(for moodKey: String) -> Suggestion {
//        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
//              let journaling = content.journaling.first else {
//            return fallbackJournalSuggestion
//        }
//
//        return Suggestion(
//            imageName: journalingImageName,
//            title: journaling.title,
//            subtitle: journaling.description
//        )
//    }
//
//    // MARK: - Suggested For You (only breathing + hobby)
//
//    static func initialSuggestion(for moodKey: String) -> [Suggestion] {
//        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
//            return fallbackSuggestedForYou
//        }
//
//        var output: [Suggestion] = []
//
//        if let breathing = breathingItem(for: moodKey, from: content) {
//            output.append(
//                Suggestion(
//                    imageName: breathingImageName(for: breathing.title),
//                    title: breathing.title,
//                    subtitle: breathing.description
//                )
//            )
//        }
//
//        if let hobby = content.hobby.first {
//            output.append(
//                Suggestion(
//                    imageName: hobbyImageName,
//                    title: hobby.title,
//                    subtitle: hobby.description
//                )
//            )
//        }
//
//        return output.isEmpty ? fallbackSuggestedForYou : output
//    }
//
//    static func suggestions(for moodKey: String) -> [Suggestion] {
//        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
//            return fallbackSuggestedForYou
//        }
//
//        var output: [Suggestion] = []
//
//        if let breathing = breathingItem(for: moodKey, from: content) {
//            output.append(
//                Suggestion(
//                    imageName: breathingImageName(for: breathing.title),
//                    title: breathing.title,
//                    subtitle: breathing.description
//                )
//            )
//        }
//
//        if let hobby = content.hobby.first {
//            output.append(
//                Suggestion(
//                    imageName: hobbyImageName,
//                    title: hobby.title,
//                    subtitle: hobby.description
//                )
//            )
//        }
//
//        return output.isEmpty ? fallbackSuggestedForYou : output
//    }
//
//    private static let fallbackJournalSuggestion = Suggestion(
//        imageName: "Journal",
//        title: "Write about someone who brings joy and why they matter.",
//        subtitle: "Start Writing..."
//    )
//
//    private static let fallbackSuggestedForYou: [Suggestion] = [
//        Suggestion(
//            imageName: "BreathingSessionsImage",
//            title: "Gentle Focus",
//            subtitle: "A soft breathing session to keep your energy steady."
//        ),
//        Suggestion(
//            imageName: "Cooking",
//            title: "Cooking",
//            subtitle: "Make a snack you love and enjoy the process."
//        )
//    ]
//
//    static let articles: [Article] = [
//        Article(
//            imageName: "article_image_1",
//            title: "Debunking Common Breast Cancer Myths",
//            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
//        ),
//        Article(
//            imageName: "article_image_2",
//            title: "Implications of Dense Breast Tissue",
//            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
//        )
//    ]
//}

import Foundation

class HomeModel {

    static let moods: [Mood] = [
        Mood(imageName: "ExcitedImage", title: "Excited"),
        Mood(imageName: "HappyImage", title: "Happy"),
        Mood(imageName: "SadImage", title: "Sad"),
        Mood(imageName: "TiredImage", title: "Tired"),
        Mood(imageName: "AnxiousImage", title: "Anxious")
    ]

    static let quote = "My body and I are working together beautifully"

    private static let fallbackBreathingImageName = "BreathingSessionsImage"
    private static let journalingImageName = "Journal"
    private static let hobbyImageName = "Cooking"

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

    private static func breathingItem(for moodKey: String, from content: HomeMoodSuggestionContent) -> HomeMoodSuggestionItem? {
        let preferred = preferredBreathingTitle(for: moodKey)
        return content.breathing.first(where: { $0.title.caseInsensitiveCompare(preferred) == .orderedSame })
            ?? content.breathing.first
    }

    private static func breathingImageName(for breathingTitle: String) -> String {
        let sessions = BreathingDataManager().getAllSessions()
        if let match = sessions.first(where: { $0.title.caseInsensitiveCompare(breathingTitle) == .orderedSame }) {
            return match.imageName
        }
        return fallbackBreathingImageName
    }

    private static func subtitle(for item: HomeMoodSuggestionItem, fallback: String) -> String {
        let value = item.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? fallback : value
    }

    // MARK: - Journal (separate cell)

    static func initialJournalSuggestion(for moodKey: String) -> Suggestion {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey),
              let journaling = content.journaling.first else {
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
              let journaling = content.journaling.first else {
            return fallbackJournalSuggestion
        }

        return Suggestion(
            imageName: journalingImageName,
            title: journaling.title,
            subtitle: subtitle(for: journaling, fallback: "Start Writing...")
        )
    }

    // MARK: - Suggested For You (only breathing + hobby)

    static func initialSuggestion(for moodKey: String) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return fallbackSuggestedForYou
        }

        var output: [Suggestion] = []

        if let breathing = breathingItem(for: moodKey, from: content) {
            output.append(
                Suggestion(
                    imageName: breathingImageName(for: breathing.title),
                    title: breathing.title,
                    subtitle: subtitle(for: breathing, fallback: "A soft breathing session to keep your energy steady.")
                )
            )
        }

        if let hobby = content.hobby.first {
            output.append(
                Suggestion(
                    imageName: hobbyImageName,
                    title: hobby.title,
                    subtitle: subtitle(for: hobby, fallback: "Enjoy this hobby at your own pace.")
                )
            )
        }

        return output.isEmpty ? fallbackSuggestedForYou : output
    }

    static func suggestions(for moodKey: String) -> [Suggestion] {
        guard let content = HomeMoodSuggestionLoader.shared.moodContent(for: moodKey) else {
            return fallbackSuggestedForYou
        }

        var output: [Suggestion] = []

        if let breathing = breathingItem(for: moodKey, from: content) {
            output.append(
                Suggestion(
                    imageName: breathingImageName(for: breathing.title),
                    title: breathing.title,
                    subtitle: subtitle(for: breathing, fallback: "A soft breathing session to keep your energy steady.")
                )
            )
        }

        if let hobby = content.hobby.first {
            output.append(
                Suggestion(
                    imageName: hobbyImageName,
                    title: hobby.title,
                    subtitle: subtitle(for: hobby, fallback: "Enjoy this hobby at your own pace.")
                )
            )
        }

        return output.isEmpty ? fallbackSuggestedForYou : output
    }

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
        )
    ]

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
