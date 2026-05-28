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
    func numberOfSections(in _: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch Section(rawValue: section)! {
        case .header:
            return 1
        case .content:
            return article.contentBlocks.count + 1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return configureHeaderCell(collectionView: collectionView, indexPath: indexPath)
        case .content:
            return configureContentCell(collectionView: collectionView, indexPath: indexPath)
        }
    }

    private func configureHeaderCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ArticleHeaderCell",
            for: indexPath
        ) as? ArticleHeaderCell else {
            fatalError("Expected ArticleHeaderCell for reuse identifier 'ArticleHeaderCell' at \(indexPath)")
        }
        cell.configure(imageName: article.imageName)
        return cell
    }

    private func configureContentCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleContentCell",
                for: indexPath
            ) as? ArticleContentCell else {
                fatalError("Expected ArticleContentCell for reuse identifier 'ArticleContentCell' at \(indexPath)")
            }
            let attributed = NSAttributedString(
                string: article.title,
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 22),
                    .foregroundColor: UIColor.label,
                ]
            )
            cell.configureAttributed(text: attributed)
            return cell
        }
        return configureContentBlockCell(
            collectionView: collectionView,
            indexPath: indexPath,
            block: article.contentBlocks[indexPath.item - 1]
        )
    }

    private func configureContentBlockCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        block: ContentBlock
    ) -> UICollectionViewCell {
        switch block.type {
        case .heading:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleContentCell",
                for: indexPath
            ) as? ArticleContentCell else {
                fatalError("Expected ArticleContentCell for reuse identifier 'ArticleContentCell' at \(indexPath)")
            }
            let attributed = NSAttributedString(
                string: block.value,
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.label,
                ]
            )
            cell.configureAttributed(text: attributed)
            return cell

        case .image:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleImageCell",
                for: indexPath
            ) as? ArticleImageCell else {
                fatalError("Expected ArticleImageCell for reuse identifier 'ArticleImageCell' at \(indexPath)")
            }
            cell.configure(imageName: block.value)
            return cell

        case .boldText:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleContentCell",
                for: indexPath
            ) as? ArticleContentCell else {
                fatalError("Expected ArticleContentCell for reuse identifier 'ArticleContentCell' at \(indexPath)")
            }
            cell.configureAttributed(text: parseInlineBold(block.value))
            return cell

        case .link:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleLinkCell",
                for: indexPath
            ) as? ArticleLinkCell else {
                fatalError("Expected ArticleLinkCell for reuse identifier 'ArticleLinkCell' at \(indexPath)")
            }
            cell.configure(urlString: block.value)
            return cell

        case .text:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleContentCell",
                for: indexPath
            ) as? ArticleContentCell else {
                fatalError("Expected ArticleContentCell for reuse identifier 'ArticleContentCell' at \(indexPath)")
            }
            cell.configure(title: "", content: block.value)
            return cell
        }
    }

    private func parseInlineBold(_ raw: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let parts = raw.components(separatedBy: "**")
        for (i, part) in parts.enumerated() {
            let isBold = i % 2 == 1
            let font: UIFont = isBold
                ? .boldSystemFont(ofSize: 16)
                : .systemFont(ofSize: 16)
            result.append(NSAttributedString(string: part, attributes: [.font: font]))
        }
        return result
    }
}
