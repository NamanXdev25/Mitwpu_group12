//
//  ProfileSetupFormCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class ProfileSetupFormCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameContainerView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!

    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameContainerView: UIView!
    @IBOutlet weak var lastNameTextField: UITextField!

    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderContainerView: UIView!
    @IBOutlet weak var genderTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        styleContainer(firstNameContainerView)
        styleContainer(lastNameContainerView)
        styleContainer(genderContainerView)
    }

    private func styleContainer(_ view: UIView) {
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemPink.cgColor
    }
}
