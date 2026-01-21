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
}
