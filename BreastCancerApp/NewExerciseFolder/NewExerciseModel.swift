//
//  NewExerciseModel.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 04/02/26.
//

import Foundation

struct NewExerciseModel {
    let imageName: String
    let title: String
    let category: String
    let difficulty: String
    let duration: String
}

struct NewExercisePlan {
    let level: String
    let duration: String
    let exerciseCount: Int
    let note: String?
    let exercises: [NewExerciseModel]
}

// MARK: - Sample Data
extension NewExercisePlan {
    static let level1Exercises = NewExercisePlan(
        level: "Level 1 Post-Surgery Exercises",
        duration: "18 min",
        exerciseCount: 4,
        note: "Note: Start the day after surgery and continue for 7 days unless your doctor says otherwise.",
        exercises: [
            NewExerciseModel(
                imageName: "wall_climbing",
                title: "Wall Climb Stretch",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "shoulder_blade_squeeze",
                title: "Shoulder Rolls",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "chest_open",
                title: "Chest-Opening Breaths",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "girl_stretch",
                title: "Corner Stretch",
                category: "Chest Mobility",
                difficulty: "Medium",
                duration: "2 min"
            ),
            NewExerciseModel(
                imageName: "shoulder_blade_squeeze",
                title: "Scapular Retractions",
                category: "Chest Mobility",
                difficulty: "Medium",
                duration: "2 min"
            )
        ]
    )
    
    static let level2Exercises = NewExercisePlan(
        level: "Level 2 Post-Surgery Exercises",
        duration: "22 min",
        exerciseCount: 5,
        note: nil,
        exercises: [
            NewExerciseModel(
                imageName: "arm_lift",
                title: "Arm stretch",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "posture_alignment_against_wall",
                title: "Elbows together",
                category: "Chest Mobility",
                difficulty: "Medium",
                duration: "2 min"
            ),
            NewExerciseModel(
                imageName: "chest_open",
                title: "Elbows push back",
                category: "Chest Mobility",
                difficulty: "Medium",
                duration: "2 min"
            ),
            NewExerciseModel(
                imageName: "arm_lift",
                title: "Arm lift",
                category: "Chest Mobility",
                difficulty: "High",
                duration: "3 min"
            ),
            NewExerciseModel(
                imageName: "wall_climbing",
                title: "Wall crawl",
                category: "Chest Mobility",
                difficulty: "High",
                duration: "3 min"
            )
        ]
    )
}
