//
//  TopGradientView.swift
//  BreastCancerApp
//
//  Created by Shloka on 16/12/25.
//

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
            UIColor(named: "primary_color")!.cgColor,
            UIColor.clear.cgColor
        ]
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

