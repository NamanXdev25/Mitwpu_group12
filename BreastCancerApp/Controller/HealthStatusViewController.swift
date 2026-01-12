import UIKit

final class HealthStatusViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - State
    private var firstName = "Sophie"
    private var lastName = "Chen"

    private var fullName: String {
        "\(firstName) \(lastName)"
    }

    private weak var cardCell: HealthStatusCardCell?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "bg")
        configureNavigationBarAppearance()
        configureNavigationBar()
        setupCollectionView()
        registerCells()
    }

    // MARK: - Collection View Setup
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: "ProfileHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: ProfileHeaderCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: "HealthStatusCardCell", bundle: nil),
            forCellWithReuseIdentifier: HealthStatusCardCell.reuseIdentifier
        )
    }

    // MARK: - Navigation Bar
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear

        let pink = UIColor(named: "pink") ?? .systemPink
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: pink]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = pink
    }

    private func configureNavigationBar() {
        navigationItem.title = "Health Status"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func editTapped() {
        setEditing(true, animated: true)
    }
}

// MARK: - Edit Handling
extension HealthStatusViewController {

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        cardCell?.setEditing(editing)

        if editing {
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
            configureNavigationBar()
        }
    }

    @objc private func cancelTapped() {
        cardCell?.revertEdits()
        setEditing(false, animated: true)
    }

    @objc private func doneTapped() {
        view.endEditing(true)

        if let updated = cardCell?.currentName {
            firstName = updated.first
            lastName = updated.last
        }

        cardCell?.commitEdits()
        setEditing(false, animated: true)
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }
}

// MARK: - UICollectionViewDataSource
extension HealthStatusViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.bounds.width - 32

        if indexPath.item == 0 {
            return CGSize(width: width, height: 160)
        }

        return CGSize(width: width, height: 420)
    }
}
