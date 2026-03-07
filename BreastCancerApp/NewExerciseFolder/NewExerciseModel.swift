//
//  NewExerciseModel.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 04/02/26.
//

import Foundation

// MARK: - Sample Data
extension NewExercisePlan {

    // MARK: Before Chemotherapy — 20–30 min | 4–5 days/week
    static let beforeChemotherapy = NewExercisePlan(
        level: "Before Chemotherapy",
        duration: "20–30 min",
        exerciseCount: 6,
        note: "Note: Perform 4–5 days per week. Build strength and stamina before treatment starts. Stop if dizziness, pain, or unusual fatigue occurs.",
        exercises: [
            NewExerciseModel(imageName: "girl_stretch",           title: "Sit-to-Stand",           category: "Light Strength", difficulty: "Low", duration: "2 × 10"),
            NewExerciseModel(imageName: "arm_lift",               title: "Resistance Band Row",     category: "Light Strength", difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Bodyweight Mini Squat",   category: "Light Strength", difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Blade Squeeze",  category: "Mobility",       difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "chest_open",             title: "Chest Opening Stretch",   category: "Mobility",       difficulty: "Low", duration: "2 min"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Diaphragmatic Breathing", category: "Mobility",       difficulty: "Low", duration: "3 min"),
        ]
    )

    // MARK: During Chemotherapy — 10–20 min | Flexible
    static let duringChemotherapy = NewExercisePlan(
        level: "During Chemotherapy",
        duration: "10–20 min",
        exerciseCount: 6,
        note: "Note: Some movement is better than none. On very tired days, even 5 minutes counts.",
        exercises: [
            NewExerciseModel(imageName: "girl_stretch",           title: "Seated Knee Extension",   category: "Light Strength", difficulty: "Low", duration: "2 × 10"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Sit-to-Stand",            category: "Light Strength", difficulty: "Low", duration: "1–2 × 8"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Shrug",          category: "Mobility",       difficulty: "Low", duration: "1 × 10"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Roll",           category: "Mobility",       difficulty: "Low", duration: "1 × 10"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Seated Cat–Cow",          category: "Gentle Yoga",    difficulty: "Low", duration: "2 min"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Diaphragmatic Breathing", category: "Mobility",       difficulty: "Low", duration: "5 min"),
        ]
    )

    // MARK: Post-Chemo, Pre-Surgery — 20–25 min
    static let postChemoPreSurgery = NewExercisePlan(
        level: "Post-Chemo, Pre-Surgery",
        duration: "20–25 min",
        exerciseCount: 6,
        note: "Note: Focus on restoring energy without stressing the body before surgery.",
        exercises: [
            NewExerciseModel(imageName: "arm_lift",               title: "Resistance Band Row",     category: "Light Strength", difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Bodyweight Mini Squat",   category: "Light Strength", difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "standing_heel_raises",   title: "Standing Heel Raises",    category: "Light Strength", difficulty: "Low", duration: "2 × 10"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Blade Squeeze",  category: "Mobility",       difficulty: "Low", duration: "2 × 10"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Neck Side Stretch",       category: "Mobility",       difficulty: "Low", duration: "2 min"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Diaphragmatic Breathing", category: "Mobility",       difficulty: "Low", duration: "3 min"),
        ]
    )

    // MARK: Early Post-Surgery (Week 1) — 10–15 min daily
    static let level1Exercises = NewExercisePlan(
        level: "Early Post-Surgery (Week 1)",
        duration: "10–15 min",
        exerciseCount: 5,
        note: "Note: Start the day after surgery and continue for 7 days unless your doctor says otherwise.",
        exercises: [
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Shrug",         category: "Mobility", difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Roll",          category: "Mobility", difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Wrist Circles",          category: "Mobility", difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "arm_lift",               title: "Elbow Flex & Extend",    category: "Mobility", difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Blade Squeeze", category: "Mobility", difficulty: "Low", duration: "2 min"),
        ]
    )

    // MARK: Post-Surgery (Week 2) — 15–20 min
    static let level2Exercises = NewExercisePlan(
        level: "Post-Surgery (Week 2)",
        duration: "15–20 min",
        exerciseCount: 5,
        note: nil,
        exercises: [
            NewExerciseModel(imageName: "girl_stretch",           title: "Pendulum Arm Swing",         category: "Mobility", difficulty: "Low",    duration: "2 min"),
            NewExerciseModel(imageName: "wall_climbing",          title: "Wall Crawl (Front)",         category: "Mobility", difficulty: "Low",    duration: "2 × 5"),
            NewExerciseModel(imageName: "wall_climbing",          title: "Wall Crawl (Side)",          category: "Mobility", difficulty: "Low",    duration: "2 × 5"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Blade Squeeze",     category: "Mobility", difficulty: "Low",    duration: "2 × 8"),
            NewExerciseModel(imageName: "arm_lift",               title: "Gentle Shoulder Abduction",  category: "Mobility", difficulty: "Medium", duration: "2 × 6"),
        ]
    )

    // MARK: Post-Surgery Recovery (Week 3–6) — 20–25 min
    static let postSurgeryRecovery = NewExercisePlan(
        level: "Post-Surgery Recovery (Week 3–6)",
        duration: "20–25 min",
        exerciseCount: 6,
        note: "Note: Gradually improve shoulder movement. Watch for swelling, heaviness, or pain.",
        exercises: [
            NewExerciseModel(imageName: "wall_climbing",        title: "Wall Crawl (Front)",    category: "Mobility",       difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "wall_climbing",        title: "Wall Crawl (Side)",     category: "Mobility",       difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "arm_lift",             title: "Resistance Band Row",   category: "Light Strength", difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "girl_stretch",         title: "Sit-to-Stand",          category: "Light Strength", difficulty: "Low", duration: "2 × 10"),
            NewExerciseModel(imageName: "standing_heel_raises", title: "Standing Heel Raises",  category: "Light Strength", difficulty: "Low", duration: "2 × 10"),
            NewExerciseModel(imageName: "chest_open",           title: "Chest Opening Stretch", category: "Mobility",       difficulty: "Low", duration: "2 min"),
        ]
    )

    // MARK: After Breast Reconstruction — 15–20 min
    static let afterBreastReconstruction = NewExercisePlan(
        level: "After Breast Reconstruction",
        duration: "15–20 min",
        exerciseCount: 5,
        note: "Note: Protect reconstructed tissue. Avoid chest loading and sudden arm movements.",
        exercises: [
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Shrug",            category: "Mobility", difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Roll",             category: "Mobility", difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "arm_lift",               title: "Gentle Shoulder Abduction", category: "Mobility", difficulty: "Low", duration: "2 × 6"),
            NewExerciseModel(imageName: "chest_open",             title: "Chest Opening Stretch",     category: "Mobility", difficulty: "Low", duration: "2 min"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Diaphragmatic Breathing",   category: "Mobility", difficulty: "Low", duration: "3 min"),
        ]
    )

    // MARK: Pre-Radiation Therapy — 15–20 min
    static let preRadiationTherapy = NewExercisePlan(
        level: "Pre-Radiation Therapy",
        duration: "15–20 min",
        exerciseCount: 5,
        note: "Note: Good shoulder mobility helps with radiation positioning.",
        exercises: [
            NewExerciseModel(imageName: "wall_climbing",          title: "Wall Crawl (Front)",     category: "Mobility",    difficulty: "Low", duration: "2 × 6"),
            NewExerciseModel(imageName: "wall_climbing",          title: "Wall Crawl (Side)",      category: "Mobility",    difficulty: "Low", duration: "2 × 6"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Blade Squeeze", category: "Mobility",    difficulty: "Low", duration: "2 × 10"),
            NewExerciseModel(imageName: "chest_open",             title: "Chest Opening Stretch",  category: "Mobility",    difficulty: "Low", duration: "2 min"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Seated Cat–Cow",         category: "Gentle Yoga", difficulty: "Low", duration: "2 min"),
        ]
    )

    // MARK: During & After Radiation Therapy — 15–20 min
    static let duringAfterRadiation = NewExercisePlan(
        level: "During & After Radiation Therapy",
        duration: "15–20 min",
        exerciseCount: 5,
        note: "Note: Fatigue and skin sensitivity are common. Reduce intensity if skin irritation increases.",
        exercises: [
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Shrug",          category: "Mobility",       difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "shoulder_blade_squeeze", title: "Shoulder Roll",           category: "Mobility",       difficulty: "Low", duration: "1 min"),
            NewExerciseModel(imageName: "arm_lift",               title: "Resistance Band Row",     category: "Light Strength", difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Bodyweight Mini Squat",   category: "Light Strength", difficulty: "Low", duration: "2 × 8"),
            NewExerciseModel(imageName: "girl_stretch",           title: "Diaphragmatic Breathing", category: "Mobility",       difficulty: "Low", duration: "3 min"),
        ]
    )

    // MARK: Post-Treatment Recovery — 25–30 min | 4–5 days/week
    static let postTreatmentRecovery = NewExercisePlan(
        level: "Post-Treatment Recovery",
        duration: "25–30 min",
        exerciseCount: 6,
        note: "Note: Perform 4–5 days per week. Gradually rebuild strength and endurance. Progress slowly.",
        exercises: [
            NewExerciseModel(imageName: "girl_stretch",         title: "Sit-to-Stand",          category: "Light Strength", difficulty: "Medium", duration: "2 × 12"),
            NewExerciseModel(imageName: "arm_lift",             title: "Resistance Band Row",   category: "Light Strength", difficulty: "Medium", duration: "2 × 12"),
            NewExerciseModel(imageName: "girl_stretch",         title: "Bodyweight Mini Squat", category: "Light Strength", difficulty: "Medium", duration: "2 × 10"),
            NewExerciseModel(imageName: "girl_stretch",         title: "Wall Push-Up",          category: "Light Strength", difficulty: "Medium", duration: "2 × 8"),
            NewExerciseModel(imageName: "standing_heel_raises", title: "Single Leg Stand",      category: "Balance",        difficulty: "Medium", duration: "3 × 20 sec"),
            NewExerciseModel(imageName: "chest_open",           title: "Chest Opening Stretch", category: "Mobility",       difficulty: "Low",    duration: "2 min"),
        ]
    )

    // MARK: Remission / Survivorship — 30 min | 5 days/week
    static let remissionSurvivorship = NewExercisePlan(
        level: "Remission / Survivorship",
        duration: "30 min",
        exerciseCount: 7,
        note: "Note: Perform 5 days per week. Regular exercise supports long-term health and reduces recurrence risk.",
        exercises: [
            NewExerciseModel(imageName: "girl_stretch",         title: "Bodyweight Mini Squat", category: "Light Strength", difficulty: "Medium", duration: "3 × 12"),
            NewExerciseModel(imageName: "arm_lift",             title: "Resistance Band Row",   category: "Light Strength", difficulty: "Medium", duration: "3 × 12"),
            NewExerciseModel(imageName: "girl_stretch",         title: "Wall Push-Up",          category: "Light Strength", difficulty: "Medium", duration: "3 × 10"),
            NewExerciseModel(imageName: "standing_heel_raises", title: "Standing Heel Raises",  category: "Light Strength", difficulty: "Medium", duration: "3 × 15"),
            NewExerciseModel(imageName: "standing_heel_raises", title: "Single Leg Stand",      category: "Balance",        difficulty: "Medium", duration: "3 × 30 sec"),
            NewExerciseModel(imageName: "girl_stretch",         title: "Tandem Stand",          category: "Balance",        difficulty: "Medium", duration: "3 × 30 sec"),
            NewExerciseModel(imageName: "girl_stretch",         title: "Seated Cat–Cow",        category: "Gentle Yoga",    difficulty: "Low",    duration: "3 min"),
        ]
    )
}
