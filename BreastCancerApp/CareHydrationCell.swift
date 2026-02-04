//////
//////  CareHydrationCell.swift
//////  BreastCancerApp
//////
//////  Created by Naman Bhansali on 04/02/26.
//////
////
//import UIKit
//
//class CareHydrationCell: UICollectionViewCell {
//
//    // MARK: - Outlets
//       
//    @IBOutlet weak var headerView: UIView!
//    @IBOutlet weak var detailContainerView: UIView!
//       
//    @IBOutlet weak var ViewStack: UIView!
//    @IBOutlet weak var CupsizeLabel: UILabel!
//    @IBOutlet weak var GoalLabel: UILabel!
//    
//    // Header Components
//    @IBOutlet weak var progressView: CircularProgressView!
//    @IBOutlet weak var hydrationLabel: UILabel!
//    @IBOutlet weak var currentProgressLabel: UILabel!
//    @IBOutlet weak var dropIconImageView: UIImageView!
//       
//    // Detail Components (Expandable)
//    @IBOutlet weak var goalValueLabel: UILabel!
//    @IBOutlet weak var cupSizeValueLabel: UILabel!
//
//    @IBOutlet weak var CupSizeChevronButton: UIButton!
//    @IBOutlet weak var GoalChevronButton: UIButton!
//    @IBOutlet weak var Hydrationstepper: UIStepper!
//    
//    // MARK: - Properties
//    private var currentValue: Double = 0
//    private var maxValue: Double = 3.0
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        // Ensure the header starts visible
//        headerView.isHidden = false
//        detailContainerView.isHidden = true
//        detailContainerView.alpha = 0
//        
//        dropIconImageView.tintColor = .systemBlue
//        dropIconImageView.image = UIImage(systemName: "drop.fill")
//        
//        // Configure stepper
//        setupStepper()
//        
//        // Optional: Add card styling
//        self.contentView.layer.cornerRadius = 20
//        self.contentView.layer.masksToBounds = true
//        
//        // Ensure contentView doesn't clip subviews
//        self.contentView.clipsToBounds = false
//        
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//    }
//    
//    // MARK: - Stepper Setup
//    private func setupStepper() {
//        // Configure stepper range and increment
//        Hydrationstepper.minimumValue = 0
//        Hydrationstepper.maximumValue = 100
//        Hydrationstepper.stepValue = 1
//        Hydrationstepper.value = 0
//        Hydrationstepper.autorepeat = true
//        Hydrationstepper.wraps = false
//        
//        // Add action
//        Hydrationstepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
//        
//        // Bring stepper to front to ensure visibility
//        if let parentView = Hydrationstepper.superview {
//            parentView.bringSubviewToFront(Hydrationstepper)
//        }
//    }
//    
//    // MARK: - Stepper Action
//    @objc private func stepperValueChanged(_ sender: UIStepper) {
//        // Update the current hydration value
//        let stepValue = sender.value
//        
//        // Calculate new hydration amount (assuming each step = 200ml = 0.2L)
//        let incrementPerStep = 0.2
//        currentValue = stepValue * incrementPerStep
//        
//        // Update the progress label
//        let formattedValue = String(format: "%.1f", currentValue)
//        currentProgressLabel.text = "\(formattedValue)/\(String(format: "%.1f", maxValue)) L"
//        
//        // Update progress view
//        let progress = CGFloat(currentValue / maxValue)
//        progressView.progress = min(progress, 1.0)
//        
//        print("Hydration updated to: \(currentValue) L")
//    }
//
//    /**
//     Configures the hydration cell and handles the expansion animation.
//     */
//    func configure(isExpanded: Bool, progress: CGFloat, currentAmount: String, goal: String, cupSize: String) {
//        progressView.progress = progress
//        currentProgressLabel.text = currentAmount
//        goalValueLabel.text = goal
//        cupSizeValueLabel.text = cupSize
//        
//        // Extract current value from currentAmount string (e.g., "2/3 Ltr" -> 2.0)
//        if let slashIndex = currentAmount.firstIndex(of: "/"),
//           let value = Double(currentAmount[..<slashIndex].trimmingCharacters(in: .whitespaces)) {
//            currentValue = value
//            // Set stepper value (each step = 0.2L, so value/0.2)
//            Hydrationstepper.value = value / 0.2
//        }
//        
//        // Extract max value from goal
//        if let maxVal = Double(goal.replacingOccurrences(of: " L", with: "").trimmingCharacters(in: .whitespaces)) {
//            maxValue = maxVal
//        }
//        
//        // Toggle visibility
//        detailContainerView.isHidden = !isExpanded
//        
//        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
//            self.detailContainerView.alpha = isExpanded ? 1.0 : 0.0
//            self.layoutIfNeeded()
//            
//            // Ensure stepper is visible after animation
//            if isExpanded {
//                self.Hydrationstepper.superview?.bringSubviewToFront(self.Hydrationstepper)
//            }
//        }, completion: nil)
//    }
//}


import UIKit

class CareHydrationCell: UICollectionViewCell {

    // MARK: - Outlets
       
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var detailContainerView: UIView!
       
    @IBOutlet weak var ViewStack: UIView!
    @IBOutlet weak var CupsizeLabel: UILabel!
    @IBOutlet weak var GoalLabel: UILabel!
    
    // Header Components
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var hydrationLabel: UILabel!
    @IBOutlet weak var currentProgressLabel: UILabel!
    @IBOutlet weak var dropIconImageView: UIImageView!
       
    // Detail Components (Expandable)
    @IBOutlet weak var goalValueLabel: UILabel!
    @IBOutlet weak var cupSizeValueLabel: UILabel!

    @IBOutlet weak var CupSizeChevronButton: UIButton!
    @IBOutlet weak var GoalChevronButton: UIButton!
    @IBOutlet weak var Hydrationstepper: UIStepper!
    
    // MARK: - Properties
    private var currentValue: Double = 2.0
    private var maxValue: Double = 3.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Ensure the header starts visible
        headerView.isHidden = false
        detailContainerView.isHidden = true
        detailContainerView.alpha = 0
        
        dropIconImageView.tintColor = .systemBlue
        dropIconImageView.image = UIImage(systemName: "drop.fill")
        
        // Configure stepper
        setupStepper()
        
        // Card styling - only contentView should have corner radius
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .white
        
        // IMPORTANT: Remove corner radius from individual views
        headerView.layer.cornerRadius = 0
        detailContainerView.layer.cornerRadius = 0
        
        // Subtle shadow on the cell itself
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)
//        self.layer.shadowRadius = 4
//        self.layer.shadowOpacity = 0.05
//        self.layer.masksToBounds = false
        
        self.contentView.clipsToBounds = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update corner radius based on expansion state
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        // Only contentView should have corner radius
        // Individual subviews (headerView, detailContainerView) should have 0 corner radius
        headerView.layer.cornerRadius = 0
        detailContainerView.layer.cornerRadius = 0
        
        // Ensure contentView maintains its corner radius
        self.contentView.layer.cornerRadius = 20
    }
    
    // MARK: - Stepper Setup
    private func setupStepper() {
        // Configure stepper range and increment
        Hydrationstepper.minimumValue = 0
        Hydrationstepper.maximumValue = 15 // 15 steps * 0.2L = 3.0L
        Hydrationstepper.stepValue = 1
        Hydrationstepper.value = 10 // Default to 2.0L (10 * 0.2)
        Hydrationstepper.autorepeat = true
        Hydrationstepper.wraps = false
        
        // Add action
        Hydrationstepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        
        // Bring stepper to front
        if let parentView = Hydrationstepper.superview {
            parentView.bringSubviewToFront(Hydrationstepper)
        }
    }
    
    // MARK: - Stepper Action
    @objc private func stepperValueChanged(_ sender: UIStepper) {
        // Each step = 200ml = 0.2L
        let incrementPerStep = 0.2
        currentValue = sender.value * incrementPerStep
        
        // Update the progress label (format: "2/3 Ltr")
        let currentInt = Int(currentValue)
        let maxInt = Int(maxValue)
        currentProgressLabel.text = "\(currentInt)/\(maxInt) Ltr"
        
        // Update progress view
        let progress = CGFloat(currentValue / maxValue)
        progressView.progress = min(progress, 1.0)
        
        print("Hydration updated to: \(currentValue) L")
    }

    func configure(isExpanded: Bool, progress: CGFloat, currentAmount: String, goal: String, cupSize: String) {
        progressView.progress = progress
        currentProgressLabel.text = currentAmount
        goalValueLabel.text = goal
        cupSizeValueLabel.text = cupSize
        
        // Extract current value from currentAmount string (e.g., "2/3 Ltr" -> 2.0)
        let components = currentAmount.components(separatedBy: "/")
        if components.count > 0,
           let value = Double(components[0].trimmingCharacters(in: .whitespaces)) {
            currentValue = value
            // Set stepper value (each step = 0.2L, so value/0.2)
            Hydrationstepper.value = value / 0.2
        }
        
        // Extract max value from goal
        if let maxVal = Double(goal.replacingOccurrences(of: " L", with: "").trimmingCharacters(in: .whitespaces)) {
            maxValue = maxVal
        }
        
        // Toggle visibility
        detailContainerView.isHidden = !isExpanded
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.detailContainerView.alpha = isExpanded ? 1.0 : 0.0
            self.updateCornerRadius() // Update corner radius during animation
            self.layoutIfNeeded()
            
            if isExpanded {
                self.Hydrationstepper.superview?.bringSubviewToFront(self.Hydrationstepper)
            }
        }, completion: nil)
    }
}

