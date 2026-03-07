//
//  ExercisePlanCategoryModel.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/02/26.
//

import Foundation

// MARK: - Exercise Image Mapping
private func imageForExercise(_ name: String) -> String {
    let lower = name.lowercased()
    if lower.contains("wall climb") || lower.contains("wall crawl") || lower.contains("wall walk") {
        return "wall_climbing"
    } else if lower.contains("heel raise") {
        return "standing_heel_raises"
    } else if lower.contains("shoulder blade") || lower.contains("scapular") || lower.contains("shoulder roll") {
        return "shoulder_blade_squeeze"
    } else if lower.contains("posture alignment") {
        return "posture_alignment_against_wall"
    } else if lower.contains("chest open") || lower.contains("chest-open") || lower.contains("corner stretch") {
        return "chest_open"
    } else if lower.contains("arm raise") || lower.contains("arm lift") || lower.contains("arm stretch") ||
              lower.contains("shoulder abduction") || lower.contains("shoulder flexion") ||
              lower.contains("arm circle") || lower.contains("elbow") || lower.contains("resistance band") ||
              lower.contains("band pull") {
        return "arm_lift"
    } else {
        return "girl_stretch"
    }
}

// MARK: - Sample Data
extension ExercisePlanCategory {

    static let allCategories: [ExercisePlanCategory] = [

        // 1. Before Chemotherapy
        ExercisePlanCategory(
            id: 1,
            title: "Before Chemotherapy",
            subtitle: "30 min · Pre-chemo",
            importantNote: "Build strength and stamina before treatment starts. Stop if dizziness, pain, or unusual fatigue occurs.",
            exercises: [
                CategoryExercise(name: "Brisk walking", details: "10–15 min", imageName: "standing_heel_raises"),
                CategoryExercise(name: "Sit-to-stand from chair", details: "2 sets × 10 reps", imageName: imageForExercise("Sit-to-stand from chair")),
                CategoryExercise(name: "Wall push-ups", details: "2 sets × 8 reps", imageName: imageForExercise("Wall push-ups")),
                CategoryExercise(name: "Neck side stretch", details: "2 min", imageName: imageForExercise("Neck side stretch"))
            ],
            imageName: "standing_heel_raises"
        ),

        // 2. During Chemotherapy
        ExercisePlanCategory(
            id: 2,
            title: "During Chemotherapy",
            subtitle: "20 min · During chemo",
            importantNote: "Some movement is better than none. On very tired days, even 5 minutes counts.",
            exercises: [
                CategoryExercise(name: "Slow walking", details: "5-10 min", imageName: "arm_lift"),
                CategoryExercise(name: "Seated knee extensions", details: "2 sets × 10 reps", imageName: imageForExercise("Seated knee extensions")),
                CategoryExercise(name: "Seated arm raises (no weight)", details: "2 sets × 8 reps", imageName: imageForExercise("Seated arm raises (no weight)")),
                CategoryExercise(name: "Deep diaphragmatic breathing", details: "3–5 min", imageName: imageForExercise("Deep diaphragmatic breathing"))
            ],
            imageName: "arm_lift"
        ),

        // 3. Post-Chemo, Pre-Surgery
        ExercisePlanCategory(
            id: 3,
            title: "Post-Chemo",
            subtitle: "20 min · 1–3 weeks",
            importantNote: "Focus on restoring energy without stressing the body before surgery.",
            exercises: [
                CategoryExercise(name: "Walking (comfortable pace)", details: "15 min", imageName: "chest_open"),
                CategoryExercise(name: "Resistance band row", details: "2 sets × 8 reps", imageName: imageForExercise("Resistance band row")),
                CategoryExercise(name: "Standing heel raises", details: "2 sets × 10 reps", imageName: imageForExercise("Standing heel raises")),
                CategoryExercise(name: "Chest opening stretch", details: "2 min", imageName: imageForExercise("Chest opening stretch"))
            ],
            imageName: "chest_open"
        ),

        // 4. Early Post-Surgery (Week 1) — Level 1 data inline
        ExercisePlanCategory(
            id: 4,
            title: "Early Post-Surgery (Week 1)",
            subtitle: "15 min · Week 1",
            importantNote: "Start the day after surgery and continue for 7 days unless your doctor says otherwise.",
            exercises: [
                CategoryExercise(name: "Wall Climb Stretch", details: "1 min", imageName: "wall_climbing"),
                CategoryExercise(name: "Shoulder Rolls", details: "1 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Chest-Opening Breaths", details: "1 min", imageName: "chest_open"),
                CategoryExercise(name: "Corner Stretch", details: "2 min", imageName: "girl_stretch"),
                CategoryExercise(name: "Scapular Retractions", details: "2 min", imageName: "shoulder_blade_squeeze")
            ],
            imageName: "wall_climbing"
        ),

        // 5. Post-Surgery (Week 2) — Level 2 data inline
        ExercisePlanCategory(
            id: 5,
            title: "Post-Surgery (Week 2)",
            subtitle: "15 min · Week 2",
            importantNote: "Continue building strength and mobility. Listen to your body.",
            exercises: [
                CategoryExercise(name: "Arm Stretch", details: "1 min", imageName: "arm_lift"),
                CategoryExercise(name: "Elbows Together", details: "2 min", imageName: "posture_alignment_against_wall"),
                CategoryExercise(name: "Elbows Push Back", details: "2 min", imageName: "chest_open"),
                CategoryExercise(name: "Arm Lift", details: "3 min", imageName: "arm_lift"),
                CategoryExercise(name: "Wall Crawl", details: "3 min", imageName: "wall_climbing")
            ],
            imageName: "arm_lift"
        ),

        // 6. Post-Surgery Recovery (Week 3-6)
        ExercisePlanCategory(
            id: 6,
            title: "Post-Surgery Recovery",
            subtitle: "25 min · 3-6 Weeks",
            importantNote: "Gradually improve shoulder movement. Watch for swelling, heaviness, or pain.",
            exercises: [
                CategoryExercise(name: "Wall climbing (arm walk)", details: "2 sets × 5 reps", imageName: "wall_climbing"),
                CategoryExercise(name: "Pendulum arm swing", details: "1–2 min", imageName: imageForExercise("Pendulum arm swing")),
                CategoryExercise(name: "Shoulder blade squeeze", details: "2 sets × 8 reps", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Walking", details: "10–15 min", imageName: imageForExercise("Walking"))
            ],
            imageName: nil
        ),

        // 7. After Breast Reconstruction
        ExercisePlanCategory(
            id: 7,
            title: "After Breast Reconstruction",
            subtitle: "20 min · 4-8 Weeks",
            importantNote: "Protect reconstructed tissue. Avoid chest loading and sudden arm movements.",
            exercises: [
                CategoryExercise(name: "Posture alignment against wall", details: "2 min", imageName: "posture_alignment_against_wall"),
                CategoryExercise(name: "Neck rotation stretch", details: "2 min", imageName: imageForExercise("Neck rotation stretch")),
                CategoryExercise(name: "Gentle shoulder abduction", details: "2 sets × 6 reps", imageName: imageForExercise("Gentle shoulder abduction")),
                CategoryExercise(name: "Slow walking", details: "10 min", imageName: imageForExercise("Slow walking"))
            ],
            imageName: nil
        ),

        // 8. Pre-Radiation Therapy
        ExercisePlanCategory(
            id: 8,
            title: "Pre-Radiation Therapy",
            subtitle: "20 min · 1–2 weeks",
            importantNote: "Good shoulder mobility helps with radiation positioning.",
            exercises: [
                CategoryExercise(name: "Shoulder flexion stretch", details: "2 sets × 5 reps", imageName: imageForExercise("Shoulder flexion stretch")),
                CategoryExercise(name: "Arm circles (small range)", details: "2 sets × 6 reps", imageName: imageForExercise("Arm circles (small range)")),
                CategoryExercise(name: "Resistance band pull-apart", details: "2 sets × 8 reps", imageName: imageForExercise("Resistance band pull-apart")),
                CategoryExercise(name: "Walking", details: "10 min", imageName: imageForExercise("Walking"))
            ],
            imageName: nil
        ),

        // 9. During & After Radiation Therapy
        ExercisePlanCategory(
            id: 9,
            title: "During & After Radiation",
            subtitle: "15–25 min",
            importantNote: "Fatigue and skin sensitivity are common. Reduce intensity if skin irritation increases.",
            exercises: [
                CategoryExercise(name: "Gentle yoga stretch", details: "5 min", imageName: "girl_stretch"),
                CategoryExercise(name: "Walking", details: "10–20 min", imageName: imageForExercise("Walking")),
                CategoryExercise(name: "Shoulder side stretch", details: "2 sets × 5 reps", imageName: imageForExercise("Shoulder side stretch")),
                CategoryExercise(name: "Deep breathing", details: "3–5 min", imageName: imageForExercise("Deep breathing"))
            ],
            imageName: "girl_stretch"
        ),

        // 10. Post-Treatment Recovery
        ExercisePlanCategory(
            id: 10,
            title: "Post-Treatment Recovery",
            subtitle: "30 min · 3–6 months",
            importantNote: "Gradually rebuild strength and endurance. Progress slowly.",
            exercises: [
                CategoryExercise(name: "Brisk walking", details: "20 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Bodyweight squats", details: "2 sets × 10 reps", imageName: imageForExercise("Bodyweight squats")),
                CategoryExercise(name: "Resistance band rows", details: "2 sets × 10 reps", imageName: imageForExercise("Resistance band rows")),
                CategoryExercise(name: "Seated core engagement", details: "2 sets × 10 reps", imageName: imageForExercise("Seated core engagement"))
            ],
            imageName: "shoulder_blade_squeeze"
        ),

        // 11. Remission / Survivorship
        ExercisePlanCategory(
            id: 11,
            title: "Remission / Survivorship",
            subtitle: "30 min · Long-term",
            importantNote: "Regular exercise supports long-term health and reduces recurrence risk.",
            exercises: [
                CategoryExercise(name: "Moderate-intensity cardio", details: "30 min", imageName: "posture_alignment_against_wall"),
                CategoryExercise(name: "Strength training session", details: "20–30 min", imageName: imageForExercise("Strength training session")),
                CategoryExercise(name: "Flexibility stretching", details: "5–10 min", imageName: imageForExercise("Flexibility stretching")),
                CategoryExercise(name: "Balance exercise (single-leg stand)", details: "5 min", imageName: imageForExercise("Balance exercise (single-leg stand)"))
            ],
            imageName: "posture_alignment_against_wall"
        )
    ]

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
