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
                                  UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        collectionView.delegate = self
        collectionView.dataSource = self

        // 🔹 Push entire content DOWN (matches Figma vertical spacing)
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        collectionView.contentInsetAdjustmentBehavior = .never

        // 🔹 Force full-width layout behavior
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = .zero
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.estimatedItemSize = .zero
        }

        // MARK: - Cell Registrations

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

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // 🔹 Cell 0 — Welcome Header
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupWelcomeCollectionViewCell",
                for: indexPath
            ) as! ProfileSetupWelcomeCollectionViewCell

            cell.titleLabel.text = "Welcome"
            cell.subtitleLabel.text = "Let’s set up your profile"
            return cell
        }

        // 🔹 Cell 1 — Profile Photo
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileSetupPhotoCollectionViewCell",
                for: indexPath
            ) as! ProfileSetupPhotoCollectionViewCell

            cell.titleLabel.text = "Profile Photo"
            cell.instructionLabel.text = "Click the camera to add a photo"
            return cell
        }

        // 🔹 Cell 2 — Form Fields
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

        // 🔹 Cell 3 — Continue Button + Footer Label
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ProfileSetupContinueCollectionViewCell",
            for: indexPath
        ) as! ProfileSetupContinueCollectionViewCell

        cell.footerLabel.text = "You’re not alone on this journey"
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width

        if indexPath.item == 0 {
            return CGSize(width: width, height: 120)
        }

        if indexPath.item == 1 {
            return CGSize(width: width, height: 160)
        }

        if indexPath.item == 2 {
            return CGSize(width: width, height: 280)
        }

        // 🔹 Continue + "You're not alone" (same XIB)
        return CGSize(width: width, height: 120)
    }
}
