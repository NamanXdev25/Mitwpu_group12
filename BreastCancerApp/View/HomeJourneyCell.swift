import UIKit

class HomeJourneyCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var treatmentLabel: UILabel!
    @IBOutlet var phaseLabel: UILabel!
    @IBOutlet var cardView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        phaseLabel.isHidden = true
    }

    private func setupCard() {
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
    }

    func configure(journeyStage: String) {
        treatmentLabel.text = journeyStage
        phaseLabel.isHidden = true
    }
}
