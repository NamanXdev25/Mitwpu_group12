import UIKit

class HydrationTopCardCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var goalValueButton: UIButton!
    @IBOutlet weak var cupValueButton: UIButton!

    // MARK: - Callbacks (handled by ViewController)
    var onGoalTapped: (() -> Void)?
    var onCupTapped: (() -> Void)?
    var onDropTapped: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        goalValueButton.addTarget(
            self,
            action: #selector(goalTapped),
            for: .touchUpInside
        )

        cupValueButton.addTarget(
            self,
            action: #selector(cupTapped),
            for: .touchUpInside
        )

        dropButton.addTarget(
            self,
            action: #selector(dropTapped),
            for: .touchUpInside
        )
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

    // MARK: - UI Update
    func configure(consumedML: Int,
                   goal: Double,
                   cupSize: Int) {

        let consumedLiters = Double(consumedML) / 1000.0
        let remainingLiters = max(goal - consumedLiters, 0)

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
    }
}
