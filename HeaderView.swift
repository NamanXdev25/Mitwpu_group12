//
//  HeaderView.swift
//  ChemoCompanion
//
//  Created by ChemoCompanion Dev on 28/11/25.
//

import UIKit

class HeaderView: UICollectionReusableView {
    /// OUTLET
    @IBOutlet var titleLabel: UILabel!

    func configureHeader(text: String) {
        titleLabel.text = text
    }
}
