import UIKit

class TestRecordCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var itemsStack: UIStackView!

    var onChevronTap: (() -> Void)?
    var onRequestDelete: (() -> Void)?

    private weak var detailsContainer: UIView?
    private weak var detailsStack: UIStackView?
    private var separator: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()

        // CELL MUST BE TRANSPARENT (pink background shows through)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        isOpaque = false
        backgroundView = nil
        let sbg = UIView()
        sbg.backgroundColor = .clear
        selectedBackgroundView = sbg

        itemsStack.axis = .vertical
        itemsStack.spacing = 8
        itemsStack.alignment = .fill
        itemsStack.distribution = .fill
        itemsStack.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false

        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = UIColor(white: 0.93, alpha: 1)
        contentView.addSubview(sep)
        self.separator = sep

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            chevronButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronButton.leadingAnchor, constant: -8),

            itemsStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6),
            itemsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemsStack.bottomAnchor.constraint(lessThanOrEqualTo: sep.topAnchor, constant: -8),

            sep.heightAnchor.constraint(equalToConstant: 1),
            sep.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sep.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sep.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        if let img = chevronButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate) {
            chevronButton.setImage(img, for: .normal)
        }
        chevronButton.tintColor = UIColor(named: "ChevronGray") ?? .systemGray

        // Swipe-to-delete gesture (controller handles delete)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft(_:)))
        swipe.direction = .left
        contentView.addGestureRecognizer(swipe)

        clearDetails()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearDetails()
        chevronButton.transform = .identity
    }

    private func clearDetails() {
        detailsContainer?.removeFromSuperview()
        detailsContainer = nil
        detailsStack = nil
        itemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func configureDate(_ date: Date, details: [ObservationItem]? = nil) {
        let df = DateFormatter()
        df.dateStyle = .medium
        dateLabel.text = df.string(from: date)

        clearDetails()

        guard let details = details, !details.isEmpty else {
            rotateChevron(down: false, animated: false)
            return
        }

        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.cornerCurve = .continuous
        container.translatesAutoresizingMaskIntoConstraints = false

        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.spacing = 0
        vstack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(vstack)
        NSLayoutConstraint.activate([
            vstack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            vstack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            vstack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            vstack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])

        for (i, obs) in details.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8

            let left = UILabel()
            left.text = obs.title
            left.font = .systemFont(ofSize: 16)

            let right = UILabel()
            right.text = obs.value
            right.font = .systemFont(ofSize: 16)
            right.textAlignment = .right

            row.addArrangedSubview(left)
            row.addArrangedSubview(right)
            row.heightAnchor.constraint(equalToConstant: 44).isActive = true

            vstack.addArrangedSubview(row)

            if i < details.count - 1 {
                let d = UIView()
                d.backgroundColor = UIColor(white: 0.93, alpha: 1)
                d.heightAnchor.constraint(equalToConstant: 1).isActive = true
                vstack.addArrangedSubview(d)
            }
        }

        itemsStack.addArrangedSubview(container)
        detailsContainer = container
        detailsStack = vstack

        rotateChevron(down: true, animated: false)
    }

    private func rotateChevron(down: Bool, animated: Bool) {
        let transform = down ? CGAffineTransform(rotationAngle: .pi/2) : .identity
        if animated { UIView.animate(withDuration: 0.22) { self.chevronButton.transform = transform } }
        else { chevronButton.transform = transform }
    }

    @IBAction func chevronTapped(_ sender: UIButton) {
        let isDown = sender.transform != .identity
        rotateChevron(down: !isDown, animated: true)
        onChevronTap?()
    }

    @objc private func didSwipeLeft(_ g: UISwipeGestureRecognizer) {
        onRequestDelete?()
    }
}
