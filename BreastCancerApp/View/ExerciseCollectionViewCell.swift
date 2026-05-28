import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    @IBOutlet var editPlanButton: UIButton!
    @IBOutlet var exerciseGraphView: BarGraphView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var barChartContainerView: UIView!
    @IBOutlet var dayActiveValueLabel: UILabel!
    @IBOutlet var totalMinutesValueLabel: UILabel!
}
