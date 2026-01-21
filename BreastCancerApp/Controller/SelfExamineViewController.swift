import UIKit

final class SelfExamineViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        [
            "GuidesCardCell",
            "SectionTitleCell",
            "SelfExamCardsContainerCell",
            "ActionsContainerCell"
        ].forEach {
            collectionView.register(
                UINib(nibName: $0, bundle: nil),
                forCellWithReuseIdentifier: $0
            )
        }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )

        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segues preserved exactly as requested
    }
}

// MARK: - UICollectionViewDataSource
extension SelfExamineViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        4
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let identifiers = [
            "SectionTitleCell",
            "SelfExamCardsContainerCell",
            "GuidesCardCell",
            "ActionsContainerCell"
        ]

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: identifiers[indexPath.item],
            for: indexPath
        )

        switch (indexPath.item, cell) {

        case (2, let guidesCell as GuidesCardCell):
            guidesCell.delegate = self

        case (3, let actionsCell as ActionsContainerCell):
            actionsCell.delegate = self

        default:
            break
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelfExamineViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.frame.width - 32

        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: 44)
        case 1:
            return CGSize(width: width, height: 200)
        case 2:
            return CGSize(width: width, height: 180)
        case 3:
            return CGSize(width: width, height: 140)
        default:
            return CGSize(width: width, height: 60)
        }
    }
}

// MARK: - GuidesCardCellDelegate
extension SelfExamineViewController: GuidesCardCellDelegate {

    func guidesCardCellDidTapVideoGuide(_ cell: GuidesCardCell) {
        performSegue(withIdentifier: "ShowVideoGuide", sender: cell)
    }

    func guidesCardCellDidTapAudioGuide(_ cell: GuidesCardCell) {
        performSegue(withIdentifier: "ShowAudioGuide", sender: cell)
    }
}

// MARK: - ActionsContainerCellDelegate
extension SelfExamineViewController: ActionsContainerCellDelegate {

    func didTapLogSelfExam(from cell: ActionsContainerCell) {
        performSegue(withIdentifier: "showObservations", sender: cell)
    }

    func didTapViewPastTests(from cell: ActionsContainerCell) {
        performSegue(withIdentifier: "showTestHistory", sender: cell)
    }
}
