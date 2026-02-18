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
    
    // Container to hold phase views
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
        
        // Add phases container between separator and button
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
        print("➕ Add phase tapped")
        addNewPhase()
    }
    
    // MARK: - Add Phase
    private func addNewPhase() {
        // Load phase view from XIB
        guard let phaseView = Bundle.main.loadNibNamed("TreatmentPhaseView", owner: nil, options: nil)?.first as? TreatmentPhaseView else {
            print("❌ Failed to load TreatmentPhaseView from XIB")
            return
        }
        
        phaseView.translatesAutoresizingMaskIntoConstraints = false
        phaseView.configure(index: phaseViews.count)
        
        // Add to container
        phasesContainerView.addSubview(phaseView)
        
        // Position it below previous phase or at top
        if let lastPhase = phaseViews.last {
            NSLayoutConstraint.activate([
                phaseView.topAnchor.constraint(equalTo: lastPhase.bottomAnchor, constant: 12),
                phaseView.leadingAnchor.constraint(equalTo: phasesContainerView.leadingAnchor),
                phaseView.trailingAnchor.constraint(equalTo: phasesContainerView.trailingAnchor),
                phaseView.heightAnchor.constraint(equalToConstant: 450)
            ])
        } else {
            NSLayoutConstraint.activate([
                phaseView.topAnchor.constraint(equalTo: phasesContainerView.topAnchor),
                phaseView.leadingAnchor.constraint(equalTo: phasesContainerView.leadingAnchor),
                phaseView.trailingAnchor.constraint(equalTo: phasesContainerView.trailingAnchor),
                phaseView.heightAnchor.constraint(equalToConstant: 450)
            ])
        }
        
        phaseViews.append(phaseView)
        
        // Update container height
        let totalHeight = CGFloat(phaseViews.count) * 450 + CGFloat(phaseViews.count - 1) * 12
        containerHeightConstraint?.constant = totalHeight
        
        // Notify VC to update cell height
        onCellHeightChanged?()
    }

    // MARK: - Public Configure
    func configure(with model: TreatmentModel) {
        statusLabel.text = model.status
    }

    // MARK: - Height Helper
    func getCellHeight() -> CGFloat {
        let baseHeight: CGFloat = 130
        let phasesHeight = containerHeightConstraint?.constant ?? 0
        return baseHeight + phasesHeight
    }
}
