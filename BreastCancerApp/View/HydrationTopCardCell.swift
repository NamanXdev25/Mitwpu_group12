import UIKit

final class HydrationTopCardCell: UICollectionViewCell {

    @IBOutlet private weak var progressRingView: CircularProgressView!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var remainingLabel: UILabel!
    @IBOutlet private weak var dropButton: UIButton!
    @IBOutlet private weak var goalValueButton: UIButton!
    @IBOutlet private weak var cupValueButton: UIButton!

    var onGoalTapped: (() -> Void)?
    var onCupTapped: (() -> Void)?
    var onDropTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupProgressView()
        setupActions()
    }

    private func setupProgressView() {
        progressRingView.lineWidth = 8
        progressRingView.trackColor = UIColor(white: 0.92, alpha: 1.0)
        progressRingView.progressColor = .bg
        progressRingView.backgroundColor = .clear
    }

    private func setupActions() {
        goalValueButton.addTarget(self, action: #selector(goalTapped), for: .touchUpInside)
        cupValueButton.addTarget(self, action: #selector(cupTapped), for: .touchUpInside)
        dropButton.addTarget(self, action: #selector(dropTapped), for: .touchUpInside)
    }

    @objc private func goalTapped() {
        onGoalTapped?()
    }

    @objc private func cupTapped() {
        onCupTapped?()
    }

    @objc private func dropTapped() {
        onDropTapped?()
    }

    func configure(consumedML: Int, goal: Double, cupSize: Int) {
        let consumedLiters = Double(consumedML) / 1000.0
        let remainingLiters = max(goal - consumedLiters, 0)
        let progress = goal > 0 ? CGFloat(consumedLiters / goal) : 0

        valueLabel.text = String(format: "%.1f L / %d mL", goal, cupSize)
        remainingLabel.text = String(format: "Remaining %.1f L", remainingLiters)

        goalValueButton.setTitle(String(format: "%.1f L", goal), for: .normal)
        cupValueButton.setTitle("\(cupSize) mL", for: .normal)

        progressRingView.setProgress(progress, animated: true)
    }
}
