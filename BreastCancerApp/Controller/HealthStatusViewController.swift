import UIKit

protocol HealthStatusViewControllerDelegate: AnyObject {
    func didUpdateProfile(image: UIImage?, fullName: String)
}

final class HealthStatusViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout,
                                       ProfileHeaderCellDelegate,
                                       UIImagePickerControllerDelegate,
                                       UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: HealthStatusViewControllerDelegate?

    private var firstName = "Sophie"
    private var lastName = "Chen"
    private var profileImage: UIImage?
    private var isEditingProfile = false

    private weak var cardCell: HealthStatusCardCell?

    private var fullName: String {
        "\(firstName) \(lastName)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear

        [
            (ProfileHeaderCell.reuseIdentifier, "ProfileHeaderCell"),
            (HealthStatusCardCell.reuseIdentifier, "HealthStatusCardCell")
        ].forEach {
            collectionView.register(
                UINib(nibName: $0.1, bundle: nil),
                forCellWithReuseIdentifier: $0.0
            )
        }
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func editTapped() {
        isEditingProfile.toggle()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: isEditingProfile ? "xmark" : "chevron.left"),
            style: .plain,
            target: self,
            action: isEditingProfile ? #selector(cancelTapped) : #selector(backTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: isEditingProfile ? "checkmark" : "pencil"),
            style: .plain,
            target: self,
            action: isEditingProfile ? #selector(doneTapped) : #selector(editTapped)
        )

        cardCell?.setEditing(isEditingProfile)
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }

    @objc private func cancelTapped() {
        cardCell?.revertEdits()
        isEditingProfile = false
        editTapped()
    }

    @objc private func doneTapped() {
        view.endEditing(true)

        if let updated = cardCell?.currentName {
            firstName = updated.first
            lastName = updated.last
        }

        cardCell?.commitEdits()

        delegate?.didUpdateProfile(
            image: profileImage,
            fullName: fullName
        )

        dismiss(animated: true)
    }

    // MARK: - Collection View

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileHeaderCell.reuseIdentifier,
                for: indexPath
            ) as! ProfileHeaderCell

            cell.configure(
                name: fullName,
                image: profileImage,
                isEditing: isEditingProfile
            )

            cell.delegate = self
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

    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32
        return indexPath.item == 0
            ? CGSize(width: width, height: 160)
            : CGSize(width: width, height: 340)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }

    // MARK: - Camera

    func didTapCamera() {
        guard isEditingProfile else { return }

        let alert = UIAlertController(
            title: "Profile Photo",
            message: nil,
            preferredStyle: .actionSheet
        )

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openPicker(.camera)
            })
        }

        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openPicker(.photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func openPicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
                               [UIImagePickerController.InfoKey : Any]) {

        profileImage =
            (info[.editedImage] ?? info[.originalImage]) as? UIImage

        picker.dismiss(animated: true)
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
