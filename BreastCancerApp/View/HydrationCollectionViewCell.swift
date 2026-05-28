import UIKit

class HydrationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var hydrationGraphView: LineGraphView!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var subtitle2Label: UILabel!
    @IBOutlet var graphContainerView: UIView!
    @IBOutlet var averageValueLabel: UILabel!
}
