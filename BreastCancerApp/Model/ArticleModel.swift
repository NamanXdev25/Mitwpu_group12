//
//  ArticleModel.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 10/01/26.
//

import Foundation

struct ArticleModel: Decodable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String
    let content: String
}

struct ArticlesResponse: Decodable {
    let articles: [ArticleModel]
}
