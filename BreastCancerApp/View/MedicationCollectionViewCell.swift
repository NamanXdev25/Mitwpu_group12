import UIKit

class MedicationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var editButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var adherenceRateLabel: UILabel!
    @IBOutlet var metricCaptionLabel: UILabel!
    @IBOutlet var dosesTakenLabel: UILabel!
    @IBOutlet var dosesMissedLabel: UILabel!
    @IBOutlet var statusIcons: [UIImageView]!

    var onStatusIconTapped: ((Int) -> Void)?
    private var selectedStatusIndex: Int?
    private var statusValues: [Int] = []
    private var isStatusSelectionEnabled = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStatusIconGestures()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let completedTintColor = UIColor(named: "primary_color")
            ?? UIColor(named: "PrimaryColor")
            ?? UIColor(named: "pink")
            ?? .systemPink

        for (index, icon) in statusIcons.enumerated() {
            applySelectionAppearance(
                to: icon,
                isSelected: selectedStatusIndex == index,
                accentColor: completedTintColor
            )
        }
    }

    func configureStatusIcons(
        with values: [Int],
        selectedIndex: Int? = nil,
        isSelectionEnabled: Bool = false,
        usesDashedPlaceholderForIncompleteDays: Bool = false
    ) {
        let completedTintColor = UIColor(named: "primary_color")
            ?? UIColor(named: "PrimaryColor")
            ?? UIColor(named: "pink")
            ?? .systemPink

        selectedStatusIndex = selectedIndex
        statusValues = values
        isStatusSelectionEnabled = isSelectionEnabled

        for (index, icon) in statusIcons.enumerated() {
            icon.tag = index
            icon.isUserInteractionEnabled = isSelectionEnabled

            guard index < values.count else {
                icon.image = UIImage(systemName: "minus.circle")
                icon.tintColor = .systemGray4
                applySelectionAppearance(
                    to: icon,
                    isSelected: selectedStatusIndex == index,
                    accentColor: completedTintColor
                )
                continue
            }

            switch values[index] {
            case 1:
                icon.image = UIImage(systemName: "checkmark.circle.fill")
                icon.tintColor = completedTintColor
            case 0:
                icon.image = UIImage(systemName: usesDashedPlaceholderForIncompleteDays ? "minus.circle" : "circle.fill")
                icon.tintColor = .systemGray4
            default:
                icon.image = UIImage(systemName: "minus.circle")
                icon.tintColor = .systemGray4
            }

            applySelectionAppearance(
                to: icon,
                isSelected: selectedStatusIndex == index,
                accentColor: completedTintColor
            )
        }
    }

    func selectStatusIcon(at index: Int?) {
        selectedStatusIndex = index
        configureStatusIcons(
            with: statusValues,
            selectedIndex: index,
            isSelectionEnabled: isStatusSelectionEnabled
        )
    }

    private func setupStatusIconGestures() {
        for (index, icon) in statusIcons.enumerated() {
            icon.tag = index
            icon.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleStatusIconTap(_:)))
            icon.gestureRecognizers?.forEach { icon.removeGestureRecognizer($0) }
            icon.addGestureRecognizer(tap)
        }
    }

    @objc private func handleStatusIconTap(_ gesture: UITapGestureRecognizer) {
        guard isStatusSelectionEnabled else { return }
        guard let view = gesture.view else { return }
        selectedStatusIndex = view.tag
        configureStatusIcons(
            with: statusValues,
            selectedIndex: selectedStatusIndex,
            isSelectionEnabled: isStatusSelectionEnabled
        )
        onStatusIconTapped?(view.tag)
    }

    private func applySelectionAppearance(
        to icon: UIImageView,
        isSelected: Bool,
        accentColor: UIColor
    ) {
        icon.layer.cornerRadius = icon.bounds.width / 2
        icon.backgroundColor = isSelected ? accentColor.withAlphaComponent(0.12) : .clear
        icon.transform = isSelected ? CGAffineTransform(scaleX: 1.12, y: 1.12) : .identity
    }
}
