import UIKit

class ProfileSetupViewController: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    ProfileSetupPhotoCellDelegate {
    @IBOutlet var collectionView: UICollectionView!

    private var selectedProfileImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        collectionView.contentInsetAdjustmentBehavior = .never

        // Keyboard Support
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        collectionView.keyboardDismissMode = .onDrag

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = .zero
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.estimatedItemSize = .zero
        }

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 40, left: 0, bottom: keyboardSize.height + 20, right: 0)
            collectionView.contentInset = contentInsets
            collectionView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(notification _: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        return 4
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupWelcomeCollectionViewCell",
                for: indexPath
            ) as? ProfileSetupWelcomeCollectionViewCell else {
                fatalError("Expected ProfileSetupWelcomeCollectionViewCell for reuse identifier 'ProfileSetupWelcomeCollectionViewCell' at \(indexPath)")
            }

            cell.titleLabel.text = "Welcome"
            cell.subtitleLabel.text = "Let’s set up your profile"
            return cell
        }

        if indexPath.item == 1 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupPhotoCollectionViewCell",
                for: indexPath
            ) as? ProfileSetupPhotoCollectionViewCell else {
                fatalError("Expected ProfileSetupPhotoCollectionViewCell for reuse identifier 'ProfileSetupPhotoCollectionViewCell' at \(indexPath)")
            }

            cell.titleLabel.text = "Profile Photo"
            cell.instructionLabel.text = "Click the camera to add a photo"
            cell.delegate = self

            if let image = selectedProfileImage {
                cell.setProfileImage(image)
            }

            return cell
        }

        if indexPath.item == 2 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupFormCollectionViewCell",
                for: indexPath
            ) as? ProfileSetupFormCollectionViewCell else {
                fatalError("Expected ProfileSetupFormCollectionViewCell for reuse identifier 'ProfileSetupFormCollectionViewCell' at \(indexPath)")
            }

            cell.firstNameLabel.text = "Your First Name"
            cell.lastNameLabel.text = "Your Last Name"
            cell.genderLabel.text = "Your Gender"
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ProfileSetupContinueCollectionViewCell",
            for: indexPath
        ) as? ProfileSetupContinueCollectionViewCell else {
            fatalError("Expected ProfileSetupContinueCollectionViewCell for reuse identifier 'ProfileSetupContinueCollectionViewCell' at \(indexPath)")
        }

        cell.footerLabel.text = "You’re not alone on this journey"
        cell.onContinueTapped = { [weak self] in
            self?.navigateToWelcome()
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
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

    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedProfileImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedProfileImage = originalImage
        }

        picker.dismiss(animated: true)

        collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func navigateToWelcome() {
        if let formCell = collectionView.cellForItem(at: IndexPath(item: 2, section: 0))
            as? ProfileSetupFormCollectionViewCell {
            let firstName = formCell.firstNameTextField.text ?? ""
            let lastName = formCell.lastNameTextField.text ?? ""

            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            OnboardingData.shared.userName = fullName.isEmpty ? "User" : fullName
        }

        let storyboard = UIStoryboard(name: "OnboardingMain", bundle: nil)

        guard let mindfulnessVC = storyboard.instantiateViewController(
            withIdentifier: "OnboardingMindfulnessViewController"
        ) as? OnboardingMindfulnessViewController else {
            fatalError("OnboardingMindfulnessViewController ID missing")
        }

        let navController = UINavigationController(rootViewController: mindfulnessVC)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
