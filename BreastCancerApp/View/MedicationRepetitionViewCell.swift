//
//  MedicationRepetitionViewCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 20/03/26.
//

import UIKit

class MedicationRepetitionViewCell: UICollectionViewCell {

    @IBOutlet weak var everyDayButton: UIButton!
    @IBOutlet weak var customButton: UIButton!

    var onRepeatChanged: ((Bool) -> Void)?

    private var isCustom = false

    func configure(isCustom: Bool) {
        self.isCustom = isCustom
        updateButtonStates()
    }

    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        let wasCustom = isCustom
        isCustom = (sender === customButton)
        updateButtonStates()
        if wasCustom != isCustom {
            onRepeatChanged?(isCustom)
        }
    }

    private func updateButtonStates() {
        let primary = UIColor(named: "primary_color")

        var edConfig = everyDayButton.configuration ?? UIButton.Configuration.filled()
        edConfig.baseBackgroundColor = isCustom ? .white : primary
        edConfig.baseForegroundColor = isCustom ? .black : .white
        everyDayButton.configuration = edConfig

        var cuConfig = customButton.configuration ?? UIButton.Configuration.filled()
        cuConfig.baseBackgroundColor = isCustom ? primary : .white
        cuConfig.baseForegroundColor = isCustom ? .white : .black
        customButton.configuration = cuConfig
    }
}
