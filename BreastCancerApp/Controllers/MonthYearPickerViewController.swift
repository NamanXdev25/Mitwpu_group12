import UIKit

final class MonthYearPickerViewController: UIViewController {

    @IBOutlet private weak var pickerView: UIPickerView!

    var onApply: ((Int, Int) -> Void)?

    private let calendar = Calendar.current
    private lazy var months = calendar.monthSymbols
    private lazy var years = Array(2000...calendar.component(.year, from: Date()))

    private var selectedMonth = Calendar.current.component(.month, from: Date())
    private var selectedYear = Calendar.current.component(.year, from: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePickerView()
        selectInitialRows()
    }

    @IBAction private func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction private func applyTapped(_ sender: UIButton) {
        onApply?(selectedMonth, selectedYear)
        dismiss(animated: true)
    }
}

// MARK: - Picker Configuration
private extension MonthYearPickerViewController {

    func configurePickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }

    func selectInitialRows() {
        pickerView.selectRow(selectedMonth - 1, inComponent: 0, animated: false)

        if let yearIndex = years.firstIndex(of: selectedYear) {
            pickerView.selectRow(yearIndex, inComponent: 1, animated: false)
        }
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension MonthYearPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? months.count : years.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        component == 0 ? months[row] : String(years[row])
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        switch component {
        case 0:
            selectedMonth = row + 1
        case 1:
            selectedYear = years[row]
        default:
            break
        }
    }
}
