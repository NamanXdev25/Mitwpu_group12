import UIKit

final class YearFilterViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    // MARK: - Data
    var years: [Int] = [] {
        didSet {
            pickerView?.reloadAllComponents()
        }
    }

    var selectedYear: Int?

    /// Callback to send selected year back
    var onYearSelected: ((Int) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupPicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Ensure picker selects correct row AFTER layout & reload
        selectInitialYearIfNeeded()
    }

    // MARK: - Setup
    private func setupPicker() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }

    private func selectInitialYearIfNeeded() {
        guard
            let selectedYear,
            let index = years.firstIndex(of: selectedYear),
            index < years.count
        else { return }

        pickerView.selectRow(index, inComponent: 0, animated: false)
    }

    // MARK: - Actions
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func doneTapped(_ sender: UIButton) {
        guard !years.isEmpty else {
            dismiss(animated: true)
            return
        }

        let row = pickerView.selectedRow(inComponent: 0)

        guard row >= 0, row < years.count else {
            dismiss(animated: true)
            return
        }

        let year = years[row]
        onYearSelected?(year)
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource
extension YearFilterViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        years.count
    }
}

// MARK: - UIPickerViewDelegate
extension YearFilterViewController: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        guard row < years.count else { return nil }
        return "\(years[row])"
    }
}
