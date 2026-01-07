//
// ObservationsContainerCell.swift
//

import UIKit

class ObservationsContainerCell: UICollectionViewCell {
  
    @IBOutlet weak var headerLabel: UILabel?       // optional; connect if present in nib
    @IBOutlet weak var lumpsSwitch: UISwitch!
    @IBOutlet weak var skinChangesButton: UIButton!
    @IBOutlet weak var nippleChangesButton: UIButton!
    @IBOutlet weak var painButton: UIButton!
    @IBOutlet weak var sizeSwitch: UISwitch!

    // Stored selection properties
    var selectedSkinChange: String?
    var selectedNippleChange: String?
    var selectedPainLevel: String?

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

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Keep a neat header if present
        if let header = headerLabel {
            header.font = .systemFont(ofSize: 17, weight: .semibold)
            header.text = "Observations"
            header.textColor = UIColor(named: "mutedHeader") ?? UIColor.gray
        }

        
        lumpsSwitch.isOn = false
        sizeSwitch.isOn = false

       
        var dict = UserDefaults.standard.dictionary(forKey: "latestObservations") ?? [:]
        dict["lumps"] = false
        dict["sizeChange"] = false
        UserDefaults.standard.set(dict, forKey: "latestObservations")

        // Restore default button values (unchanged behavior)
        selectedSkinChange = "None"
        selectedNippleChange = "None"
        selectedPainLevel = "None"

        skinChangesButton.setTitle("None", for: .normal)
        skinChangesButton.setTitleColor(UIColor(named: "mutedText") ?? .systemGray, for: .normal)

        nippleChangesButton.setTitle("None", for: .normal)
        nippleChangesButton.setTitleColor(UIColor(named: "mutedText") ?? .systemGray, for: .normal)

        painButton.setTitle("None", for: .normal)
        painButton.setTitleColor(UIColor(named: "mutedText") ?? .systemGray, for: .normal)

        // Ensure buttons show their menus (UIMenu)
        configureMenus()
    }

    // MARK: - Switch actions
    @IBAction func lumpsSwitchChanged(_ sender: UISwitch) {
        saveObservation(key: "lumps", value: sender.isOn)
    }

    @IBAction func sizeSwitchChanged(_ sender: UISwitch) {
        saveObservation(key: "sizeChange", value: sender.isOn)
    }

    @IBAction func skinChangesTapped(_ sender: UIButton) {
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
        selectedSkinChange = option
        skinChangesButton.setTitle(option, for: .normal)
        skinChangesButton.setTitleColor(UIColor(named: "pink") ?? .systemPink, for: .normal)
        saveObservation(key: "skinChanges", value: option)
    }

    private func applyNippleSelection(_ option: String) {
        selectedNippleChange = option
        nippleChangesButton.setTitle(option, for: .normal)
        nippleChangesButton.setTitleColor(UIColor(named: "pink") ?? .systemPink, for: .normal)
        saveObservation(key: "nippleChanges", value: option)
    }

    private func applyPainSelection(_ option: String) {
        selectedPainLevel = option
        painButton.setTitle(option, for: .normal)
        painButton.setTitleColor(UIColor(named: "pink") ?? .systemPink, for: .normal)
        saveObservation(key: "pain", value: option)
    }

    // MARK: - UIMenu configuration
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

    // Provide a dictionary snapshot for controller
    func currentObservationSnapshot() -> [String: Any] {
        return [
            "lumps": lumpsSwitch.isOn,
            "skinChanges": selectedSkinChange ?? skinChangesButton.title(for: .normal) ?? "None",
            "nippleChanges": selectedNippleChange ?? nippleChangesButton.title(for: .normal) ?? "None",
            "sizeChange": sizeSwitch.isOn,
            "pain": selectedPainLevel ?? painButton.title(for: .normal) ?? "None"
        ]
    }
}

// MARK: - ObservationsCollector
extension ObservationsContainerCell: ObservationsCollector {
    func collectObservations() -> [ObservationItem] {
        let snap = currentObservationSnapshot()
        return [
            ObservationItem(title: "Lumps/Thickening", value: (snap["lumps"] as? Bool) == true ? "Yes" : "No"),
            ObservationItem(title: "Size/shape changes", value: (snap["sizeChange"] as? Bool) == true ? "Yes" : "No"),
            ObservationItem(title: "Skin changes", value: snap["skinChanges"] as? String ?? "None"),
            ObservationItem(title: "Nipple changes", value: snap["nippleChanges"] as? String ?? "None"),
            ObservationItem(title: "Pain/Tenderness", value: snap["pain"] as? String ?? "None")
        ]
    }
}
