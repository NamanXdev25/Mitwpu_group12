//
//  SocialLoginCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 19/01/26.
//

import UIKit

class SocialLoginCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var googleContainerView: UIView!
    @IBOutlet weak var appleContainerView: UIView!
    @IBOutlet weak var signUpButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTapGestures()
    }

    private func setupUI() {

        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        stylePillView(googleContainerView)
        stylePillView(appleContainerView)

        signUpButton.backgroundColor = .clear
        signUpButton.setTitleColor(UIColor(named: "Pink"), for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        signUpButton.adjustsImageWhenHighlighted = false
    }

    private func stylePillView(_ view: UIView) {
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "Pink")?.cgColor
        view.clipsToBounds = true
        view.backgroundColor = .white
    }

    private func setupTapGestures() {
        let googleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapGoogle)
        )
        googleContainerView.addGestureRecognizer(googleTap)

        let appleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapApple)
        )
        appleContainerView.addGestureRecognizer(appleTap)
    }

    @objc private func didTapGoogle() {
        print("Google login tapped")
    }

    @objc private func didTapApple() {
        print("Apple login tapped")
    }

    @IBAction func didTapSignUp(_ sender: UIButton) {
        print("Sign up tapped")
    }
}

