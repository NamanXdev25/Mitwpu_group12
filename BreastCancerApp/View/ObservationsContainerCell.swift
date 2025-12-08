import UIKit

class ObservationsContainerCell: UICollectionViewCell {
    @IBOutlet weak var lumpsSwitch: UISwitch!
    @IBOutlet weak var skinChangesButton: UIButton!
    @IBOutlet weak var nippleChangesButton: UIButton!
    @IBOutlet weak var painButton: UIButton!
    @IBOutlet weak var sizeSwitch: UISwitch!

    private let skinOptions = [
        "None",
        "Dimpling/puckering",
        "Redness/unusual warmth",
        "Rash, soreness, skin irritation",
        "Changes in skin texture"
    ]

    private let nippleOptions = [
        "None",
        "Inverted",
        "Discharge",
        "Sores/ulcers"
    ]

    private let painOptions = [
        "None",
        "Mild",
        "Moderate",
        "Severe"
    ]

    override func awakeFromNib() {
        super.awakeFromNib()

        lumpsSwitch.accessibilityLabel = "Lumps or thickening"

        // restore saved values (safe defaults)
        let dict = UserDefaults.standard.dictionary(forKey: "latestObservations") ?? [:]
        let savedSkin = (dict["skinChanges"] as? String) ?? "None"
        let savedNipple = (dict["nippleChanges"] as? String) ?? "None"
        let savedPain = (dict["pain"] as? String) ?? "None"
        let savedSize = (dict["sizeChange"] as? Bool) ?? false
        let savedLumps = (dict["lumps"] as? Bool) ?? false

        skinChangesButton.setTitle(savedSkin, for: .normal)
        skinChangesButton.setTitleColor(UIColor(named: "mutedText") ?? .systemGray, for: .normal)

        nippleChangesButton.setTitle(savedNipple, for: .normal)
        nippleChangesButton.setTitleColor(UIColor(named: "mutedText") ?? .systemGray, for: .normal)

        painButton.setTitle(savedPain, for: .normal)
        painButton.setTitleColor(UIColor(named: "mutedText") ?? .systemGray, for: .normal)

        lumpsSwitch.isOn = savedLumps
        sizeSwitch.isOn = savedSize

        configureMenus()
    }

    // MARK: - Switch actions (connect Value Changed)
    @IBAction func lumpsSwitchChanged(_ sender: UISwitch) {
        saveObservation(key: "lumps", value: sender.isOn)
    }

    @IBAction func sizeSwitchChanged(_ sender: UISwitch) {
        saveObservation(key: "sizeChange", value: sender.isOn)
    }

    // optional fallback IBActions (connect Touch Up Inside if you prefer)
    @IBAction func skinChangesTapped(_ sender: UIButton) {
        // UIMenu shows automatically on iOS14+, fallback to action sheet for older OS
        presentActionSheet(title: "Skin Changes", options: skinOptions) { [weak self] v in
            self?.applySkinSelection(v)
        }
    }

    @IBAction func nippleChangesTapped(_ sender: UIButton) {
        presentActionSheet(title: "Nipple changes", options: nippleOptions) { [weak self] v in
            self?.applyNippleSelection(v)
        }
    }

    @IBAction func painTapped(_ sender: UIButton) {
        presentActionSheet(title: "Pain / Tenderness", options: painOptions) { [weak self] v in
            self?.applyPainSelection(v)
        }
    }

    // MARK: - Apply selections
    private func applySkinSelection(_ option: String) {
        skinChangesButton.setTitle(option, for: .normal)
        skinChangesButton.setTitleColor(UIColor(named: "pink") ?? .systemPink, for: .normal)
        saveObservation(key: "skinChanges", value: option)
    }

    private func applyNippleSelection(_ option: String) {
        nippleChangesButton.setTitle(option, for: .normal)
        nippleChangesButton.setTitleColor(UIColor(named: "pink") ?? .systemPink, for: .normal)
        saveObservation(key: "nippleChanges", value: option)
    }

    private func applyPainSelection(_ option: String) {
        painButton.setTitle(option, for: .normal)
        painButton.setTitleColor(UIColor(named: "pink") ?? .systemPink, for: .normal)
        saveObservation(key: "pain", value: option)
    }

    // MARK: - UIMenu configuration (native dropdown)
    private func configureMenus() {
        if #available(iOS 14.0, *) {
            skinChangesButton.menu = UIMenu(title: "", children: skinOptions.map { option in
                UIAction(title: option) { [weak self] _ in self?.applySkinSelection(option) }
            })
            skinChangesButton.showsMenuAsPrimaryAction = true

            nippleChangesButton.menu = UIMenu(title: "", children: nippleOptions.map { option in
                UIAction(title: option) { [weak self] _ in self?.applyNippleSelection(option) }
            })
            nippleChangesButton.showsMenuAsPrimaryAction = true

            painButton.menu = UIMenu(title: "", children: painOptions.map { option in
                UIAction(title: option) { [weak self] _ in self?.applyPainSelection(option) }
            })
            painButton.showsMenuAsPrimaryAction = true
        }
    }

    // MARK: - Helpers
    private func saveObservation(key: String, value: Any) {
        var dict = UserDefaults.standard.dictionary(forKey: "latestObservations") ?? [:]
        dict[key] = value
        UserDefaults.standard.set(dict, forKey: "latestObservations")
    }

    private func presentActionSheet(title: String, options: [String], onSelect: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for opt in options {
            ac.addAction(UIAlertAction(title: opt, style: .default) { _ in onSelect(opt) })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let vc = firstAvailableViewController() {
            if let pop = ac.popoverPresentationController {
                pop.sourceView = self.contentView
                pop.sourceRect = self.contentView.bounds
            }
            vc.present(ac, animated: true, completion: nil)
        }
    }

    private func firstAvailableViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController { return vc }
            responder = responder?.next
        }
        return nil
    }
}
