//
//  DetailExerciseCellCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 08/12/25.
//

/*
 import UIKit
 
 class DetailExerciseCell: UICollectionViewCell {
 
 weak var delegate: DetailExerciseCellDelegate?
 @IBOutlet weak var containerView: UIView!
 @IBOutlet weak var exerciseImageView: UIImageView!
 @IBOutlet weak var titleLabel: UILabel!
 @IBOutlet weak var subtitleLabel: UILabel!
 @IBOutlet weak var timeLabel: UILabel!
 @IBOutlet weak var clockIconImageView: UIImageView!
 @IBOutlet weak var chevronButton: UIButton!
 
 override func awakeFromNib() {
 super.awakeFromNib()
 
 // 1. Card Style
 containerView.layer.cornerRadius = 16
 containerView.backgroundColor = .white
 
 // Shadow
 containerView.layer.shadowColor = UIColor.black.cgColor
 containerView.layer.shadowOpacity = 0.05
 containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
 containerView.layer.shadowRadius = 4
 
 // 2. Image Style
 exerciseImageView.layer.cornerRadius = 12
 exerciseImageView.contentMode = .scaleAspectFill
 exerciseImageView.clipsToBounds = true
 
 // 3. Text Style (Force Colors)
 titleLabel.textColor = .black
 
 // Ensure title is not compressed
 titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
 
 //subtitleLabel.textColor = .darkGray
 timeLabel.textColor = .gray
 
 // 4. Icons
 clockIconImageView.tintColor = .systemGray
 clockIconImageView.image = UIImage(systemName: "clock")
 
 // 4. Chevron Style
 let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
 chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
 chevronButton.tintColor = .systemGray3
 
 // 5. LAYER FIX: Bring labels to front
 // This ensures they are drawn ON TOP of the containerView
 if let parentView = titleLabel.superview {
 parentView.bringSubviewToFront(titleLabel)
 parentView.bringSubviewToFront(subtitleLabel)
 parentView.bringSubviewToFront(timeLabel)
 }
 }
 
 func configure(title: String, subtitle: String, time: String, imageName: String) {
 // Fallback for empty title
 titleLabel.text = title.isEmpty ? "Exercise" : title
 subtitleLabel.text = subtitle
 timeLabel.text = time
 
 if let img = UIImage(named: imageName) {
 exerciseImageView.image = img
 } else {
 exerciseImageView.backgroundColor = .systemPink.withAlphaComponent(0.1)
 }
 }
 
 protocol DetailExerciseCellDelegate: AnyObject {
 func didTapChevron(on cell: DetailExerciseCell)
 }
 
 @IBAction func chevronTapped(_ sender: UIButton) {
 delegate?.didTapChevron(on: self)
 }
 
 }
 
 /*
  import UIKit
  
  class DetailExerciseCell: UICollectionViewCell {
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var exerciseImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var chevronButton: UIButton!
  
  override func awakeFromNib() {
  super.awakeFromNib()
  
  // Style Card
  containerView.layer.cornerRadius = 16
  containerView.backgroundColor = .white
  
  // Shadow (Optional)
  containerView.layer.shadowColor = UIColor.black.cgColor
  containerView.layer.shadowOpacity = 0.05
  containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
  
  titleLabel.textColor = .black
  
  // Ensure title is not compressed
  titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
  
  subtitleLabel.textColor = .darkGray
  timeLabel.textColor = .gray
  
  // Style Image
  exerciseImageView.layer.cornerRadius = 12
  exerciseImageView.contentMode = .scaleAspectFill
  exerciseImageView.clipsToBounds = true
  
  // 4. Chevron Style
  let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
  chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
  chevronButton.tintColor = .systemGray3
  }
  
  func configure(title: String, subtitle: String, time: String, imageName: String) {
  titleLabel.text = title
  subtitleLabel.text = subtitle
  timeLabel.text = time
  
  if let img = UIImage(named: imageName) {
  exerciseImageView.image = img
  } else {
  exerciseImageView.backgroundColor = .systemPink.withAlphaComponent(0.1)
  }
  }
  }
  
  */
 */

//
//  DetailExerciseCell.swift
//  BreastCancerApp
//
//  Created by You on <date>.
//

import UIKit

// Global delegate protocol so controllers can adopt it easily
protocol DetailExerciseCellDelegate: AnyObject {
    func didTapChevron(on cell: DetailExerciseCell)
}

class DetailExerciseCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clockIconImageView: UIImageView!
    @IBOutlet weak var chevronButton: UIButton!

    // MARK: - Delegate
    weak var delegate: DetailExerciseCellDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // 1. Card Style
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = .white

        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6

        // 2. Image Style
        exerciseImageView.layer.cornerRadius = 10
        exerciseImageView.contentMode = .scaleAspectFill
        exerciseImageView.clipsToBounds = true

        // 3. Text Style
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.textColor = .darkGray
        subtitleLabel.font = .systemFont(ofSize: 13)

        timeLabel.textColor = .gray
        timeLabel.font = .systemFont(ofSize: 13)

        // 4. Icons
        clockIconImageView.tintColor = .systemGray
        clockIconImageView.image = UIImage(systemName: "clock")

        // 5. Chevron
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        chevronButton.tintColor = .systemGray3

        // Ensure button action exists (IBAction should be connected in IB; this is a safety)
        chevronButton.removeTarget(nil, action: nil, for: .allEvents)
        chevronButton.addTarget(self, action: #selector(chevronTapped(_:)), for: .touchUpInside)
    }

    // MARK: - Configure
    func configure(title: String, subtitle: String, time: String, imageName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        timeLabel.text = time

        if let img = UIImage(named: imageName) {
            exerciseImageView.image = img
        } else {
            exerciseImageView.image = nil
            exerciseImageView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.08)
        }
    }

    // MARK: - IBAction
    // Connect this IBAction from the chevron UIButton in Interface Builder,
    // or the programmatic target above will also call it.
    @IBAction func chevronTapped(_ sender: UIButton) {
        delegate?.didTapChevron(on: self)
    }
}

