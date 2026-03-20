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
        if let stack = contentView.subviews.first?.subviews.compactMap({ $0 as? UIStackView }).first {
            let buttonCount = CGFloat(7)
            let buttonWidth = CGFloat(35)
            let availableWidth = UIScreen.main.bounds.width - 32 - 32
            let spacing = (availableWidth - buttonCount * buttonWidth) / (buttonCount - 1)
            stack.spacing = max(4, spacing)
        }
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
            config.baseBackgroundColor = selected ? primary : .clear
            config.baseForegroundColor = selected ? .white : primary
            btn.configuration = config
        }
    }
}
