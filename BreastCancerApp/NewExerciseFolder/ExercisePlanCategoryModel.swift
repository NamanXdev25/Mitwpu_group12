//
//  ExercisePlanCategoryModel.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/02/26.
//

import Foundation

// MARK: - Sample Data
extension ExercisePlanCategory {

    static let allCategories: [ExercisePlanCategory] = [

        // MARK: 1. Before Chemotherapy
        ExercisePlanCategory(
            id: 1,
            title: "Before Chemotherapy",
            subtitle: "20–30 min · 4–5 days/week",
            importantNote: "Build strength and stamina before treatment starts. Stop if dizziness, pain, or unusual fatigue occurs.",
            exercises: [
                CategoryExercise(name: "Sit-to-Stand",           details: "2 × 10", imageName: "girl_stretch"),
                CategoryExercise(name: "Resistance Band Row",    details: "2 × 8",  imageName: "arm_lift"),
                CategoryExercise(name: "Bodyweight Mini Squat",  details: "2 × 8",  imageName: "girl_stretch"),
                CategoryExercise(name: "Shoulder Blade Squeeze", details: "2 × 8",  imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Chest Opening Stretch",  details: "2 min",  imageName: "chest_open"),
                CategoryExercise(name: "Diaphragmatic Breathing",details: "3 min",  imageName: "girl_stretch"),
            ],
            imageName: "chest_open"
        ),

        // MARK: 2. During Chemotherapy
        ExercisePlanCategory(
            id: 2,
            title: "During Chemotherapy",
            subtitle: "10–20 min · Flexible",
            importantNote: "Some movement is better than none. On very tired days, even 5 minutes counts.",
            exercises: [
                CategoryExercise(name: "Seated Knee Extension",  details: "2 × 10",  imageName: "girl_stretch"),
                CategoryExercise(name: "Sit-to-Stand",           details: "1–2 × 8", imageName: "girl_stretch"),
                CategoryExercise(name: "Shoulder Shrug",         details: "1 × 10",  imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Shoulder Roll",          details: "1 × 10",  imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Seated Cat–Cow",         details: "2 min",   imageName: "girl_stretch"),
                CategoryExercise(name: "Diaphragmatic Breathing",details: "5 min",   imageName: "girl_stretch"),
            ],
            imageName: "arm_lift"
        ),

        // MARK: 3. Post-Chemo, Pre-Surgery
        ExercisePlanCategory(
            id: 3,
            title: "Post-Chemo, Pre-Surgery",
            subtitle: "20–25 min",
            importantNote: "Focus on restoring energy without stressing the body before surgery.",
            exercises: [
                CategoryExercise(name: "Resistance Band Row",    details: "2 × 8",  imageName: "arm_lift"),
                CategoryExercise(name: "Bodyweight Mini Squat",  details: "2 × 8",  imageName: "girl_stretch"),
                CategoryExercise(name: "Standing Heel Raises",   details: "2 × 10", imageName: "standing_heel_raises"),
                CategoryExercise(name: "Shoulder Blade Squeeze", details: "2 × 10", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Neck Side Stretch",      details: "2 min",  imageName: "girl_stretch"),
                CategoryExercise(name: "Diaphragmatic Breathing",details: "3 min",  imageName: "girl_stretch"),
            ],
            imageName: "standing_heel_raises"
        ),

        // MARK: 4. Early Post-Surgery (Week 1)
        ExercisePlanCategory(
            id: 4,
            title: "Early Post-Surgery (Week 1)",
            subtitle: "10–15 min · Daily",
            importantNote: "Start the day after surgery and continue for 7 days unless your doctor says otherwise.",
            exercises: [
                CategoryExercise(name: "Shoulder Shrug",         details: "1 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Shoulder Roll",          details: "1 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Wrist Circles",          details: "1 min", imageName: "girl_stretch"),
                CategoryExercise(name: "Elbow Flex & Extend",    details: "1 min", imageName: "arm_lift"),
                CategoryExercise(name: "Shoulder Blade Squeeze", details: "2 min", imageName: "shoulder_blade_squeeze"),
            ],
            imageName: "shoulder_blade_squeeze"
        ),

        // MARK: 5. Post-Surgery (Week 2)
        ExercisePlanCategory(
            id: 5,
            title: "Post-Surgery (Week 2)",
            subtitle: "15–20 min",
            importantNote: "Continue building strength and mobility. Listen to your body.",
            exercises: [
                CategoryExercise(name: "Pendulum Arm Swing",        details: "2 min", imageName: "girl_stretch"),
                CategoryExercise(name: "Wall Crawl (Front)",        details: "2 × 5", imageName: "wall_climbing"),
                CategoryExercise(name: "Wall Crawl (Side)",         details: "2 × 5", imageName: "wall_climbing"),
                CategoryExercise(name: "Shoulder Blade Squeeze",    details: "2 × 8", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Gentle Shoulder Abduction", details: "2 × 6", imageName: "arm_lift"),
            ],
            imageName: "wall_climbing"
        ),

        // MARK: 6. Post-Surgery Recovery (Week 3–6)
        ExercisePlanCategory(
            id: 6,
            title: "Post-Surgery Recovery (Week 3–6)",
            subtitle: "20–25 min",
            importantNote: "Gradually improve shoulder movement. Watch for swelling, heaviness, or pain.",
            exercises: [
                CategoryExercise(name: "Wall Crawl (Front)",    details: "2 × 8",  imageName: "wall_climbing"),
                CategoryExercise(name: "Wall Crawl (Side)",     details: "2 × 8",  imageName: "wall_climbing"),
                CategoryExercise(name: "Resistance Band Row",   details: "2 × 8",  imageName: "arm_lift"),
                CategoryExercise(name: "Sit-to-Stand",          details: "2 × 10", imageName: "girl_stretch"),
                CategoryExercise(name: "Standing Heel Raises",  details: "2 × 10", imageName: "standing_heel_raises"),
                CategoryExercise(name: "Chest Opening Stretch", details: "2 min",  imageName: "chest_open"),
            ],
            imageName: "wall_climbing"
        ),

        // MARK: 7. After Breast Reconstruction
        ExercisePlanCategory(
            id: 7,
            title: "After Breast Reconstruction",
            subtitle: "15–20 min",
            importantNote: "Protect reconstructed tissue. Avoid chest loading and sudden arm movements.",
            exercises: [
                CategoryExercise(name: "Shoulder Shrug",            details: "1 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Shoulder Roll",             details: "1 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Gentle Shoulder Abduction", details: "2 × 6", imageName: "arm_lift"),
                CategoryExercise(name: "Chest Opening Stretch",     details: "2 min", imageName: "chest_open"),
                CategoryExercise(name: "Diaphragmatic Breathing",   details: "3 min", imageName: "girl_stretch"),
            ],
            imageName: "chest_open"
        ),

        // MARK: 8. Pre-Radiation Therapy
        ExercisePlanCategory(
            id: 8,
            title: "Pre-Radiation Therapy",
            subtitle: "15–20 min",
            importantNote: "Good shoulder mobility helps with radiation positioning.",
            exercises: [
                CategoryExercise(name: "Wall Crawl (Front)",     details: "2 × 6",  imageName: "wall_climbing"),
                CategoryExercise(name: "Wall Crawl (Side)",      details: "2 × 6",  imageName: "wall_climbing"),
                CategoryExercise(name: "Shoulder Blade Squeeze", details: "2 × 10", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Chest Opening Stretch",  details: "2 min",  imageName: "chest_open"),
                CategoryExercise(name: "Seated Cat–Cow",         details: "2 min",  imageName: "girl_stretch"),
            ],
            imageName: "wall_climbing"
        ),

        // MARK: 9. During & After Radiation Therapy
        ExercisePlanCategory(
            id: 9,
            title: "During & After Radiation",
            subtitle: "15–20 min",
            importantNote: "Fatigue and skin sensitivity are common. Reduce intensity if skin irritation increases.",
            exercises: [
                CategoryExercise(name: "Shoulder Shrug",          details: "1 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Shoulder Roll",           details: "1 min", imageName: "shoulder_blade_squeeze"),
                CategoryExercise(name: "Resistance Band Row",     details: "2 × 8", imageName: "arm_lift"),
                CategoryExercise(name: "Bodyweight Mini Squat",   details: "2 × 8", imageName: "girl_stretch"),
                CategoryExercise(name: "Diaphragmatic Breathing", details: "3 min", imageName: "girl_stretch"),
            ],
            imageName: "girl_stretch"
        ),

        // MARK: 10. Post-Treatment Recovery
        ExercisePlanCategory(
            id: 10,
            title: "Post-Treatment Recovery",
            subtitle: "25–30 min · 4–5 days/week",
            importantNote: "Gradually rebuild strength and endurance. Progress slowly.",
            exercises: [
                CategoryExercise(name: "Sit-to-Stand",          details: "2 × 12",     imageName: "girl_stretch"),
                CategoryExercise(name: "Resistance Band Row",   details: "2 × 12",     imageName: "arm_lift"),
                CategoryExercise(name: "Bodyweight Mini Squat", details: "2 × 10",     imageName: "girl_stretch"),
                CategoryExercise(name: "Wall Push-Up",          details: "2 × 8",      imageName: "girl_stretch"),
                CategoryExercise(name: "Single Leg Stand",      details: "3 × 20 sec", imageName: "standing_heel_raises"),
                CategoryExercise(name: "Chest Opening Stretch", details: "2 min",      imageName: "chest_open"),
            ],
            imageName: "shoulder_blade_squeeze"
        ),

        // MARK: 11. Remission / Survivorship
        ExercisePlanCategory(
            id: 11,
            title: "Remission / Survivorship",
            subtitle: "30 min · 5 days/week",
            importantNote: "Regular exercise supports long-term health and reduces recurrence risk.",
            exercises: [
                CategoryExercise(name: "Bodyweight Mini Squat", details: "3 × 12",     imageName: "girl_stretch"),
                CategoryExercise(name: "Resistance Band Row",   details: "3 × 12",     imageName: "arm_lift"),
                CategoryExercise(name: "Wall Push-Up",          details: "3 × 10",     imageName: "girl_stretch"),
                CategoryExercise(name: "Standing Heel Raises",  details: "3 × 15",     imageName: "standing_heel_raises"),
                CategoryExercise(name: "Single Leg Stand",      details: "3 × 30 sec", imageName: "standing_heel_raises"),
                CategoryExercise(name: "Tandem Stand",          details: "3 × 30 sec", imageName: "girl_stretch"),
                CategoryExercise(name: "Seated Cat–Cow",        details: "3 min",      imageName: "girl_stretch"),
            ],
            imageName: "posture_alignment_against_wall"
        ),
    ]

    // MARK: - Section Groupings (unchanged)

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
