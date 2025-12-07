import UIKit

class ActionsContainerCell: UICollectionViewCell {

    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var pastLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Transparent so background shows through
        contentView.backgroundColor = .clear

        // Button styling
        logButton.setTitle("Log Self-Exam", for: .normal)
        logButton.backgroundColor = UIColor(named: "pink") ?? UIColor.systemPink
        logButton.layer.cornerRadius = 24
        logButton.clipsToBounds = true
        logButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logButton.setTitleColor(.white, for: .normal)

        // Label styling
        pastLabel.text = "View past tests"
        pastLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        pastLabel.textColor = UIColor(named: "pink") ?? UIColor.systemPink
        pastLabel.textAlignment = .center
    }
}
