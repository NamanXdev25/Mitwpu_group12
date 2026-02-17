//
//  ExercisePlanCategoryModel.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/02/26.
//

import Foundation

struct ExercisePlanCategory {
    let id: Int
    let title: String
    let subtitle: String
    let importantNote: String
    let exercises: [CategoryExercise]
    let sourceURL: String?
    let imageName: String? // For future use
    let relatedPlan: NewExercisePlan? // For categories 4 & 5 that reference Level 1 & 2
}

struct CategoryExercise {
    let name: String
    let details: String
}

// MARK: - Sample Data
extension ExercisePlanCategory {
    
    static let allCategories: [ExercisePlanCategory] = [
        // 1. Before Chemotherapy
        ExercisePlanCategory(
            id: 1,
            title: "Before Chemotherapy",
            subtitle: "4–5 days/week · 20–30 min/session · Until chemotherapy begins",
            importantNote: "Build strength and stamina before treatment starts. Stop if dizziness, pain, or unusual fatigue occurs.",
            exercises: [
                CategoryExercise(name: "Brisk walking", details: "10–15 min"),
                CategoryExercise(name: "Sit-to-stand from chair", details: "2 sets × 10 reps"),
                CategoryExercise(name: "Wall push-ups", details: "2 sets × 8 reps"),
                CategoryExercise(name: "Neck side stretch", details: "2 min")
            ],
            sourceURL: "https://www.oncolink.org/cancers/breast/support-and-survivorship-for-breast-cancer/exercises-for-individuals-with-breast-cancer#exercise-before-treatment",
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 2. During Chemotherapy
        ExercisePlanCategory(
            id: 2,
            title: "During Chemotherapy",
            subtitle: "3–5 days/week (flexible) · 10–20 min/session · Entire chemotherapy period",
            importantNote: "Some movement is better than none. On very tired days, even 5 minutes counts.",
            exercises: [
                CategoryExercise(name: "Slow walking", details: "5–10 min"),
                CategoryExercise(name: "Seated knee extensions", details: "2 sets × 10 reps"),
                CategoryExercise(name: "Seated arm raises (no weight)", details: "2 sets × 8 reps"),
                CategoryExercise(name: "Deep diaphragmatic breathing", details: "3–5 min")
            ],
            sourceURL: "https://www.mskcc.org/cancer-care/patient-education/exercise-during-after-cancer-treatment-level-1",
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 3. Post-Chemo, Pre-Surgery
        ExercisePlanCategory(
            id: 3,
            title: "Post-Chemo, Pre-Surgery",
            subtitle: "4–5 days/week · 20–30 min/session · 1–3 weeks",
            importantNote: "Focus on restoring energy without stressing the body before surgery.",
            exercises: [
                CategoryExercise(name: "Walking (comfortable pace)", details: "15 min"),
                CategoryExercise(name: "Resistance band row", details: "2 sets × 8 reps"),
                CategoryExercise(name: "Standing heel raises", details: "2 sets × 10 reps"),
                CategoryExercise(name: "Chest opening stretch", details: "2 min")
            ],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 4. Early Post-Surgery (Week 1)
        ExercisePlanCategory(
            id: 4,
            title: "Early Post-Surgery (Week 1)",
            subtitle: "Level 1 exercises",
            importantNote: "Start the day after surgery and continue for 7 days unless your doctor says otherwise.",
            exercises: [],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: NewExercisePlan.level1Exercises
        ),
        
        // 5. Post-Surgery (Week 2)
        ExercisePlanCategory(
            id: 5,
            title: "Post-Surgery (Week 2)",
            subtitle: "Level 2 exercises",
            importantNote: "Continue building strength and mobility. Listen to your body.",
            exercises: [],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: NewExercisePlan.level2Exercises
        ),
        
        // 6. Post-Surgery Recovery (Week 3-6)
        ExercisePlanCategory(
            id: 6,
            title: "Post-Surgery Recovery",
            subtitle: "5–6 days/week · 15–25 min/session · 3–6 weeks\nMastectomy / Lumpectomy / BCS",
            importantNote: "Gradually improve shoulder movement. Watch for swelling, heaviness, or pain.",
            exercises: [
                CategoryExercise(name: "Wall climbing (arm walk)", details: "2 sets × 5 reps"),
                CategoryExercise(name: "Pendulum arm swing", details: "1–2 min"),
                CategoryExercise(name: "Shoulder blade squeeze", details: "2 sets × 8 reps"),
                CategoryExercise(name: "Walking", details: "10–15 min")
            ],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 7. After Breast Reconstruction
        ExercisePlanCategory(
            id: 7,
            title: "After Breast Reconstruction",
            subtitle: "4–5 days/week · 15–20 min/session · 4–8 weeks",
            importantNote: "Protect reconstructed tissue. Avoid chest loading and sudden arm movements.",
            exercises: [
                CategoryExercise(name: "Posture alignment against wall", details: "2 min"),
                CategoryExercise(name: "Neck rotation stretch", details: "2 min"),
                CategoryExercise(name: "Gentle shoulder abduction", details: "2 sets × 6 reps"),
                CategoryExercise(name: "Slow walking", details: "10 min")
            ],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 8. Pre-Radiation Therapy
        ExercisePlanCategory(
            id: 8,
            title: "Pre-Radiation Therapy",
            subtitle: "5–6 days/week · 10–20 min/session · 1–2 weeks",
            importantNote: "Good shoulder mobility helps with radiation positioning.",
            exercises: [
                CategoryExercise(name: "Shoulder flexion stretch", details: "2 sets × 5 reps"),
                CategoryExercise(name: "Arm circles (small range)", details: "2 sets × 6 reps"),
                CategoryExercise(name: "Resistance band pull-apart", details: "2 sets × 8 reps"),
                CategoryExercise(name: "Walking", details: "10 min")
            ],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 9. During & After Radiation Therapy
        ExercisePlanCategory(
            id: 9,
            title: "During & After Radiation Therapy",
            subtitle: "3–5 days/week · 15–25 min/session · Radiation period + 2–4 weeks",
            importantNote: "Fatigue and skin sensitivity are common. Reduce intensity if skin irritation increases.",
            exercises: [
                CategoryExercise(name: "Gentle yoga stretch", details: "5 min"),
                CategoryExercise(name: "Walking", details: "10–20 min"),
                CategoryExercise(name: "Shoulder side stretch", details: "2 sets × 5 reps"),
                CategoryExercise(name: "Deep breathing", details: "3–5 min")
            ],
            sourceURL: "https://www.cancercouncil.com.au/cancer-information/cancer-treatment/radiation-therapy/life-after-cancer-treatment/#after-treatment",
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 10. Post-Treatment Recovery
        ExercisePlanCategory(
            id: 10,
            title: "Post-Treatment Recovery",
            subtitle: "4–6 days/week · 20–40 min/session · 3–6 months",
            importantNote: "Gradually rebuild strength and endurance. Progress slowly.",
            exercises: [
                CategoryExercise(name: "Brisk walking", details: "20 min"),
                CategoryExercise(name: "Bodyweight squats", details: "2 sets × 10 reps"),
                CategoryExercise(name: "Resistance band rows", details: "2 sets × 10 reps"),
                CategoryExercise(name: "Seated core engagement", details: "2 sets × 10 reps")
            ],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: nil
        ),
        
        // 11. Remission / Survivorship
        ExercisePlanCategory(
            id: 11,
            title: "Remission / Survivorship",
            subtitle: "30 min/day · 5 days/week + strength 2–3 days/week · Long-term",
            importantNote: "Regular exercise supports long-term health and reduces recurrence risk.",
            exercises: [
                CategoryExercise(name: "Moderate-intensity cardio", details: "30 min"),
                CategoryExercise(name: "Strength training session", details: "20–30 min"),
                CategoryExercise(name: "Flexibility stretching", details: "5–10 min"),
                CategoryExercise(name: "Balance exercise (single-leg stand)", details: "5 min")
            ],
            sourceURL: nil,
            imageName: nil,
            relatedPlan: nil
        )
    ]
    
    // Section groupings - CORRECTED: Changed from 'let' to 'var'
    static var postSurgeryCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 4 || $0.id == 5 }
    }
    
    static var postRecoveryCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 6 }
    }
    
    static var chemotherapyCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 1 || $0.id == 2 || $0.id == 3 }
    }
    
    static var radiationCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 8 || $0.id == 9 }
    }
    
    static var reconstructionCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 7 }
    }
    
    static var recoveryCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 10 || $0.id == 11 }
    }
}
