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
    @IBOutlet weak var pageControl: UIPageControl!    // optional: you can update this from cell

    // callbacks for actions inside slides (optional)
    var didTapSlideButton: ((Int) -> Void)?  // slide index

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
    }

    // We'll provide a setup method later to attach a UIPageViewController into pageHostView
    func configure(initialSlidesCount: Int) {
        pageControl.numberOfPages = initialSlidesCount
        pageControl.currentPage = 0
    }
}
