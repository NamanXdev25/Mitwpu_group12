

import Foundation

struct ExerciseRecommendationEngine {

    static func recommendedCategories() -> [ExercisePlanCategory] {
        let ctx = AppContext.current(moodKey: "general")
        let scored = ExercisePlanCategory.allCategories.map { ($0, score($0, ctx: ctx)) }
        return scored
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(2)
            .map { $0.0 }
    }

    private static func score(_ plan: ExercisePlanCategory, ctx: AppContext) -> Int {
        let type = ctx.effectiveTreatmentType

        guard type != "general" && type != "earlyDiagnosis" else { return 0 }

        switch type {
        case "chemotherapy":
            return [1, 2, 10, 11].contains(plan.id) ? 1 : 0

        case "surgery":
            return [3, 4, 5, 6, 7, 10, 11].contains(plan.id) ? 1 : 0

        case "radiation":
            return [8, 9, 10, 11].contains(plan.id) ? 1 : 0

        case "hormone", "immunotherapy", "targeted", "stemcell":
            return [10, 11].contains(plan.id) ? 1 : 0

        default:
            return 0
        }
    }
}
