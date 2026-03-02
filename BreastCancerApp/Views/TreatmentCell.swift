import UIKit

class TreatmentCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var treatmentTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var addPhaseButton: UIButton!

    // MARK: - Callbacks
    var onCellHeightChanged: (() -> Void)?
    var onSaveButtonTapped: ((TreatmentPhaseModel, Int) -> Void)?

    // MARK: - Properties
    private var phases: [TreatmentPhaseModel] = []
    private var phaseViews: [TreatmentPhaseView] = []
    private let pink = UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let completedGreenColor = UIColor(red: 0.2,  green: 0.6,  blue: 0.2,  alpha: 1.0)
    private let completedGreenBg    = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)

    // MARK: - Constants
    private let phaseHeight: CGFloat = 390
    private let phaseSpacing: CGFloat = 12

    private let phasesContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var containerHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    // MARK: - Setup
    private func setupCell() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white

        statusLabel.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        statusLabel.layer.cornerRadius = 10
        statusLabel.layer.masksToBounds = true
        statusLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.textAlignment = .center
        statusLabel.text = "Not Started"

        addPhaseButton.tintColor = UIColor(named: "pink")
        addPhaseButton.setBackgroundImage(imageWithColor(.white), for: .normal)
        addPhaseButton.setBackgroundImage(imageWithColor(.white), for: .highlighted)
        addPhaseButton.setBackgroundImage(imageWithColor(.white), for: .selected)

        contentView.addSubview(phasesContainerView)
        NSLayoutConstraint.activate([
            phasesContainerView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            phasesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            phasesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            phasesContainerView.bottomAnchor.constraint(equalTo: addPhaseButton.topAnchor, constant: -12)
        ])

        containerHeightConstraint = phasesContainerView.heightAnchor.constraint(equalToConstant: 0)
        containerHeightConstraint?.isActive = true
    }

    private func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    // MARK: - IBActions
    @IBAction func addPhaseTapped(_ sender: UIButton) {
        addNewPhase()
    }

    // MARK: - Add Phase
    private func addNewPhase() {
        guard let phaseView = Bundle.main.loadNibNamed("TreatmentPhaseView", owner: nil, options: nil)?.first as? TreatmentPhaseView else {
            return
        }

        phaseView.translatesAutoresizingMaskIntoConstraints = false
        phaseView.configure(index: phaseViews.count)

        phaseView.onSaved = { [weak self] in
            self?.markCompleted()
        }

        phasesContainerView.addSubview(phaseView)

        if let lastPhase = phaseViews.last {
            NSLayoutConstraint.activate([
                phaseView.topAnchor.constraint(equalTo: lastPhase.bottomAnchor, constant: phaseSpacing),
                phaseView.leadingAnchor.constraint(equalTo: phasesContainerView.leadingAnchor),
                phaseView.trailingAnchor.constraint(equalTo: phasesContainerView.trailingAnchor),
                phaseView.heightAnchor.constraint(equalToConstant: phaseHeight)
            ])
        } else {
            NSLayoutConstraint.activate([
                phaseView.topAnchor.constraint(equalTo: phasesContainerView.topAnchor),
                phaseView.leadingAnchor.constraint(equalTo: phasesContainerView.leadingAnchor),
                phaseView.trailingAnchor.constraint(equalTo: phasesContainerView.trailingAnchor),
                phaseView.heightAnchor.constraint(equalToConstant: phaseHeight)
            ])
        }

        phaseViews.append(phaseView)

        // Fix: correct total height — n phases + (n-1) gaps
        let count = CGFloat(phaseViews.count)
        let totalHeight = (count * phaseHeight) + ((count - 1) * phaseSpacing)
        containerHeightConstraint?.constant = totalHeight

        onCellHeightChanged?()
    }

    // MARK: - Status Badge
    private func markCompleted() {
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = completedGreenBg
        statusLabel.textColor = completedGreenColor
    }

    // MARK: - Public Configure
    func configure(with model: TreatmentModel) {
        if model.status == "Completed" {
            markCompleted()
        } else {
            statusLabel.text = "Not Started"
            statusLabel.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
    }

    // MARK: - Height Helper
    func getCellHeight() -> CGFloat {
        let baseHeight: CGFloat = 150
        let phasesHeight = containerHeightConstraint?.constant ?? 0
        return baseHeight + phasesHeight
    }
}
