import UIKit

final class HealthStatusViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - State
    private var firstName = "Sophie"
    private var lastName = "Chen"

    private var fullName: String {
        firstName + " " + lastName
    }

    private weak var cardCell: HealthStatusCardCell?

    // MARK: - Constants
    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let headerHeight: CGFloat = 160
        static let cardHeight: CGFloat = 420
        static let lineSpacing: CGFloat = 16
    }

    private enum Strings {
        static let title = "Health Status"
        static let edit = "Edit"
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBarAppearance()
        setupNavigationBar(forEditing: false)
        setupCollectionView()
        registerCells()
    }

    // MARK: - View Setup
    private func setupView() {
        view.backgroundColor = UIColor(named: "bg")
    }

    // MARK: - Collection View
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: ProfileHeaderCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: ProfileHeaderCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: HealthStatusCardCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: HealthStatusCardCell.reuseIdentifier
        )
    }

    // MARK: - Navigation Bar
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear

        navigationController?.navigationBar.tintColor =
            UIColor(named: "pink") ?? .systemPink

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupNavigationBar(forEditing isEditing: Bool) {
        navigationItem.title = Strings.title

        if isEditing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(cancelTapped)
            )

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(doneTapped)
            )
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backTapped)
            )

            let editButton = UIBarButtonItem(
                title: Strings.edit,
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )

            editButton.setTitleTextAttributes(
                [.foregroundColor: UIColor.black],
                for: [.normal, .highlighted]
            )

            navigationItem.rightBarButtonItem = editButton
        }
    }

    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func editTapped() {
        setEditing(true, animated: true)
    }

    @objc private func cancelTapped() {
        cardCell?.revertEdits()
        setEditing(false, animated: true)
    }

    @objc private func doneTapped() {
        view.endEditing(true)

        if let updatedName = cardCell?.currentName {
            firstName = updatedName.first
            lastName = updatedName.last
        }

        cardCell?.commitEdits()
        setEditing(false, animated: true)
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }

    // MARK: - Editing State
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        cardCell?.setEditing(editing)
        setupNavigationBar(forEditing: editing)
    }
}

// MARK: - UICollectionViewDataSource
extension HealthStatusViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        2
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileHeaderCell.reuseIdentifier,
                for: indexPath
            ) as! ProfileHeaderCell

            cell.configure(
                name: fullName,
                image: UIImage(named: "profile_placeholder")
            )

            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HealthStatusCardCell.reuseIdentifier,
            for: indexPath
        ) as! HealthStatusCardCell

        cardCell = cell

        cell.configure(
            firstName: firstName,
            lastName: lastName,
            diagnosisDate: "12 Aug 2024",
            gender: "Female",
            age: "32",
            cancerStage: "Stage II",
            treatmentState: "Ongoing"
        )

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HealthStatusViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 24,
            right: Layout.horizontalInset
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.lineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.bounds.width - (Layout.horizontalInset * 2)

        if indexPath.item == 0 {
            return CGSize(width: width, height: Layout.headerHeight)
        }

        return CGSize(width: width, height: Layout.cardHeight)
    }
}
