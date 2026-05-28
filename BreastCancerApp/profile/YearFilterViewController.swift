import UIKit

final class YearFilterViewController: UIViewController {
    @IBOutlet private var pickerView: UIPickerView!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var doneButton: UIButton!

    /// Earliest year where logs exist (set by caller)
    // swiftlint:disable:next implicitly_unwrapped_optional
    var earliestLogYear: Int!

    /// Optional preselected year
    var selectedYear: Int?

    /// Callback
    var onYearSelected: ((Int) -> Void)?

    /// Internal data source
    private var years: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupPicker()
        buildYears()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectInitialYearIfNeeded()
    }

    private func setupPicker() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }

    /// Build years from earliest log year → current year
    private func buildYears() {
        let currentYear = Calendar.current.component(.year, from: Date())

        guard earliestLogYear <= currentYear else {
            years = [currentYear]
            return
        }

        years = Array(earliestLogYear ... currentYear)
        pickerView.reloadAllComponents()
    }

    private func selectInitialYearIfNeeded() {
        let yearToSelect = selectedYear ?? years.last

        guard
            let year = yearToSelect,
            let index = years.firstIndex(of: year)
        else { return }

        pickerView.selectRow(index, inComponent: 0, animated: false)
    }

    // MARK: - Actions

    @IBAction private func cancelTapped(_: UIButton) {
        dismiss(animated: true)
    }

    @IBAction private func doneTapped(_: UIButton) {
        let row = pickerView.selectedRow(inComponent: 0)
        guard row >= 0, row < years.count else {
            dismiss(animated: true)
            return
        }

        onYearSelected?(years[row])
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource

extension YearFilterViewController: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(
        _: UIPickerView,
        numberOfRowsInComponent _: Int
    ) -> Int {
        return years.count
    }
}

// MARK: - UIPickerViewDelegate

extension YearFilterViewController: UIPickerViewDelegate {
    func pickerView(
        _: UIPickerView,
        titleForRow row: Int,
        forComponent _: Int
    ) -> String? {
        return "\(years[row])"
    }
}
