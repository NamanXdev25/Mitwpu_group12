import UIKit

final class HydrationOptionSelectorViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var titleText: String = ""
    var subtitleText: String = ""
    var options: [String] = []
    var onSelect: ((Int) -> Void)?

    private let cellHeight: CGFloat = 35

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
    }

    private func configureUI() {
        view.backgroundColor = .clear
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
    }

    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "HydrationOptionCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "HydrationOptionCollectionCell"
        )
    }
}

extension HydrationOptionSelectorViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        options.count + 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HydrationOptionCollectionCell",
            for: indexPath
        ) as! HydrationOptionCollectionCell

        let isCancel = indexPath.item == options.count
        let text = isCancel ? "Cancel" : options[indexPath.item]

        cell.configure(
            text: text,
            hideDivider: isCancel,
            isFirst: indexPath.item == 0,
            isLast: isCancel
        )

        return cell
    }
}

extension HydrationOptionSelectorViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true)

        if indexPath.item < options.count {
            onSelect?(indexPath.item)
        }
    }
}

extension HydrationOptionSelectorViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: cellHeight)
    }
}
