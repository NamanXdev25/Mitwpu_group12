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
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArticleHeaderCell",
                for: indexPath
            ) as! ArticleHeaderCell
            cell.configure(imageName: article.imageName)
            return cell

        case .content:

            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ArticleContentCell",
                    for: indexPath
                ) as! ArticleContentCell
                let attributed = NSAttributedString(
                    string: article.title,
                    attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 22),
                        .foregroundColor: UIColor.label
                    ]
                )
                cell.configureAttributed(text: attributed)
                return cell
            }

            let block = article.contentBlocks[indexPath.item - 1]

            switch block.type {

            case .heading:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ArticleContentCell",
                    for: indexPath
                ) as! ArticleContentCell
                let attributed = NSAttributedString(
                    string: block.value,
                    attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 18),
                        .foregroundColor: UIColor.label
                    ]
                )
                cell.configureAttributed(text: attributed)
                return cell

            case .image:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ArticleImageCell",
                    for: indexPath
                ) as! ArticleImageCell
                cell.configure(imageName: block.value)
                return cell

            case .boldText:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ArticleContentCell",
                    for: indexPath
                ) as! ArticleContentCell
                cell.configureAttributed(text: parseInlineBold(block.value))
                return cell

            case .link:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ArticleLinkCell",
                    for: indexPath
                ) as! ArticleLinkCell
                cell.configure(urlString: block.value)
                return cell

            case .text:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ArticleContentCell",
                    for: indexPath
                ) as! ArticleContentCell
                cell.configure(title: "", content: block.value)
                return cell
            }
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
