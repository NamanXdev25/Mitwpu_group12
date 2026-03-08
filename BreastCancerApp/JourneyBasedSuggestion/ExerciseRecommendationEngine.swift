//
//  ExerciseRecommendationEngine.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/03/26.
//

// Returns the most relevant exercise plan categories based on current treatment context.

import Foundation

struct ExerciseRecommendationEngine {

    // Returns up to 2 recommended categories. Returns empty if no clear match.
    static func recommendedCategories() -> [ExercisePlanCategory] {
        let ctx = AppContext.current(moodKey: "general")
        let scored = ExercisePlanCategory.allCategories.map { ($0, score($0, ctx: ctx)) }
        return scored
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(2)
            .map { $0.0 }
    }

    // treatment type → relevant plan IDs
    private static func score(_ plan: ExercisePlanCategory, ctx: AppContext) -> Int {
        let type = ctx.effectiveTreatmentType

        // No recommendations until a treatment type is known
        guard type != "general" && type != "earlyDiagnosis" else { return 0 }

        switch type {
        case "chemotherapy":
            // Plans 1, 2 during/before chemo; 10, 11 for recovery
            return [1, 2, 10, 11].contains(plan.id) ? 1 : 0

        case "surgery":
            // All surgery plans + reconstruction + recovery
            return [3, 4, 5, 6, 7, 10, 11].contains(plan.id) ? 1 : 0

        case "radiation":
            // Pre and during/after radiation + recovery
            return [8, 9, 10, 11].contains(plan.id) ? 1 : 0

        case "hormone", "immunotherapy", "targeted", "stemcell":
            // No dedicated plans — show generic recovery plans
            return [10, 11].contains(plan.id) ? 1 : 0

        default:
            return 0
        }
    }
}
