//
//  WelcomeViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var introImageView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //applyGradient()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let mask = CAGradientLayer()
        mask.frame = introImageView.bounds

        mask.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]

        mask.locations = [0.0, 0.45, 1.0]
        introImageView.layer.mask = mask
    }
    
//    private func applyGradient() {
//        gradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//
//        let gradient = CAGradientLayer()
//        gradient.frame = gradientView.bounds
//
//        gradient.colors = [
//            UIColor.clear.cgColor,
//            UIColor.white.cgColor
//        ]
//
//        gradient.locations = [0.0, 1.0]
//        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
//
//        gradientView.layer.addSublayer(gradient)
//    }
}
