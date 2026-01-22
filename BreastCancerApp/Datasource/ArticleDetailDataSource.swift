//
//  ArticleDetailDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 10/01/26.
//

import UIKit

final class ArticleDetailDataSource: NSObject {

    enum Section: Int, CaseIterable {
        case header
        case content
    }

    private let article: ArticleModel

    init(article: ArticleModel) {
        self.article = article
    }
}

extension ArticleDetailDataSource: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let section = Section(rawValue: indexPath.section)!

        switch section {

        case .header:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleHeaderCell",
                for: indexPath
            ) as! ArticleHeaderCell
            cell.configure(imageName: article.imageName)
            return cell

        case .content:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleContentCell",
                for: indexPath
            ) as! ArticleContentCell
            cell.configure(
                title: article.title,
                content: article.content
            )
            return cell
        }
    }
}
