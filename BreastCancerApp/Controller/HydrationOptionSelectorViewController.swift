import UIKit

final class HydrationOptionSelectorViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Public Configuration
    var titleText: String = ""
    var subtitleText: String = ""
    var options: [String] = []
    var onSelect: ((Int) -> Void)?

    // MARK: - Layout
    private let cellHeight: CGFloat = 44

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        configureDismissGesture()
    }

    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .clear
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.estimatedItemSize = .zero
        }

        collectionView.register(
            UINib(
                nibName: "HydrationOptionCollectionCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "HydrationOptionCollectionCell"
        )
    }

    private func configureDismissGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissSelf)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension HydrationOptionSelectorViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
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

// MARK: - UICollectionViewDelegate
extension HydrationOptionSelectorViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        dismiss(animated: true)

        if indexPath.item < options.count {
            onSelect?(indexPath.item)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HydrationOptionSelectorViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: collectionView.bounds.width,
            height: cellHeight
        )
    }
}
