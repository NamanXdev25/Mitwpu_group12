import UIKit

class TreatmentCell: UICollectionViewCell {

    @IBOutlet weak var treatmentTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var addPhaseButton: UIButton!

    var onCellHeightChanged: (() -> Void)?
    var onSaveButtonTapped: ((TreatmentPhaseModel, Int) -> Void)?
    /// Called when all phases are completed and the overall badge goes Completed.
    var onAllPhasesCompleted: ((String) -> Void)?
    /// Called when a phase is deleted / edit reverted, dropping back below Completed.
    var onTreatmentReset: (() -> Void)?

    /// Called whenever a phase's STATUS changes — VC updates its savedPhaseStates.
    var onPhaseStatusChanged: ((Int, PhaseStatus) -> Void)?
    /// Called when + Add Phase is tapped — VC appends a new SavedPhaseState.
    var onPhaseAdded: (() -> Void)?
    /// Called when a phase is deleted — VC removes from savedPhaseStates at that index.
    var onPhaseDeleted: ((Int) -> Void)?
    /// Called whenever any field value inside a phase changes (before Save) — VC caches it.
    var onPhaseFieldsChanged: ((Int, TreatmentType, Date?, String) -> Void)?

    private var phaseViews: [TreatmentPhaseView] = []
    private var phaseStatuses: [Int: PhaseStatus] = [:]
    private var wasCompleted = false
    private var lockOverlayView: UIView?

    private let lightPink           = UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)
    private let inProgressTextColor = UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let completedGreenColor = UIColor(red: 0.2,  green: 0.6,  blue: 0.2,  alpha: 1.0)
    private let completedGreenBg    = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
    private let notStartedTextColor = UIColor(red: 0.4,  green: 0.4,  blue: 0.4,  alpha: 1.0)
    private let notStartedBg        = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)

    private let phaseHeight: CGFloat  = 285
    private let phaseSpacing: CGFloat = 12

    private let phasesContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private var containerHeightConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    private func setupCell() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        applyBadge(.notStarted)
        addPhaseButton.tintColor = UIColor(named: "pink")
        addPhaseButton.setBackgroundImage(imageWithColor(.white), for: .normal)
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

    // MARK: - Reuse restore
    /// Called from cellForItemAt every time this cell is dequeued.
    /// Tears down leftover phase views and rebuilds entirely from VC-owned state.
    func restoreState(phases: [SavedPhaseState], badgeStatus: PhaseStatus) {
        phaseViews.forEach { $0.removeFromSuperview() }
        phaseViews    = []
        phaseStatuses = [:]
        wasCompleted  = (badgeStatus == .completed)

        for (i, saved) in phases.enumerated() {
            addPhaseViewInternal(index: i, initialStatus: saved.status, savedState: saved)
        }

        applyBadge(badgeStatus)
        // Ensure containerHeightConstraint is accurate so getCellHeight() returns
        // the correct value when the VC reads it synchronously right after restoreState.
        rebuildContainerHeight()
    }

    // MARK: - Lock Overlay
    func setLocked(_ locked: Bool) {
        locked ? showLockOverlay() : removeLockOverlay()
    }

    private func showLockOverlay() {
        guard lockOverlayView == nil else { return }
        let overlay = UIView()
        overlay.backgroundColor = UIColor.white.withAlphaComponent(0.65)
        overlay.layer.cornerRadius = 16
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isUserInteractionEnabled = true

        let lockImage = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockImage.tintColor = UIColor(white: 0.5, alpha: 1)
        lockImage.contentMode = .scaleAspectFit
        lockImage.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(lockImage)
        NSLayoutConstraint.activate([
            lockImage.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            lockImage.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            lockImage.widthAnchor.constraint(equalToConstant: 28),
            lockImage.heightAnchor.constraint(equalToConstant: 28)
        ])

        contentView.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        lockOverlayView = overlay
    }

    private func removeLockOverlay() {
        lockOverlayView?.removeFromSuperview()
        lockOverlayView = nil
    }

    private func imageWithColor(_ color: UIColor) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }

    // MARK: - Add Phase (user-initiated via + button)
    @IBAction func addPhaseTapped(_ sender: UIButton) {
        let index = phaseViews.count
        phaseStatuses[index] = .notStarted
        addPhaseViewInternal(index: index, initialStatus: .notStarted, savedState: nil)
        onPhaseAdded?()
        rebuildContainerHeight()
        onCellHeightChanged?()
    }

    // MARK: - Internal phase view builder
    /// `savedState` is non-nil when restoring after cell reuse; nil when user taps + Add Phase.
    private func addPhaseViewInternal(index: Int, initialStatus: PhaseStatus, savedState: SavedPhaseState?) {
        guard let phaseView = Bundle.main.loadNibNamed("TreatmentPhaseView", owner: nil, options: nil)?.first as? TreatmentPhaseView else { return }

        phaseStatuses[index] = initialStatus
        phaseView.translatesAutoresizingMaskIntoConstraints = false
        phaseView.configure(index: index)

        // ── Restore field values so unsaved input survives cell reuse ──
        if let saved = savedState {
            if saved.isSaved, let model = saved.model {
                // Phase was fully saved — restore the complete saved model
                phaseView.restoreSavedModel(model)
            } else if saved.treatmentType != .none || saved.startDate != nil || !saved.duration.isEmpty {
                // Phase had in-progress unsaved input — restore raw field values
                phaseView.restoreFields(
                    treatmentType: saved.treatmentType,
                    startDate:     saved.startDate,
                    duration:      saved.duration
                )
            }
        }

        // ── Wire callbacks ──
        phaseView.onStatusChanged = { [weak self] status in
            guard let self else { return }
            guard index < self.phaseViews.count else { return }
            self.phaseStatuses[index] = status
            self.onPhaseStatusChanged?(index, status)
            self.recomputeOverallBadge()
        }

        phaseView.onDeleteTapped = { [weak self] in
            guard let self else { return }
            self.deletePhase(phaseView)
        }

        // Relay field changes up to VC so it can cache unsaved input in savedPhaseStates
        phaseView.onFieldsChanged = { [weak self] type, startDate, duration in
            guard let self else { return }
            guard let idx = self.phaseViews.firstIndex(of: phaseView) else { return }
            self.onPhaseFieldsChanged?(idx, type, startDate, duration)
        }

        // Relay save up to VC
        phaseView.onSaved = { [weak self] in
            guard let self else { return }
            guard let idx = self.phaseViews.firstIndex(of: phaseView) else { return }
            // Build and relay the saved model
            var model = TreatmentPhaseModel()
            model.treatmentType = phaseView.currentTreatmentType()
            model.startDate     = phaseView.currentStartDate()
            model.duration      = phaseView.currentDuration()
            model.state         = .saved
            self.onSaveButtonTapped?(model, idx)
        }

        // Add to container
        phasesContainerView.addSubview(phaseView)
        if let last = phaseViews.last {
            NSLayoutConstraint.activate([
                phaseView.topAnchor.constraint(equalTo: last.bottomAnchor, constant: phaseSpacing),
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
        rebuildContainerHeight()
    }

    // MARK: - Delete Phase
    private func deletePhase(_ phaseView: TreatmentPhaseView) {
        guard phaseViews.contains(phaseView) else { return }

        UIView.animate(withDuration: 0.25, animations: {
            phaseView.alpha = 0
        }) { _ in
            guard let idx = self.phaseViews.firstIndex(of: phaseView) else { return }

            let statusesCopy = self.phaseStatuses
            phaseView.removeFromSuperview()
            self.phaseViews.remove(at: idx)

            var newStatuses: [Int: PhaseStatus] = [:]
            for i in 0 ..< self.phaseViews.count {
                let oldKey = i < idx ? i : i + 1
                newStatuses[i] = statusesCopy[oldKey] ?? .notStarted
            }
            self.phaseStatuses = newStatuses

            for (i, view) in self.phaseViews.enumerated() {
                view.configure(index: i)
            }

            self.onPhaseDeleted?(idx)
            self.rebuildPhaseConstraints()
            self.rebuildContainerHeight()
            self.recomputeOverallBadge()
            self.onCellHeightChanged?()
        }
    }

    private func rebuildPhaseConstraints() {
        phasesContainerView.subviews.forEach { $0.removeFromSuperview() }

        for (i, view) in phaseViews.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.alpha = 1.0
            phasesContainerView.addSubview(view)

            if i == 0 {
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: phasesContainerView.topAnchor),
                    view.leadingAnchor.constraint(equalTo: phasesContainerView.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: phasesContainerView.trailingAnchor),
                    view.heightAnchor.constraint(equalToConstant: phaseHeight)
                ])
            } else {
                let prev = phaseViews[i - 1]
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: phaseSpacing),
                    view.leadingAnchor.constraint(equalTo: phasesContainerView.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: phasesContainerView.trailingAnchor),
                    view.heightAnchor.constraint(equalToConstant: phaseHeight)
                ])
            }
        }
    }

    private func rebuildContainerHeight() {
        let count = CGFloat(phaseViews.count)
        containerHeightConstraint?.constant = count == 0 ? 0 : (count * phaseHeight) + ((count - 1) * phaseSpacing)
    }

    // MARK: - Badge
    private func recomputeOverallBadge() {
        guard !phaseViews.isEmpty else {
            applyBadge(.notStarted)
            if wasCompleted { wasCompleted = false; onTreatmentReset?() }
            return
        }

        guard phaseStatuses.count == phaseViews.count else { return }

        let statuses = Array(phaseStatuses.values)
        if statuses.allSatisfy({ $0 == .completed }) {
            applyBadge(.completed)
            if !wasCompleted {
                wasCompleted = true
                let firstName = phaseViews.first.map { phaseName(from: $0) } ?? "Treatment"
                onAllPhasesCompleted?(firstName)
            }
        } else if statuses.contains(.inProgress) {
            applyBadge(.inProgress)
            if wasCompleted { wasCompleted = false; onTreatmentReset?() }
        } else {
            applyBadge(.notStarted)
            if wasCompleted { wasCompleted = false; onTreatmentReset?() }
        }
    }

    private func phaseName(from view: TreatmentPhaseView) -> String {
        return JourneyState.shared.currentTreatmentName
    }

    private func applyBadge(_ status: PhaseStatus) {
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10
        statusLabel.layer.masksToBounds = true
        UIView.animate(withDuration: 0.3) {
            switch status {
            case .notStarted:
                self.statusLabel.text            = "Not Started"
                self.statusLabel.backgroundColor = self.notStartedBg
                self.statusLabel.textColor       = self.notStartedTextColor
            case .inProgress:
                self.statusLabel.text            = "In Progress"
                self.statusLabel.backgroundColor = self.lightPink
                self.statusLabel.textColor       = self.inProgressTextColor
            case .completed:
                self.statusLabel.text            = "Completed"
                self.statusLabel.backgroundColor = self.completedGreenBg
                self.statusLabel.textColor       = self.completedGreenColor
            }
        }
    }

    func configure(with model: TreatmentModel) {
        model.status == "Completed" ? applyBadge(.completed) : applyBadge(.notStarted)
    }

    func getCellHeight() -> CGFloat {
        return 150 + (containerHeightConstraint?.constant ?? 0)
    }
}
