import UIKit

final class HydrationChartCell: UICollectionViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var averageValueLabel: UILabel!
    @IBOutlet weak var graphContainerView: UIView!

    private let chartView = HydrationBarChartView()

    var onSegmentChanged: ((HydrationChartMode) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupSegmentedControl()
        setupChartView()
    }

    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Weekly", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Monthly", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func setupChartView() {
        chartView.frame = graphContainerView.bounds
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphContainerView.addSubview(chartView)
    }

    func configure(average: Double, mode: HydrationChartMode) {
        segmentedControl.selectedSegmentIndex = mode == .weekly ? 0 : 1
        averageValueLabel.text = String(format: "%.1f L", average)

        switch mode {
        case .weekly:
            let values = HydrationHistoryModel.chartValues(for: .weekly)
            let labels = ["S", "M", "T", "W", "T", "F", "S"]
            chartView.configure(values: values, labels: labels, mode: .weekly)

        case .monthly:
            let values = HydrationHistoryModel.chartValues(for: .monthly)
            let labels = values.indices.map { "\($0 + 1)" }
            chartView.configure(values: values, labels: labels, mode: .monthly)
        }
    }

    @objc private func segmentChanged() {
        let mode: HydrationChartMode = segmentedControl.selectedSegmentIndex == 0 ? .weekly : .monthly
        onSegmentChanged?(mode)
    }
}
