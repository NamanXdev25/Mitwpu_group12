import UIKit

final class AddMemoryPopupViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var onCamera: (() -> Void)?
    var onPhotos: (() -> Void)?

    private enum Option {
        case camera
        case photos
    }

    private let options: [Option] = [.camera, .photos]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureCollectionView()
    }
}

private extension AddMemoryPopupViewController {

    func configureView() {
        view.backgroundColor = .clear
    }

    func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
            layout.estimatedItemSize = .zero
        }

        collectionView.register(
            UINib(nibName: "AddMemoryOptionCell", bundle: nil),
            forCellWithReuseIdentifier: "AddMemoryOptionCell"
        )
    }
}

extension AddMemoryPopupViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AddMemoryOptionCell",
            for: indexPath
        ) as! AddMemoryOptionCell

        switch options[indexPath.item] {
        case .camera:
            cell.configure(title: "Camera", iconName: "icon_camera")
        case .photos:
            cell.configure(title: "Photos", iconName: "icon_photos")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        dismiss(animated: true)

        switch options[indexPath.item] {
        case .camera:
            onCamera?()
        case .photos:
            onPhotos?()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 68)
    }
}

extension AddMemoryPopupViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
