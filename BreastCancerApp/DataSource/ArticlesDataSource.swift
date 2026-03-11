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
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        articles.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ArticleCell",
            for: indexPath
        ) as! ArticleCell
        cell.configure(with: articles[indexPath.item])
        return cell
    }
}
