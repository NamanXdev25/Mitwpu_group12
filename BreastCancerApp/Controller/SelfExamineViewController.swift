import UIKit

class SelfExamineViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        ["GuidesCardCell", "SectionTitleCell",
         "SelfExamCardsContainerCell", "ActionsContainerCell"].forEach {
            collectionView.register(UINib(nibName: $0, bundle: nil),
                                    forCellWithReuseIdentifier: $0)
        }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segues preserved exactly.
    }
}


// MARK: - UICollectionViewDataSource
extension SelfExamineViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { 4 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let id: String = [
            "GuidesCardCell",
            "SectionTitleCell",
            "SelfExamCardsContainerCell",
            "ActionsContainerCell"
        ][indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)

        switch (indexPath.item, cell) {

        case (0, let c as GuidesCardCell):
            c.delegate = self

        case (3, let c as ActionsContainerCell):
            c.delegate = self

        default: break
        }

        return cell
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension SelfExamineViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width - 32

        switch indexPath.item {
        case 0: return .init(width: width, height: 180)
        case 1: return .init(width: width, height: 44)
        case 2: return .init(width: width, height: 200)
        case 3: return .init(width: width, height: 140)
        default: return .init(width: width, height: 60)
        }
    }
}


// MARK: - GuidesCardCellDelegate
extension SelfExamineViewController: GuidesCardCellDelegate {

    func guidesCellDidTapVideo(_ cell: GuidesCardCell) {
        performSegue(withIdentifier: "ShowVideoGuide", sender: cell)
    }

    func guidesCellDidTapAudio(_ cell: GuidesCardCell) {
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
