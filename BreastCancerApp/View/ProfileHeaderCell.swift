//
//  ProfileHeaderCell.swift
//  BreastCancerApp
//

import UIKit

class ProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var onImageTap: (() -> Void)?

    private var brandPink: UIColor {
        UIColor(named: "BrandPink") ?? UIColor(red: 215/255, green: 112/255, blue: 145/255, alpha: 1)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        guard profileImageView != nil else { return }

        profileImageView.layer.cornerRadius       = profileImageView.frame.width / 2
        profileImageView.clipsToBounds            = true
        profileImageView.contentMode              = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.addGestureRecognizer(tap)
    }

    func configure(name: String, image: UIImage? = nil) {
        nameLabel?.text          = name
        nameLabel?.font          = .systemFont(ofSize: 20, weight: .bold)
        nameLabel?.textAlignment = .center
        nameLabel?.textColor     = .label

        if let img = image {
            profileImageView?.image     = img
            profileImageView?.tintColor = .clear
        } else {
            profileImageView?.image     = UIImage(systemName: "person.circle.fill")
            profileImageView?.tintColor = brandPink
        }
    }

    @objc private func imageTapped() { onImageTap?() }
}
