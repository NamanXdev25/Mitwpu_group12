import UIKit

final class MonthYearPickerViewController: UIViewController {

    var onApply: ((Int, Int) -> Void)?

    private let picker = UIPickerView()
    private let months = Calendar.current.monthSymbols
    private let years = Array(2000...Calendar.current.component(.year, from: Date()))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        picker.dataSource = self
        picker.delegate = self

        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: 200)
        ])

        setupButtons()
    }

    private func setupButtons() {
        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let apply = UIButton(type: .system)
        apply.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        apply.tintColor = .pink
        apply.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        close.translatesAutoresizingMaskIntoConstraints = false
        apply.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(close)
        view.addSubview(apply)

        NSLayoutConstraint.activate([
            close.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            close.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            apply.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            apply.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func applyTapped() {
        let month = picker.selectedRow(inComponent: 0) + 1
        let year = years[picker.selectedRow(inComponent: 1)]
        dismiss(animated: true)
        onApply?(month, year)
    }
}

extension MonthYearPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? months.count : years.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        component == 0 ? months[row] : String(years[row])
    }
}
