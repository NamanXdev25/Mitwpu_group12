import UIKit

final class ArticlesDataSource: NSObject {
    var articles: [ArticleModel] = []

    func loadArticles() {
        guard let url = Bundle.main.url(forResource: "articles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(ArticlesResponse.self, from: data)
        else { return }
        articles = decoded.articles
    }

    func article(at indexPath: IndexPath) -> ArticleModel {
        articles[indexPath.item]
    }
}

extension ArticlesDataSource: UICollectionViewDataSource {
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
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
            fatalError("Expected ArticleCell for reuse identifier 'ArticleCell' at \(indexPath)")
        }
        cell.configure(with: articles[indexPath.item])
        return cell
    }
}
