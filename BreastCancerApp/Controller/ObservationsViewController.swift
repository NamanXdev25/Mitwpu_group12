import UIKit

class ObservationsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center Title
        let titleLabel = UILabel()
        titleLabel.text = "Your Observations"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // Done circular button
        let doneBtn = UIButton(type: .custom)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        doneBtn.layer.cornerRadius = 22
        doneBtn.backgroundColor = UIColor(named: "pink") ?? UIColor.systemPink
        doneBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        doneBtn.tintColor = .white
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)

        // Register cell + delegates
        let nib = UINib(nibName: "ObservationsContainerCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ObservationsContainerCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @objc func doneTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CollectionView Layout
extension ObservationsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "ObservationsContainerCell",
            for: indexPath
        ) as! ObservationsContainerCell
    }

    // Add spacing: 24 top, 8 left/right
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 24, left: 4, bottom: 0, right: 4)
    }

    // Adjust width to match padding and height for layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 8  // 8 + 8 side padding
        return CGSize(width: width, height: 360)
    }
}
