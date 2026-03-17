//
//  InsightsDatePickerViewController.swift
//  BreastCancerApp
//
//  Created by Shloka on 16/03/26.
//

import UIKit

final class InsightDatePickerViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!

    // MARK: - Callback
    var onApply: ((Date) -> Void)?
    var initialDate: Date?              // ← ADD THIS LINE

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupDatePicker()
    }

    private func setupDatePicker() {
        datePicker.datePickerMode           = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.maximumDate              = Date()
        datePicker.tintColor                = UIColor(named: "primary_color")
            ?? UIColor(named: "PrimaryColor")
            ?? .systemPink
        if let initial = initialDate {     // ← ADD THIS BLOCK
            datePicker.date = initial
        }
    }

    // MARK: - IBActions
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func applyTapped(_ sender: UIBarButtonItem) {
        onApply?(datePicker.date)
        dismiss(animated: true)
    }
}
