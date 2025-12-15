//
//  HomeTodaysGoalModel.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import Foundation

// MARK: - The Model
// In MVC, the Model is a standalone entity that knows nothing about the View or the Controller.
struct HomeTodaysGoalModel {
    let title: String
    let points: String
    let iconName: String
    let isCompleted: Bool
}
