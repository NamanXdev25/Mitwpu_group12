import UIKit

class HydrationTopCardCell: UICollectionViewCell {

    @IBOutlet weak var progressRingView: CircularProgressView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var goalValueButton: UIButton!
    @IBOutlet weak var cupValueButton: UIButton!

    var onGoalTapped: (() -> Void)?
    var onCupTapped: (() -> Void)?
    var onDropTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        progressRingView.lineWidth = 8
        progressRingView.trackColor = UIColor(white: 0.92, alpha: 1.0)
        progressRingView.progressColor = UIColor.bg
        progressRingView.backgroundColor = .clear

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
        let progressValue = goal > 0 ? CGFloat(consumedLiters / goal) : 0

        
        valueLabel.text = String(format: "%.1f L / %d mL", goal, cupSize)

       
        remainingLabel.text = String(format: "Remaining %.1f L", remainingLiters)

       
        goalValueButton.setTitle(String(format: "%.1f L", goal), for: .normal)
        cupValueButton.setTitle("\(cupSize) mL", for: .normal)

        // Progress ring
        progressRingView.setProgress(progressValue, animated: true)
    }
}
