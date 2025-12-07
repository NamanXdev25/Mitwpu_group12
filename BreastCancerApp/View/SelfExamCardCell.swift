//
//  SelfExamCardCell.swift
//  BreastCancerApp
//
//  Created by Gayatri Goundadkar on 06/12/25.
//
import UIKit

class SelfExamCardCell: UICollectionViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
    }
}
