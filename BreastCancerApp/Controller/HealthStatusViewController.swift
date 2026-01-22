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

    private let dataSource = UserProfileDataSource.shared
    private var isEditingProfile = false
    private weak var cardCell: HealthStatusCardCell?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Health Status"

        // IMPORTANT: Remove the custom left bar button item
        // This allows the default back button to appear
        navigationItem.leftBarButtonItem = nil

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

    // MARK: - Navigation

    @objc private func editTapped() {
        isEditingProfile.toggle()

        // In edit mode: show cancel (X) button on left
        // In normal mode: use default back button (nil)
        navigationItem.leftBarButtonItem = isEditingProfile ? UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        ) : nil

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: isEditingProfile ? "checkmark" : "pencil"),
            style: .plain,
            target: self,
            action: isEditingProfile ? #selector(doneTapped) : #selector(editTapped)
        )

        cardCell?.setEditing(isEditingProfile)
        updateHeaderEditingState()
    }

    @objc private func cancelTapped() {
        // Revert any changes made
        cardCell?.revertEdits()
        
        // Exit editing mode
        isEditingProfile = false
        
        // Update navigation bar buttons to non-editing state
        navigationItem.leftBarButtonItem = nil // Use default back button

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        
        // Update cells to display mode
        cardCell?.setEditing(false)
        updateHeaderEditingState()
    }

    @objc private func doneTapped() {
        view.endEditing(true)

        if let updated = cardCell?.currentName {
            UserProfileDataSource.shared.updateBasicInfo(
                firstName: updated.first,
                lastName: updated.last,
                profileImage: dataSource.userProfile.profileImage
            )
        }

        cardCell?.commitEdits()

        delegate?.didUpdateProfile(
            image: dataSource.userProfile.profileImage,
            fullName: dataSource.userProfile.fullName
        )

        // Exit editing mode without dismissing the screen
        isEditingProfile = false
        
        // Update navigation bar buttons to non-editing state
        navigationItem.leftBarButtonItem = nil // Use default back button

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        
        // Update cells to display mode
        cardCell?.setEditing(false)
        updateHeaderEditingState()
    }

    // MARK: - Header Update (IMPORTANT)

    private func updateHeaderEditingState() {
        guard let header = collectionView.cellForItem(
            at: IndexPath(item: 0, section: 0)
        ) as? ProfileHeaderCell else { return }

        let profile = dataSource.userProfile
        header.configure(
            name: profile.fullName,
            image: profile.profileImage,
            isEditing: isEditingProfile
        )
        header.delegate = self
    }

    // MARK: - Collection View DataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let profile = dataSource.userProfile

        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileHeaderCell.reuseIdentifier,
                for: indexPath
            ) as! ProfileHeaderCell

            cell.configure(
                name: profile.fullName,
                image: profile.profileImage,
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
            firstName: profile.firstName,
            lastName: profile.lastName,
            diagnosisDate: "12 Aug 2024",
            gender: profile.gender,
            age: profile.ageString,
            cancerStage: profile.cancerStage,
            treatmentState: "Ongoing"
        )


        cell.setEditing(isEditingProfile)
        return cell
    }

    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32
        return indexPath.item == 0
            ? CGSize(width: width, height: 160)
            : CGSize(width: width, height: 345)
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

        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage

        UserProfileDataSource.shared.updateBasicInfo(
            firstName: dataSource.userProfile.firstName,
            lastName: dataSource.userProfile.lastName,
            profileImage: image
        )

        picker.dismiss(animated: true)
        updateHeaderEditingState()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
