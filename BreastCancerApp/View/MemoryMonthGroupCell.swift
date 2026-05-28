import UIKit

final class MemoryMonthGroupCell: UICollectionViewCell {
    static let reuseIdentifier = "MemoryMonthGroupCell"

    // MARK: - Outlets

    @IBOutlet private var polaroidCard1: UIView!
    @IBOutlet private var polaroidCard2: UIView!
    @IBOutlet private var polaroidCard3: UIView!
    @IBOutlet private var polaroidCard4: UIView!
    @IBOutlet private var imageView1: UIImageView!
    @IBOutlet private var imageView2: UIImageView!
    @IBOutlet private var imageView3: UIImageView!
    @IBOutlet private var imageView4: UIImageView!
    @IBOutlet private var overlayView: UIView!
    @IBOutlet private var overlayLabel: UILabel!
    @IBOutlet private var monthLabel: UILabel!
    @IBOutlet private var separatorLine: UIView!

    var onTap: (() -> Void)?

    private let calendar = Calendar.current

    override func awakeFromNib() {
        super.awakeFromNib()
        configureStyling()
        configureGesture()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
        imageView4.image = nil
        overlayLabel.text = ""
        overlayView.isHidden = true
        separatorLine.isHidden = false
        onTap = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for card in [polaroidCard1, polaroidCard2, polaroidCard3, polaroidCard4] {
            card?.layer.shadowPath = UIBezierPath(
                roundedRect: card!.bounds,
                cornerRadius: 12
            ).cgPath
        }
    }

    func configure(with memories: [Memory], month: Int, year _: Int, isLast: Bool) {
        let imageViews = [imageView1, imageView2, imageView3, imageView4]
        let cards = [polaroidCard1, polaroidCard2, polaroidCard3, polaroidCard4]
        let displayCount = min(memories.count, 4)

        for i in 0 ..< displayCount {
            imageViews[i]?.image = memories[i].image
            cards[i]?.isHidden = false
        }

        for i in displayCount ..< 4 {
            cards[i]?.isHidden = true
        }

        if memories.count > 4 {
            overlayView.isHidden = false
            overlayLabel.text = "+\(memories.count - 3)"
        } else {
            overlayView.isHidden = true
        }

        let monthName = calendar.monthSymbols[month - 1]
        monthLabel.text = monthName

        separatorLine.isHidden = isLast
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Private Configuration

private extension MemoryMonthGroupCell {
    func configureStyling() {
        let cards = [polaroidCard1, polaroidCard2, polaroidCard3, polaroidCard4]
        let rotations: [CGFloat] = [-0.08, 0.05, -0.03, 0.06]

        for (index, card) in cards.enumerated() {
            guard let card = card else { continue }

            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOffset = CGSize(width: 0, height: 4)
            card.layer.shadowRadius = 8
            card.layer.shadowOpacity = 0.15
            card.layer.masksToBounds = false

            card.transform = CGAffineTransform(rotationAngle: rotations[index])
        }

        for imageView in [imageView1, imageView2, imageView3, imageView4] {
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
            imageView?.layer.cornerRadius = 6
            imageView?.backgroundColor = .systemGray6
        }

        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 6
        overlayLabel.textColor = .white
        overlayLabel.font = .systemFont(ofSize: 28, weight: .bold)
        overlayLabel.textAlignment = .center

        monthLabel.textColor = UIColor(red: 0.91, green: 0.42, blue: 0.57, alpha: 1.0)
    }

    func configureGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }
}
