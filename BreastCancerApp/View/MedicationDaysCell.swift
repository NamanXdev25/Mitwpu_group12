//
//  MedicationDaysCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 20/03/26.
//

import UIKit

class MedicationDaysCell: UICollectionViewCell {

    @IBOutlet var dayButtons: [UIButton]!

    var onDaysChanged: ((Set<Int>) -> Void)?

    private var selectedDays = Set<Int>()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(selectedDays: Set<Int>) {
        self.selectedDays = selectedDays
        updateButtonStates()
    }

    @IBAction func dayButtonTapped(_ sender: UIButton) {
        guard let index = dayButtons.firstIndex(of: sender) else { return }
        let weekday = index + 1
        if selectedDays.contains(weekday) {
            selectedDays.remove(weekday)
        } else {
            selectedDays.insert(weekday)
        }
        updateButtonStates()
        onDaysChanged?(selectedDays)
    }

    private func updateButtonStates() {
        let primary = UIColor(named: "primary_color")
        for (index, btn) in dayButtons.enumerated() {
            let selected = selectedDays.contains(index + 1)
            let title = btn.configuration?.title ?? btn.title(for: .normal) ?? ""
            
            var config = selected ? UIButton.Configuration.filled() : UIButton.Configuration.plain()
            config.title = title
            config.cornerStyle = .capsule
            config.baseBackgroundColor = selected ? primary : primary?.withAlphaComponent(0.1)
            config.baseForegroundColor = selected ? .white : primary
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            btn.configuration = config
        }
    }
}
