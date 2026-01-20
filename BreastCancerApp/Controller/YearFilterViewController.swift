import UIKit

final class YearFilterViewController: UIViewController {

    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!

    var years: [Int] = [] {
        didSet {
            pickerView?.reloadAllComponents()
        }
    }

    var selectedYear: Int?
    var onYearSelected: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupPicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectInitialYearIfNeeded()
    }

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

    @IBAction private func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction private func doneTapped(_ sender: UIButton) {
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

extension YearFilterViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        years.count
    }
}

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
