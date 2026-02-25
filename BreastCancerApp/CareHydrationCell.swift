import UIKit

protocol CareHydrationCellDelegate: AnyObject {
    func careHydrationCellDidTapGoal(_ cell: CareHydrationCell)
    func careHydrationCellDidTapCupSize(_ cell: CareHydrationCell)
    func careHydrationCell(_ cell: CareHydrationCell, didChangeCurrentAmountML amountML: Int)
}

class CareHydrationCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var detailContainerView: UIView!

    @IBOutlet weak var ViewStack: UIView!
    @IBOutlet weak var CupsizeLabel: UILabel!
    @IBOutlet weak var GoalLabel: UILabel!

    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var hydrationLabel: UILabel!
    @IBOutlet weak var currentProgressLabel: UILabel!
    @IBOutlet weak var dropIconImageView: UIImageView!

    @IBOutlet weak var goalValueLabel: UILabel!
    @IBOutlet weak var cupSizeValueLabel: UILabel!

    @IBOutlet weak var CupSizeChevronButton: UIButton!
    @IBOutlet weak var GoalChevronButton: UIButton!
    @IBOutlet weak var Hydrationstepper: UIStepper!

    // MARK: - Delegate
    weak var delegate: CareHydrationCellDelegate?

    // MARK: - State
    private var currentAmountML: Int = 2000
    private var goalML: Int = 3000
    private var cupSizeML: Int = 200
    private var lastStepperValue: Double = 0
    private let stepperTickML = 100



    override func awakeFromNib() {
        super.awakeFromNib()

        headerView.isHidden = false
        detailContainerView.isHidden = true
        detailContainerView.alpha = 0

        dropIconImageView.tintColor = .systemBlue
        dropIconImageView.image = UIImage(systemName: "drop.fill")

        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white

        headerView.layer.cornerRadius = 0
        detailContainerView.layer.cornerRadius = 0

        setupActions()
        setupStepper()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 20
    }

    private func setupActions() {
        GoalChevronButton.addTarget(self, action: #selector(goalTapped), for: .touchUpInside)
        CupSizeChevronButton.addTarget(self, action: #selector(cupTapped), for: .touchUpInside)
        Hydrationstepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)

        // Also open dropdown when value labels are tapped
        goalValueLabel.isUserInteractionEnabled = true
        cupSizeValueLabel.isUserInteractionEnabled = true
        goalValueLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goalTapped)))
        cupSizeValueLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cupTapped)))
    }

    private func setupStepper() {
        Hydrationstepper.minimumValue = 0
        Hydrationstepper.stepValue = 1 // 1 tick = 100 mL
        Hydrationstepper.autorepeat = true
        Hydrationstepper.wraps = false
    }

    @objc private func goalTapped() {
        delegate?.careHydrationCellDidTapGoal(self)
    }

    @objc private func cupTapped() {
        delegate?.careHydrationCellDidTapCupSize(self)
    }

    @objc private func stepperValueChanged(_ sender: UIStepper) {
        let delta = sender.value - lastStepperValue
        guard delta != 0 else { return }

        if delta > 0 {
            currentAmountML = min(currentAmountML + cupSizeML, goalML)
        } else {
            currentAmountML = max(currentAmountML - cupSizeML, 0)
        }

        // Re-sync from real ml so minus only disables at 0 mL
        configureStepperRange()
        render()
        delegate?.careHydrationCell(self, didChangeCurrentAmountML: currentAmountML)
    }




    // MARK: - Configure
    func configure(
        isExpanded: Bool,
        currentAmountML: Int,
        goalML: Int,
        cupSizeML: Int
    ) {
        self.goalML = max(goalML, 1)
        self.cupSizeML = max(cupSizeML, 1)
        self.currentAmountML = min(max(currentAmountML, 0), self.goalML)

        configureStepperRange()
        render()

        detailContainerView.isHidden = !isExpanded
        UIView.animate(withDuration: 0.25) {
            self.detailContainerView.alpha = isExpanded ? 1.0 : 0.0
            self.layoutIfNeeded()
        }
    }

    private func configureStepperRange() {
        let minTick = 0.0
        let maxTick = Double(goalML) / Double(stepperTickML)
        let currentTick = Double(currentAmountML) / Double(stepperTickML)

        Hydrationstepper.minimumValue = minTick
        Hydrationstepper.maximumValue = max(1, maxTick)
        Hydrationstepper.value = min(Hydrationstepper.maximumValue, max(Hydrationstepper.minimumValue, currentTick))
        lastStepperValue = Hydrationstepper.value
    }



    private func render() {
        goalValueLabel.text = formatGoal(goalML)
        cupSizeValueLabel.text = "\(cupSizeML) mL"

        let progress = CGFloat(Double(currentAmountML) / Double(goalML))
        progressView.progress = max(0, min(progress, 1))
        currentProgressLabel.text = "\(formatLiters(currentAmountML))/\(formatLiters(goalML)) Ltr"
    }

    private func formatGoal(_ ml: Int) -> String {
        String(format: "%.1f L", Double(ml) / 1000.0)
    }

    private func formatLiters(_ ml: Int) -> String {
        let liters = Double(ml) / 1000.0
        return liters.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(liters))
            : String(format: "%.1f", liters)
    }
}
