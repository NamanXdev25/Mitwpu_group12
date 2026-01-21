//
//  ProfileSetupViewController.swift
//  BreastCancerApp
//
//  Created by Shloka on 20/01/26.
//

import UIKit

class ProfileSetupViewController: UIViewController,
                                  UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout,
                                  UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate,
                                  ProfileSetupPhotoCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    // Stored Properties

    private var selectedProfileImage: UIImage?

    // Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        collectionView.contentInsetAdjustmentBehavior = .never


        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = .zero
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.estimatedItemSize = .zero
        }

        // Cell Registrations

        collectionView.register(
            UINib(nibName: "ProfileSetupWelcomeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileSetupWelcomeCollectionViewCell"
        )

        collectionView.register(
            UINib(nibName: "ProfileSetupPhotoCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileSetupPhotoCollectionViewCell"
        )

        collectionView.register(
            UINib(nibName: "ProfileSetupFormCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileSetupFormCollectionViewCell"
        )

        collectionView.register(
            UINib(nibName: "ProfileSetupContinueCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileSetupContinueCollectionViewCell"
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // Cell 0 — Welcome Header
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupWelcomeCollectionViewCell",
                for: indexPath
            ) as! ProfileSetupWelcomeCollectionViewCell

            cell.titleLabel.text = "Welcome"
            cell.subtitleLabel.text = "Let’s set up your profile"
            return cell
        }

        // Cell 1 — Profile Photo
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupPhotoCollectionViewCell",
                for: indexPath
            ) as! ProfileSetupPhotoCollectionViewCell

            cell.titleLabel.text = "Profile Photo"
            cell.instructionLabel.text = "Click the camera to add a photo"
            cell.delegate = self

            // Set selected image if available
            if let image = selectedProfileImage {
                cell.setProfileImage(image)
            }

            return cell
        }

        // Cell 2 — Form Fields
        if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupFormCollectionViewCell",
                for: indexPath
            ) as! ProfileSetupFormCollectionViewCell

            cell.firstNameLabel.text = "Your First Name"
            cell.lastNameLabel.text = "Your Last Name"
            cell.genderLabel.text = "Your Gender"
            return cell
        }

        // Cell 3 — Continue Button + Footer
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ProfileSetupContinueCollectionViewCell",
            for: indexPath
        ) as! ProfileSetupContinueCollectionViewCell

        cell.footerLabel.text = "You’re not alone on this journey"
        cell.onContinueTapped = { [weak self] in
            self?.navigateToWelcome()
        }

        return cell

    }

    // UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width

        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: 120)
        case 1:
            return CGSize(width: width, height: 160)
        case 2:
            return CGSize(width: width, height: 280)
        default:
            return CGSize(width: width, height: 120)
        }
    }

    // ProfileSetupPhotoCellDelegate

    func didTapCameraButton() {
        let alert = UIAlertController(
            title: "Profile Photo",
            message: "Choose an option",
            preferredStyle: .actionSheet
        )

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            })
        }

        alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // Image Picker Helpers

    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[.editedImage] as? UIImage {
            selectedProfileImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedProfileImage = originalImage
        }

        picker.dismiss(animated: true)

        // Reload only the photo cell
        collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func navigateToWelcome() {
        let storyboard = UIStoryboard(name: "OnboardingMain", bundle: nil)

        guard let navController = storyboard.instantiateViewController(
            withIdentifier: "OnboardingNavController"
        ) as? UINavigationController else {
            fatalError("OnboardingNavController ID missing")
        }

        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

}
