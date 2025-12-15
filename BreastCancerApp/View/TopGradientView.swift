//
//  TopGradientView.swift
//  BreastCancerApp
//
//  Created by Shloka on 16/12/25.
//

import UIKit

import UIKit

final class TopGradientView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        isUserInteractionEnabled = false
        gradientLayer.colors = [
            UIColor(red: 0.6, green: 0.2, blue: 0.3, alpha: 0.85).cgColor,
            UIColor.clear.cgColor
        ]
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

