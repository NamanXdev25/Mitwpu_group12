//
//  HomeModel.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 03/02/26.
//

import UIKit

// MARK: - Home Section Types
enum HomeSectionType: Int, CaseIterable {
    case title = 0
    case quote
    case mood
    case suggestion
    case articles
}

// MARK: - Item Model for Diffable Data Source
struct HomeItem: Hashable {
    let id = UUID()
    let type: ItemType
    
    enum ItemType: Hashable {
        case title
        case quote(String)
        case mood
        case suggestion(Suggestion)
        case article(Article)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HomeItem, rhs: HomeItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Mood Model
struct Mood: Hashable {
    let imageName: String
    let title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageName)
        hasher.combine(title)
    }
    
    static func == (lhs: Mood, rhs: Mood) -> Bool {
        return lhs.imageName == rhs.imageName && lhs.title == rhs.title
    }
}

// MARK: - Suggestion Model
struct Suggestion: Hashable {
    let imageName: String
    let title: String
    let subtitle: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageName)
        hasher.combine(title)
        hasher.combine(subtitle)
    }
    
    static func == (lhs: Suggestion, rhs: Suggestion) -> Bool {
        return lhs.imageName == rhs.imageName &&
               lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle
    }
}

// MARK: - Article Model
struct Article: Hashable {
    let imageName: String
    let title: String
    let subtitle: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageName)
        hasher.combine(title)
        hasher.combine(subtitle)
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.imageName == rhs.imageName &&
               lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle
    }
}

// MARK: - Home Data Model
class HomeModel {
    
    // MARK: - Mood Data
    static let moods: [Mood] = [
        Mood(imageName: "ExcitedImage", title: "Excited"),
        Mood(imageName: "HappyImage", title: "Happy"),
        Mood(imageName: "SadImage", title: "Sad"),
        Mood(imageName: "TiredImage", title: "Tired"),
        Mood(imageName: "AnxiousImage", title: "Anxious")
    ]
    
    // MARK: - Quote Data
    static let quote = "My body and I are working together beautifully"
    
    // MARK: - Suggestion Data (ONLY ONE ITEM NOW)
    static let suggestions: [Suggestion] = [
        Suggestion(
            imageName: "BreathingSessionsImage",
            title: "Gentle Focus",
            subtitle: "A soft breathing session to keep your energy steady."
        )
    ]
    
    // MARK: - Articles Data
    static let articles: [Article] = [
        Article(
            imageName: "Article 1",
            title: "Debunking Common Breast Cancer Myths",
            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
        ),
        Article(
            imageName: "Article 2",
            title: "Implications of Dense Breast Tissue",
            subtitle: "You should know about the truth behind myths associated with Breast Cancer"
        )
    ]
}
