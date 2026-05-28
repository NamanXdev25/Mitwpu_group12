import UIKit

final class TestRecordCell: UICollectionViewCell {
    // MARK: - Outlets

    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var chevronButton: UIButton!
    @IBOutlet private var itemsStack: UIStackView!
    @IBOutlet private var separator: UIView!

    // MARK: - Callbacks

    var onChevronTap: (() -> Void)?
    var onRequestDelete: (() -> Void)?

    // MARK: - Private Properties

    private weak var detailsContainer: UIView?
    private weak var detailsStack: UIStackView?

    private let containerCornerRadius: CGFloat = 12
    private let containerInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    private let rowHeight: CGFloat = 44

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupSeparator()
        setupGestures()
        clearDetails()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearDetails()
        chevronButton.transform = .identity
    }

    // MARK: - Setup

    private func setupSeparator() {
        separator.backgroundColor = UIColor(white: 0.85, alpha: 1)
        separator.isHidden = false

        if !separator.constraints.contains(where: { $0.firstAttribute == .height }) {
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }

        separator.alpha = 1.0
        separator.clipsToBounds = false
    }

    private func setupGestures() {
        let swipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(didSwipeLeft)
        )
        swipe.direction = .left
        contentView.addGestureRecognizer(swipe)
    }

    private func clearDetails() {
        detailsContainer?.removeFromSuperview()
        detailsContainer = nil
        detailsStack = nil
        itemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Configuration

    func configure(date: Date, details: [ObservationItem]? = nil) {
        dateLabel.text = formatDate(date)
        clearDetails()

        guard let details, !details.isEmpty else {
            rotateChevron(down: false, animated: false)
            return
        }

        addDetailsView(with: details)
        rotateChevron(down: true, animated: false)
    }

    private func addDetailsView(with details: [ObservationItem]) {
        let container = createDetailsContainer()
        let stack = createDetailsStack()

        setupContainerConstraints(container: container, stack: stack)
        populateDetails(stack: stack, with: details)

        itemsStack.addArrangedSubview(container)
        detailsContainer = container
        detailsStack = stack
    }

    // MARK: - Date Formatting

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Details Container Creation

    private func createDetailsContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = containerCornerRadius
        container.layer.cornerCurve = .continuous
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }

    private func createDetailsStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func setupContainerConstraints(container: UIView, stack: UIStackView) {
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: containerInsets.left),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerInsets.right),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: containerInsets.top),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -containerInsets.bottom),
        ])
    }

    // MARK: - Details Population

    private func populateDetails(
        stack: UIStackView,
        with details: [ObservationItem]
    ) {
        for (index, item) in details.enumerated() {
            let row = createDetailRow(
                title: item.title,
                value: item.value
            )
            stack.addArrangedSubview(row)

            if index < details.count - 1 {
                stack.addArrangedSubview(createDivider())
            }
        }
    }

    private func createDetailRow(
        title: String,
        value: String
    ) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8

        let titleLabel = createLabel(
            text: title,
            alignment: .left
        )

        let valueLabel = createLabel(
            text: value,
            alignment: .right
        )

        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        row.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true

        return row
    }

    private func createLabel(
        text: String,
        alignment: NSTextAlignment
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = alignment
        return label
    }

    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.93, alpha: 1)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    // MARK: - Chevron Animation

    private func rotateChevron(down: Bool, animated: Bool) {
        let transform = down
            ? CGAffineTransform(rotationAngle: .pi / 2)
            : .identity

        if animated {
            UIView.animate(withDuration: 0.22) {
                self.chevronButton.transform = transform
            }
        } else {
            chevronButton.transform = transform
        }
    }

    // MARK: - Actions

    @IBAction private func chevronTapped(_ sender: UIButton) {
        let isExpanded = sender.transform != .identity
        rotateChevron(down: !isExpanded, animated: true)
        onChevronTap?()
    }

    @objc private func didSwipeLeft(_: UISwipeGestureRecognizer) {
        onRequestDelete?()
    }

    func setSeparatorHidden(_ hidden: Bool) {
        separator.isHidden = hidden
    }
}
