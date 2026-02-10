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
                imageName: "wall_climb",
                title: "Wall Climb Stretch",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "shoulder_rolls",
                title: "Shoulder Rolls",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "chest_opening",
                title: "Chest-Opening Breaths",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "corner_stretch",
                title: "Corner Stretch",
                category: "Chest Mobility",
                difficulty: "Medium",
                duration: "2 min"
            ),
            NewExerciseModel(
                imageName: "scapular_retractions",
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
                imageName: "arm_stretch",
                title: "Arm stretch",
                category: "Chest Mobility",
                difficulty: "Low",
                duration: "1 min"
            ),
            NewExerciseModel(
                imageName: "elbows_together",
                title: "Elbows together",
                category: "Chest Mobility",
                difficulty: "Medium",
                duration: "2 min"
            ),
            NewExerciseModel(
                imageName: "elbows_push_back",
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
                imageName: "wall_crawl",
                title: "Wall crawl",
                category: "Chest Mobility",
                difficulty: "High",
                duration: "3 min"
            )
        ]
    )
}
