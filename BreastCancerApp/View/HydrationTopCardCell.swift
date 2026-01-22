import UIKit

final class HydrationTopCardCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet private weak var progressRingView: CircularProgressView!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var remainingLabel: UILabel!
    @IBOutlet private weak var dropButton: UIButton!

    // Existing value buttons
    @IBOutlet private weak var goalValueButton: UIButton!
    @IBOutlet private weak var cupValueButton: UIButton!

    // NEW: Full-row tap buttons
    @IBOutlet private weak var goalRowButton: UIButton!
    @IBOutlet private weak var cupRowButton: UIButton!

    // MARK: - Callbacks
    var onGoalTapped: (() -> Void)?
    var onCupTapped: (() -> Void)?
    var onDropTapped: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureProgressView()
        configureActions()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        progressRingView.setProgress(0, animated: false)
    }

    // MARK: - Public Configure
    func configure(consumedML: Int, goal: Double, cupSize: Int) {

        let consumedLiters = Double(consumedML) / 1000.0
        let remainingLiters = max(goal - consumedLiters, 0)

        let progress = goal > 0
            ? min(CGFloat(consumedLiters / goal), 1.0)
            : 0

        valueLabel.text = String(
            format: "%.1f L / %.1f L",
            consumedLiters,
            goal
        )

        remainingLabel.text = String(
            format: "Remaining %.1f L",
            remainingLiters
        )

        goalValueButton.setTitle(
            String(format: "%.1f L", goal),
            for: .normal
        )

        cupValueButton.setTitle(
            "\(cupSize) mL",
            for: .normal
        )

        progressRingView.setProgress(progress, animated: true)
    }

    // MARK: - Private
    private func configureProgressView() {
        let circularcolor = UIColor(named: "plusbuttoncolor")!
        progressRingView.lineWidth = 8
        progressRingView.trackColor = UIColor(white: 0.92, alpha: 1)
        progressRingView.progressColor = circularcolor
        progressRingView.backgroundColor = .clear
    }

    private func configureActions() {

        // FULL ROW TAPS
        goalRowButton.addTarget(self, action: #selector(goalTapped), for: .touchUpInside)
        cupRowButton.addTarget(self, action: #selector(cupTapped), for: .touchUpInside)

        // VALUE TEXT TAPS (optional but fine)
        goalValueButton.addTarget(self, action: #selector(goalTapped), for: .touchUpInside)
        cupValueButton.addTarget(self, action: #selector(cupTapped), for: .touchUpInside)

        // DROP BUTTON
        dropButton.addTarget(self, action: #selector(dropTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func goalTapped() {
        onGoalTapped?()
    }

    @objc private func cupTapped() {
        onCupTapped?()
    }

    @objc private func dropTapped() {
        onDropTapped?()
    }
}
