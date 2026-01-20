import UIKit

final class HydrationTopCardCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var progressRingView: CircularProgressView!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var remainingLabel: UILabel!
    @IBOutlet private weak var dropButton: UIButton!
    @IBOutlet private weak var goalValueButton: UIButton!
    @IBOutlet private weak var cupValueButton: UIButton!

    // MARK: - Callbacks
    var onGoalTapped: (() -> Void)?
    var onCupTapped: (() -> Void)?
    var onDropTapped: (() -> Void)?

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
        let progress = goal > 0 ? CGFloat(consumedLiters / goal) : 0

        valueLabel.text = String(format: "%.1f L / %d mL", goal, cupSize)
        remainingLabel.text = String(format: "Remaining %.1f L", remainingLiters)

        goalValueButton.setTitle(String(format: "%.1f L", goal), for: .normal)
        cupValueButton.setTitle("\(cupSize) mL", for: .normal)

        progressRingView.setProgress(progress, animated: true)
    }

    // MARK: - Private
    private func configureProgressView() {
        progressRingView.lineWidth = 8
        progressRingView.trackColor = UIColor(white: 0.92, alpha: 1)
        progressRingView.progressColor = .systemPink
        progressRingView.backgroundColor = .clear
    }

    private func configureActions() {
        goalValueButton.addTarget(self, action: #selector(goalTapped), for: .touchUpInside)
        cupValueButton.addTarget(self, action: #selector(cupTapped), for: .touchUpInside)
        dropButton.addTarget(self, action: #selector(dropTapped), for: .touchUpInside)
    }

    @objc private func goalTapped() { onGoalTapped?() }
    @objc private func cupTapped() { onCupTapped?() }
    @objc private func dropTapped() { onDropTapped?() }
}
