import UIKit

class SymptomLogCell: UICollectionViewCell {
    @IBOutlet var symptomNameLabel: UILabel!
    @IBOutlet var severityLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var noteLabel: UILabel!

    func configure(with log: SymptomLog) {
        symptomNameLabel.text = log.symptomName

        let severityText = SymptomDataSource.shared.getSeverityText(for: log.severity)
        severityLabel.text = severityText

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: log.timestamp)

        if !log.note.isEmpty {
            noteLabel.text = log.note
            noteLabel.isHidden = false
        } else {
            noteLabel.text = nil
            noteLabel.isHidden = true
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame

        return layoutAttributes
    }
}
