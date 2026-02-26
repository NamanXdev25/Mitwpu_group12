//
//  TreatmentOptionView.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class TreatmentOptionView: UIView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    
    var isSelectedOption: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TreatmentOptionView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        // initial state
        updateSelectionState()
    }
    
    @objc private func handleTap() {
        onTap?()
    }
    
    private func updateSelectionState() {
        if isSelectedOption {
            contentView.borderWidth = 2
            contentView.borderColor = UIColor(named: "OnboardingPrimaryColor")
            checkmarkImageView.isHidden = false
        } else {
            contentView.borderWidth = 0
            contentView.borderColor = nil
            checkmarkImageView.isHidden = true
        }
    }
}
