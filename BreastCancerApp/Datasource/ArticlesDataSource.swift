//
//  ArticlesDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 10/01/26.
//

import UIKit

final class ArticlesDataSource: NSObject {

    private(set) var articles: [ArticleModel] = []

    func loadArticles() {
        guard let url = Bundle.main.url(forResource: "articles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(ArticlesResponse.self, from: data) else {
            print("Failed to load articles.json")
            return
        }
        
        articles = response.articles
    }

    func article(at indexPath: IndexPath) -> ArticleModel {
        articles[indexPath.item]
    }
}

extension ArticlesDataSource: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        articles.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ArticleCell",
            for: indexPath
        ) as? ArticleCell else {
            fatalError("ArticleCell not registered")
        }

        cell.configure(with: article(at: indexPath))
        return cell
    }
}
