//
//  HomeMoodCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//

import UIKit

class HomeMoodCell: UICollectionViewCell {

    @IBOutlet weak var MoodCellView: UIView!
    @IBOutlet weak var MoodTitleLabel: UILabel!
    
    @IBOutlet weak var ExcitedImageView: UIImageView!
    @IBOutlet weak var ExcitedLabel: UILabel!
    
    @IBOutlet weak var HappyImageView: UIImageView!
    @IBOutlet weak var HappyLabel: UILabel!
    
    @IBOutlet weak var SadImageView: UIImageView!
    @IBOutlet weak var SadLabel: UILabel!
    
    @IBOutlet weak var TiredImageView: UIImageView!
    @IBOutlet weak var TiredLabel: UILabel!
    
    @IBOutlet weak var AnxiousImageView: UIImageView!
    @IBOutlet weak var AnxiousLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // CRITICAL FIX: Set content mode to prevent stretching
        setupImageViews()
    }
    
    private func setupImageViews() {
        let imageViews = [ExcitedImageView, HappyImageView, SadImageView, TiredImageView, AnxiousImageView]
        
        for imageView in imageViews {
            imageView?.contentMode = .scaleAspectFit  // Prevents stretching!
            imageView?.clipsToBounds = true
        }
    }
    
    // MARK: - Configure
    func configure(title: String, moods: [Mood]) {
        MoodTitleLabel.text = title
        
        guard moods.count >= 5 else { return }
        
        // Configure Excited
        ExcitedLabel.text = moods[0].title
        ExcitedImageView.image = UIImage(named: moods[0].imageName)
        ExcitedImageView.contentMode = .scaleAspectFit
        
        // Configure Happy
        HappyLabel.text = moods[1].title
        HappyImageView.image = UIImage(named: moods[1].imageName)
        HappyImageView.contentMode = .scaleAspectFit
        
        // Configure Sad
        SadLabel.text = moods[2].title
        SadImageView.image = UIImage(named: moods[2].imageName)
        SadImageView.contentMode = .scaleAspectFit
        
        // Configure Tired
        TiredLabel.text = moods[3].title
        TiredImageView.image = UIImage(named: moods[3].imageName)
        TiredImageView.contentMode = .scaleAspectFit
        
        // Configure Anxious
        AnxiousLabel.text = moods[4].title
        AnxiousImageView.image = UIImage(named: moods[4].imageName)
        AnxiousImageView.contentMode = .scaleAspectFit
    }
}
