import UIKit

class HydrationChartCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var averageValueLabel: UILabel!
    @IBOutlet weak var graphContainerView: UIView!
    @IBOutlet weak var goalLineView: UIView!

    // MARK: - Callback
    var onSegmentChanged: ((HydrationChartMode) -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSegmentedControl()
    }

    // MARK: - Setup
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Weekly", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Monthly", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged),
            for: .valueChanged
        )
    }

    // MARK: - Configuration
    func configure(average: Double, mode: HydrationChartMode) {
        segmentedControl.selectedSegmentIndex = (mode == .weekly) ? 0 : 1
        averageValueLabel.text = String(format: "%.1f L", average)
    }

    // MARK: - Actions
    @objc private func segmentChanged() {
        let mode: HydrationChartMode =
            segmentedControl.selectedSegmentIndex == 0 ? .weekly : .monthly
        onSegmentChanged?(mode)
    }
}
