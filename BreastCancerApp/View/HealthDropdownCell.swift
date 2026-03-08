//
//  HealthDropdownCell.swift
//  BreastCancerApp
//

import UIKit

class HealthDropdownCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    var onDropdownTap: (() -> Void)?

    private var brandPink: UIColor {
        UIColor(named: "BrandPink") ?? UIColor(red: 215/255, green: 112/255, blue: 145/255, alpha: 1)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor                   = .clear
        contentView.backgroundColor       = .clear
        containerView?.backgroundColor    = .clear
        containerView?.layer.borderWidth  = 0
        containerView?.layer.cornerRadius = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)
    }

    func configure(title: String, value: String, isEditing: Bool = false) {
        backgroundColor                = .clear
        contentView.backgroundColor    = .clear
        containerView?.backgroundColor = .clear

        titleLabel.text      = title
        titleLabel.font      = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .label

        valueLabel.text      = value
        valueLabel.font      = .systemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = isEditing ? brandPink : .secondaryLabel
    }

    @objc private func handleTap() { onDropdownTap?() }
}
