//
//  TreatmentOptionView.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class TreatmentOptionView: UIView {
    
    // MARK: - Outlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    
    // MARK: - Properties
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
    
    // Callback for when tapped
    var onTap: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Load XIB
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TreatmentOptionView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        // Initial state
        updateSelectionState()
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        onTap?()
    }
    
    // MARK: - Private Methods
    private func updateSelectionState() {
        if isSelectedOption {
            contentView.borderWidth = 2
            contentView.borderColor = UIColor(named: "PrimaryPink")
            checkmarkImageView.isHidden = false
        } else {
            contentView.borderWidth = 0
            contentView.borderColor = nil
            checkmarkImageView.isHidden = true
        }
    }
}
