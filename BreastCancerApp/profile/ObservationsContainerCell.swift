import UIKit

final class ObservationsContainerCell: UICollectionViewCell {

    @IBOutlet private weak var headerLabel: UILabel?
    @IBOutlet private weak var lumpsSwitch: UISwitch!
    @IBOutlet private weak var skinChangesButton: UIButton!
    @IBOutlet private weak var nippleChangesButton: UIButton!
    @IBOutlet private weak var painButton: UIButton!
    @IBOutlet private weak var sizeSwitch: UISwitch!

    var selectedSkinChange: String?
    var selectedNippleChange: String?
    var selectedPainLevel: String?

    var onSelectionChanged: ((Bool) -> Void)?

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

        if let headerLabel {
            headerLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            headerLabel.text = "Observations"
            headerLabel.textColor = UIColor(named: "mutedHeader") ?? .gray
        }

        lumpsSwitch.isOn = false
        sizeSwitch.isOn = false

        selectedSkinChange = "None"
        selectedNippleChange = "None"
        selectedPainLevel = "None"

        configureButtonDefaults()
        configureMenus()
        notifySelectionChange()
    }

    @IBAction private func lumpsSwitchChanged(_ sender: UISwitch) {
        saveObservation(key: "lumps", value: sender.isOn)
        notifySelectionChange()
    }

    @IBAction private func sizeSwitchChanged(_ sender: UISwitch) {
        saveObservation(key: "sizeChange", value: sender.isOn)
        notifySelectionChange()
    }

    @IBAction private func skinChangesTapped(_ sender: UIButton) {
        presentActionSheet(title: "Skin Changes", options: skinOptions) { [weak self] value in
            self?.applySkinSelection(value)
        }
    }

    @IBAction private func nippleChangesTapped(_ sender: UIButton) {
        presentActionSheet(title: "Nipple changes", options: nippleOptions) { [weak self] value in
            self?.applyNippleSelection(value)
        }
    }

    @IBAction private func painTapped(_ sender: UIButton) {
        presentActionSheet(title: "Pain / Tenderness", options: painOptions) { [weak self] value in
            self?.applyPainSelection(value)
        }
    }

    private func applySkinSelection(_ option: String) {
        selectedSkinChange = option
        skinChangesButton.setTitle(option, for: .normal)
        skinChangesButton.setTitleColor(
            option == "None" ? (UIColor(named: "mutedText") ?? .systemGray) : (UIColor(named: "pink") ?? .systemPink),
            for: .normal
        )
        saveObservation(key: "skinChanges", value: option)
        notifySelectionChange()
    }

    private func applyNippleSelection(_ option: String) {
        selectedNippleChange = option
        nippleChangesButton.setTitle(option, for: .normal)
        nippleChangesButton.setTitleColor(
            option == "None" ? (UIColor(named: "mutedText") ?? .systemGray) : (UIColor(named: "pink") ?? .systemPink),
            for: .normal
        )
        saveObservation(key: "nippleChanges", value: option)
        notifySelectionChange()
    }

    private func applyPainSelection(_ option: String) {
        selectedPainLevel = option
        painButton.setTitle(option, for: .normal)
        painButton.setTitleColor(
            option == "None" ? (UIColor(named: "mutedText") ?? .systemGray) : (UIColor(named: "pink") ?? .systemPink),
            for: .normal
        )
        saveObservation(key: "pain", value: option)
        notifySelectionChange()
    }

    private func hasSelectedSymptom() -> Bool {
        let skin = selectedSkinChange ?? "None"
        let nipple = selectedNippleChange ?? "None"
        let pain = selectedPainLevel ?? "None"

        return lumpsSwitch.isOn ||
               sizeSwitch.isOn ||
               skin != "None" ||
               nipple != "None" ||
               pain != "None"
    }

    private func notifySelectionChange() {
        onSelectionChanged?(hasSelectedSymptom())
    }

    private func configureMenus() {
        if #available(iOS 14.0, *) {
            skinChangesButton.menu = UIMenu(
                title: "",
                children: skinOptions.map { option in
                    UIAction(title: option) { [weak self] _ in
                        self?.applySkinSelection(option)
                    }
                }
            )
            skinChangesButton.showsMenuAsPrimaryAction = true

            nippleChangesButton.menu = UIMenu(
                title: "",
                children: nippleOptions.map { option in
                    UIAction(title: option) { [weak self] _ in
                        self?.applyNippleSelection(option)
                    }
                }
            )
            nippleChangesButton.showsMenuAsPrimaryAction = true

            painButton.menu = UIMenu(
                title: "",
                children: painOptions.map { option in
                    UIAction(title: option) { [weak self] _ in
                        self?.applyPainSelection(option)
                    }
                }
            )
            painButton.showsMenuAsPrimaryAction = true
        }
    }

    private func configureButtonDefaults() {
        let mutedColor = UIColor(named: "mutedText") ?? .systemGray

        skinChangesButton.setTitle("None", for: .normal)
        skinChangesButton.setTitleColor(mutedColor, for: .normal)

        nippleChangesButton.setTitle("None", for: .normal)
        nippleChangesButton.setTitleColor(mutedColor, for: .normal)

        painButton.setTitle("None", for: .normal)
        painButton.setTitleColor(mutedColor, for: .normal)
    }

    private func saveObservation(key: String, value: Any) {
        var dict = UserDefaults.standard.dictionary(forKey: "latestObservations") ?? [:]
        dict[key] = value
        UserDefaults.standard.set(dict, forKey: "latestObservations")
    }

    private func presentActionSheet(
        title: String,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )

        options.forEach { option in
            alert.addAction(
                UIAlertAction(title: option, style: .default) { _ in
                    onSelect(option)
                }
            )
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let vc = firstAvailableViewController() {
            if let popover = alert.popoverPresentationController {
                popover.sourceView = contentView
                popover.sourceRect = contentView.bounds
            }
            vc.present(alert, animated: true)
        }
    }

    private func firstAvailableViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController { return vc }
            responder = next
        }
        return nil
    }

    func currentObservationSnapshot() -> [String: Any] {
        [
            "lumps": lumpsSwitch.isOn,
            "skinChanges": selectedSkinChange
                ?? skinChangesButton.title(for: .normal)
                ?? "None",
            "nippleChanges": selectedNippleChange
                ?? nippleChangesButton.title(for: .normal)
                ?? "None",
            "sizeChange": sizeSwitch.isOn,
            "pain": selectedPainLevel
                ?? painButton.title(for: .normal)
                ?? "None"
        ]
    }
}

extension ObservationsContainerCell: ObservationsCollector {

    func collectObservations() -> [ObservationItem] {
        let snap = currentObservationSnapshot()

        return [
            ObservationItem(
                title: "Lumps/Thickening",
                value: (snap["lumps"] as? Bool) == true ? "Yes" : "No"
            ),
            ObservationItem(
                title: "Size/shape changes",
                value: (snap["sizeChange"] as? Bool) == true ? "Yes" : "No"
            ),
            ObservationItem(
                title: "Skin changes",
                value: snap["skinChanges"] as? String ?? "None"
            ),
            ObservationItem(
                title: "Nipple changes",
                value: snap["nippleChanges"] as? String ?? "None"
            ),
            ObservationItem(
                title: "Pain/Tenderness",
                value: snap["pain"] as? String ?? "None"
            )
        ]
    }
}
