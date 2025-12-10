// TestRecordCell.swift
import UIKit

class TestRecordCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var itemsStack: UIStackView!          // vertical; holds detailsContainer when expanded

    var onChevronTap: (() -> Void)?

    private weak var detailsContainer: UIView?
    private weak var detailsStack: UIStackView?
    private var separator: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()

        itemsStack.axis = .vertical
        itemsStack.spacing = 8
        itemsStack.alignment = .fill
        itemsStack.distribution = .fill
        itemsStack.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false

        // Divider under each date row
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = UIColor(white: 0.93, alpha: 1)
        contentView.addSubview(sep)
        self.separator = sep

        NSLayoutConstraint.activate([
            // TIGHT TOP SPACING
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            chevronButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronButton.leadingAnchor, constant: -8),

            // SHRINKED GAP LIKE FIGMA
            itemsStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            itemsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemsStack.bottomAnchor.constraint(lessThanOrEqualTo: sep.topAnchor, constant: -4),

            // Divider
            sep.heightAnchor.constraint(equalToConstant: 1),
            sep.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sep.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sep.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Chevron color from Assets (template)
        if let img = chevronButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate) {
            chevronButton.setImage(img, for: .normal)
        }
        chevronButton.tintColor = UIColor(named: "ChevronGray") ?? .systemGray

        clearDetails()
    }

    private func clearDetails() {
        detailsContainer?.removeFromSuperview()
        detailsContainer = nil
        detailsStack = nil
    }

    func configureDate(_ date: Date, details: [ObservationItem]? = nil) {
        let df = DateFormatter(); df.dateStyle = .medium
        dateLabel.text = df.string(from: date)

        clearDetails()

        guard let details = details, !details.isEmpty else {
            rotateChevron(down: false, animated: false)
            return
        }

        // container card
        let container = UIView()
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false

        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.alignment = .fill
        vstack.distribution = .fill
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
            row.alignment = .center
            row.distribution = .fill
            row.spacing = 8
            row.translatesAutoresizingMaskIntoConstraints = false

            let left = UILabel()
            left.text = obs.title
            left.font = .systemFont(ofSize: 16)
            left.numberOfLines = 1
            left.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let right = UILabel()
            right.text = obs.value
            right.font = .systemFont(ofSize: 16)
            right.numberOfLines = 1
            right.textAlignment = .right
            right.setContentCompressionResistancePriority(.required, for: .horizontal)

            row.addArrangedSubview(left)
            row.addArrangedSubview(right)

            // consistent row height
            row.heightAnchor.constraint(equalToConstant: 44).isActive = true

            vstack.addArrangedSubview(row)

            if i < details.count - 1 {
                let divider = UIView()
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                divider.backgroundColor = UIColor(white: 0.93, alpha: 1)
                vstack.addArrangedSubview(divider)
            }
        }

        // add container to itemsStack so ordering remains; pin container to contentView to control full width (8pt insets)
        itemsStack.addArrangedSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])

        // ensure corner rendering after layout
        contentView.layoutIfNeeded()
        container.layer.cornerCurve = .continuous
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        container.clipsToBounds = true

        detailsContainer = container
        detailsStack = vstack

        rotateChevron(down: true, animated: false)
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    private func rotateChevron(down: Bool, animated: Bool) {
        let transform = down ? CGAffineTransform(rotationAngle: .pi / 2) : .identity
        if animated {
            UIView.animate(withDuration: 0.22) { [weak self] in
                self?.chevronButton.transform = transform
            }
        } else {
            chevronButton.transform = transform
        }
    }

    @IBAction func chevronTapped(_ sender: UIButton) {
        let isDown = sender.transform != .identity
        rotateChevron(down: !isDown, animated: true)
        onChevronTap?()
    }
}
