//
//  MemoryMonthGroupCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 11/02/26.
//

import UIKit

final class MemoryMonthGroupCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MemoryMonthGroupCell"
    
    // MARK: - Outlets
    @IBOutlet private weak var polaroidCard1: UIView!
    @IBOutlet private weak var polaroidCard2: UIView!
    @IBOutlet private weak var polaroidCard3: UIView!
    @IBOutlet private weak var polaroidCard4: UIView!
    @IBOutlet private weak var imageView1: UIImageView!
    @IBOutlet private weak var imageView2: UIImageView!
    @IBOutlet private weak var imageView3: UIImageView!
    @IBOutlet private weak var imageView4: UIImageView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var overlayLabel: UILabel!
    @IBOutlet private weak var monthLabel: UILabel!
    
    var onTap: (() -> Void)?
    
    private let calendar = Calendar.current
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureStyling()
        configureGesture()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
        imageView4.image = nil
        overlayLabel.text = ""
        overlayView.isHidden = true
        onTap = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply shadow after layout to each polaroid card
        [polaroidCard1, polaroidCard2, polaroidCard3, polaroidCard4].forEach { card in
            card?.layer.shadowPath = UIBezierPath(
                roundedRect: card!.bounds,
                cornerRadius: 12
            ).cgPath
        }
    }
    
    func configure(with memories: [Memory], month: Int, year: Int) {
        // Configure images
        let imageViews = [imageView1, imageView2, imageView3, imageView4]
        let cards = [polaroidCard1, polaroidCard2, polaroidCard3, polaroidCard4]
        let displayCount = min(memories.count, 4)
        
        for i in 0..<displayCount {
            imageViews[i]?.image = memories[i].image
            cards[i]?.isHidden = false
        }
        
        // Hide unused cards completely
        for i in displayCount..<4 {
            cards[i]?.isHidden = true
        }
        
        // Configure overlay for additional photos
        if memories.count > 4 {
            overlayView.isHidden = false
            overlayLabel.text = "+\(memories.count - 3)"
        } else {
            overlayView.isHidden = true
        }
        
        // Configure month label
        let monthName = calendar.monthSymbols[month - 1]
        monthLabel.text = monthName
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Private Configuration
private extension MemoryMonthGroupCell {
    
    func configureStyling() {
        // Polaroid card styling with alternating tilts
        let cards = [polaroidCard1, polaroidCard2, polaroidCard3, polaroidCard4]
        let rotations: [CGFloat] = [-0.08, 0.05, -0.03, 0.06] // Alternating angles
        
        for (index, card) in cards.enumerated() {
            guard let card = card else { continue }
            
            // Shadow
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOffset = CGSize(width: 0, height: 4)
            card.layer.shadowRadius = 8
            card.layer.shadowOpacity = 0.15
            card.layer.masksToBounds = false
            
            // Rotation for polaroid effect
            card.transform = CGAffineTransform(rotationAngle: rotations[index])
        }
        
        // Image view styling
        [imageView1, imageView2, imageView3, imageView4].forEach { imageView in
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
            imageView?.layer.cornerRadius = 6
            imageView?.backgroundColor = .systemGray6
        }
        
        // Overlay styling
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 6
        overlayLabel.textColor = .white
        overlayLabel.font = .systemFont(ofSize: 28, weight: .bold)
        overlayLabel.textAlignment = .center
        
        // Month label styling
        monthLabel.textColor = UIColor(red: 0.91, green: 0.42, blue: 0.57, alpha: 1.0)
    }
    
    func configureGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }
}
