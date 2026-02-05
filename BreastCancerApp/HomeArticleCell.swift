////
////  HomeArticleCell.swift
////  BreastCancerApp
////
////  Created by Naman Bhansali on 03/02/26.
////
//
//import UIKit
//
//class HomeArticleCell: UICollectionViewCell {
//
//    @IBOutlet weak var ArticleContainerView: UIView!
//    @IBOutlet weak var ArticleImageView: UIImageView!
//    @IBOutlet weak var ArticleTitleLable: UILabel!
//    @IBOutlet weak var ArticleSubheadLabel: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        // CRITICAL FIX: Prevent image stretching
//        setupImageView()
//        setupCardAppearance()
//    }
//    
//    private func setupImageView() {
//        // Prevent stretching - maintain aspect ratio
//        ArticleImageView.contentMode = .scaleAspectFill
//        ArticleImageView.clipsToBounds = true
//        
////        // Optional: Add corner radius to image
////        ArticleImageView.layer.cornerRadius = 12
////        ArticleImageView.layer.masksToBounds = true
//    }
//    
//    private func setupCardAppearance() {
//        // Optional: Add card shadow and styling
//        ArticleContainerView.layer.cornerRadius = 13
//        ArticleContainerView.layer.shadowColor = UIColor.black.cgColor
//        ArticleContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        ArticleContainerView.layer.shadowRadius = 8
//        ArticleContainerView.layer.shadowOpacity = 0.08
//        ArticleContainerView.layer.masksToBounds = false
//        
//        // Ensure background is opaque for shadow to show
//        ArticleContainerView.backgroundColor = .white
//    }
//    
//    // MARK: - Configure
//    func configure(with article: Article) {
//        ArticleTitleLable.text = article.title
//        ArticleSubheadLabel.text = article.subtitle
//        
//        // Set image with proper content mode
//        ArticleImageView.image = UIImage(named: article.imageName)
//        ArticleImageView.contentMode = .scaleAspectFill
//    }
//}


import UIKit

class HomeArticleCell: UICollectionViewCell {
    
    @IBOutlet weak var ArticleContainerView: UIView!
    @IBOutlet weak var ArticleImageView: UIImageView!
    @IBOutlet weak var ArticleTitleLable: UILabel!
    @IBOutlet weak var ArticleSubheadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with article: Article) {
                ArticleTitleLable.text = article.title
                ArticleSubheadLabel.text = article.subtitle
        
                // Set image with proper content mode
                ArticleImageView.image = UIImage(named: article.imageName)
//                ArticleImageView.contentMode = .scaleAspectFill
    }
}
