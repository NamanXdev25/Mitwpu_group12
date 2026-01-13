//
//  ProgressBarView.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class ProgressBarView: UIView {
    
    // MARK: - Properties
    private var contentView: UIView!
    private var progressFillView: UIView?
    private var progressWidthConstraint: NSLayoutConstraint?
    
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
        // Load the XIB
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ProgressBarView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        guard contentView != nil else { return }
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        // Get reference to progress fill view (the one with tag 100)
        progressFillView = contentView.viewWithTag(100)
        
        // Find the width constraint
        if let fillView = progressFillView {
            progressWidthConstraint = fillView.constraints.first(where: { $0.firstAttribute == .width })
        }
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        // progress should be between 0.0 and 1.0
        let clampedProgress = max(0, min(1, progress))
        let targetWidth = self.bounds.width * clampedProgress
        
        progressWidthConstraint?.constant = targetWidth
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
    
    // Convenience method for step-based progress
    func setProgress(currentStep: Int, totalSteps: Int, animated: Bool = true) {
        let progress = CGFloat(currentStep) / CGFloat(totalSteps)
        setProgress(progress, animated: animated)
    }
}
