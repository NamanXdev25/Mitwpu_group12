import UIKit

final class MonthYearPickerViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!

    var onApply: ((Int, Int) -> Void)?

    private let months = Calendar.current.monthSymbols
    private let years = Array(2000...Calendar.current.component(.year, from: Date()))

    private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self

        pickerView.selectRow(selectedMonth - 1, inComponent: 0, animated: false)

        if let index = years.firstIndex(of: selectedYear) {
            pickerView.selectRow(index, inComponent: 1, animated: false)
        }
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func applyTapped(_ sender: UIButton) {
        onApply?(selectedMonth, selectedYear)
        dismiss(animated: true)
    }
}

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
        component == 0 ? months[row] : "\(years[row])"
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        if component == 0 {
            selectedMonth = row + 1
        } else {
            selectedYear = years[row]
        }
    }
}
