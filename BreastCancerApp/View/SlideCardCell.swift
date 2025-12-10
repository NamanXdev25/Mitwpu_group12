//
//  SlideCardCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 09/12/25.
//

import UIKit

class SlideCardCell: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var pageHostView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!

    var didTapSlideButton: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
    }

    func configure(initialSlidesCount: Int) {
        pageControl.numberOfPages = initialSlidesCount
        pageControl.currentPage = 0
    }
}
