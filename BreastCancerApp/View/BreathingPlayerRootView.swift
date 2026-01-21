//
//  BreathingPlayerRootView.swift
//  BreastCancerApp
//
//  Created by Shloka on 16/12/25.
//
import UIKit

final class BreathingPlayerRootView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!

    func showBackground(animated: Bool = true) {
        let animations = {
            self.backgroundImageView.alpha = 1
        }

        animated
        ? UIView.animate(withDuration: 0.3, animations: animations)
        : animations()
    }

    func hideBackground(animated: Bool = true) {
        let animations = {
            self.backgroundImageView.alpha = 0
        }

        animated
        ? UIView.animate(withDuration: 0.5, animations: animations)
        : animations()
    }
}

