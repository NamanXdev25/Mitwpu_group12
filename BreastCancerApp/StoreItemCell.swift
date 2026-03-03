////////
////////  StoreItemCell.swift
////////  healinggarden2
////////
////////  Created by Naman Bhansali on 27/01/26.
////////
//////
//////import UIKit
//////
//////class StoreItemCell: UICollectionViewCell {
//////    
//////    @IBOutlet weak var cardContainerView: UIView!
//////    @IBOutlet weak var itemImageView: UIImageView!
//////    @IBOutlet weak var priceLabel: UILabel!
//////    @IBOutlet weak var coinImageView: UIImageView!
//////    
//////    override func awakeFromNib() {
//////        super.awakeFromNib()
//////        setupUI()
//////    }
//////    
//////    private func setupUI() {
//////        // 1. Shadow on the Cell itself
//////        self.backgroundColor = .clear
//////        self.layer.shadowColor = UIColor.black.cgColor
//////        self.layer.shadowOffset = CGSize(width: 0, height: 4)
//////        self.layer.shadowRadius = 6
//////        self.layer.shadowOpacity = 0.1
//////        self.layer.masksToBounds = false
//////        
//////        // 2. Rounded Corners on the Container
//////        cardContainerView.backgroundColor = .white
//////        cardContainerView.layer.cornerRadius = 13
//////        cardContainerView.layer.masksToBounds = true // Clips the image inside
//////        
//////        itemImageView.contentMode = .scaleAspectFit
//////        priceLabel.font = .systemFont(ofSize: 14, weight: .bold)
//////    }
//////    
//////    func configure(with item: StoreItem) {
//////        itemImageView.image = UIImage(named: item.imageName)
//////        priceLabel.text = "\(item.price)"
////////        coinImageView.image = UIImage(named: "coin_icon") // Asset needed
//////    }
//////}
////
//////
//////  StoreItemCell.swift
//////  BreastCancerApp
//////
////
////import UIKit
////
////class StoreItemCell: UICollectionViewCell {
////
////    @IBOutlet weak var cardContainerView: UIView!
////    @IBOutlet weak var itemImageView: UIImageView!
////    @IBOutlet weak var priceLabel: UILabel!
////    @IBOutlet weak var coinImageView: UIImageView!
////
////    override func awakeFromNib() {
////        super.awakeFromNib()
////        setupUI()
////    }
////
////    private func setupUI() {
////        backgroundColor = .clear
////        layer.shadowColor = UIColor.black.cgColor
////        layer.shadowOffset = CGSize(width: 0, height: 4)
////        layer.shadowRadius = 6
////        layer.shadowOpacity = 0.1
////        layer.masksToBounds = false
////
////        cardContainerView.backgroundColor = .white
////        cardContainerView.layer.cornerRadius = 13
////        cardContainerView.layer.masksToBounds = true
////
////        itemImageView.contentMode = .scaleAspectFit
////        priceLabel.font = .systemFont(ofSize: 14, weight: .bold)
////    }
////
////    func configure(with item: StoreItem) {
////        itemImageView.image = UIImage(named: item.imageName)
////
////        let showPrice = item.category != GardenManager.Category.yourItems.rawValue && item.price > 0
////        priceLabel.isHidden = !showPrice
////        coinImageView.isHidden = !showPrice
////        priceLabel.text = showPrice ? "\(item.price)" : ""
////    }
////}
//
////
////  StoreItemCell.swift
////  BreastCancerApp
////
//
//import UIKit
//
//class StoreItemCell: UICollectionViewCell {
//
//    @IBOutlet weak var cardContainerView: UIView!
//    @IBOutlet weak var itemImageView: UIImageView!
//    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var coinImageView: UIImageView!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupUI()
//    }
//
//    private func setupUI() {
//        backgroundColor = .clear
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowRadius = 6
//        layer.shadowOpacity = 0.1
//        layer.masksToBounds = false
//
//        cardContainerView.backgroundColor = .white
//        cardContainerView.layer.cornerRadius = 13
//        cardContainerView.layer.masksToBounds = true
//
//        itemImageView.contentMode = .scaleAspectFit
//        priceLabel.font = .systemFont(ofSize: 14, weight: .bold)
//    }
//
//    func configure(with item: StoreItem, showPrice: Bool) {
//        itemImageView.image = UIImage(named: item.imageName)
//
//        let shouldShowPrice = showPrice && item.price > 0
//        priceLabel.isHidden = !shouldShowPrice
//        coinImageView.isHidden = !shouldShowPrice
//        priceLabel.text = shouldShowPrice ? "\(item.price)" : ""
//    }
//}

//
//  StoreItemCell.swift
//  BreastCancerApp
//

import UIKit

class StoreItemCell: UICollectionViewCell {

    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false

        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 13
        cardContainerView.layer.masksToBounds = true

        itemImageView.contentMode = .scaleAspectFit

        priceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        priceLabel.textColor = .label
        priceLabel.numberOfLines = 2
        priceLabel.textAlignment = .center
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.7
    }

    func configure(with item: StoreItem, showPrice: Bool) {
        itemImageView.image = UIImage(named: item.imageName)

        if showPrice {
            // Nature / Wellness: show coin + price
            coinImageView.isHidden = false
            priceLabel.isHidden = false
            priceLabel.text = "\(item.price)"
        } else {
            // Your Items: show name from JSON, hide coin
            coinImageView.isHidden = true
            priceLabel.isHidden = false
            priceLabel.text = item.name
        }
    }
}
