
import UIKit

class MindfulnessSlideCardCell: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var pageHostView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!

    var didTapSlideButton: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(initialSlidesCount: Int) {
        pageControl.numberOfPages = initialSlidesCount
        pageControl.currentPage = 0
    }
}
