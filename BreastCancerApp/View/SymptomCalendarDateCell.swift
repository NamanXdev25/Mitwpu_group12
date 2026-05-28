import UIKit

class SymptomCalendarDateCell: UICollectionViewCell {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var selectionLayer: UIView!
    @IBOutlet var dotView: UIView!

    private let primaryColor = UIColor(named: "SymptomsPrimaryColor") ?? .label

    override func layoutSubviews() {
        super.layoutSubviews()

        selectionLayer.layer.cornerRadius = selectionLayer.frame.height / 2
        selectionLayer.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        selectionLayer.backgroundColor = .clear
        dotView.isHidden = true
        dayLabel.textColor = .black
    }

    func configure(
        day: String,
        hasSymptomLog: Bool,
        isSelected: Bool,
        isToday: Bool,
        isFuture: Bool
    ) {
        dayLabel.text = day
        selectionLayer.backgroundColor = .clear
        dotView.isHidden = true

        guard !day.isEmpty else { return }
        if hasSymptomLog {
            dotView.isHidden = false
            dotView.backgroundColor = UIColor(named: "SymptomsPrimaryColor")
        }

        if isFuture {
            dayLabel.textColor = .tertiaryLabel
            contentView.alpha = 0.4
            contentView.backgroundColor = .clear
            dotView.isHidden = true
            return
        }

        contentView.alpha = 1.0

        if isToday {
            selectionLayer.backgroundColor =
                UIColor(named: "SymptomsPrimaryColor")?.withAlphaComponent(1.0)

            dayLabel.textColor = .white
            dotView.backgroundColor = .white
        }

        if isSelected {
            selectionLayer.backgroundColor =
                UIColor(named: "SymptomsPrimaryColor")?.withAlphaComponent(0.2)

            dayLabel.textColor = UIColor(named: "SymptomsPrimaryColor")
            dotView.backgroundColor = UIColor(named: "SymptomsPrimaryColor")
        }
    }
}
