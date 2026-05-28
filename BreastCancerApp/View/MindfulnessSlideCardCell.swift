import UIKit

class MindfulnessSlideCardCell: UICollectionViewCell {
    @IBOutlet var cardView: UIView!
    @IBOutlet var pageHostView: UIView!
    @IBOutlet var pageControl: UIPageControl!

    var didTapSlideButton: ((Int) -> Void)?

    func configure(initialSlidesCount: Int) {
        pageControl.numberOfPages = initialSlidesCount
        pageControl.currentPage = 0
    }
}
