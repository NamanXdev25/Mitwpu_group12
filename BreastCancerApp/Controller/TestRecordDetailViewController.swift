import UIKit

class TestRecordDetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    var record: TestRecord?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Test Details"

        // Show date
        if let d = record?.date {
            let df = DateFormatter()
            df.dateStyle = .medium
            dateLabel.text = df.string(from: d)
        } else {
            dateLabel.text = "—"
        }

        // Clear previous rows
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // Add each observation row
        record?.observations.forEach { obs in
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = 8
            hStack.distribution = .fillProportionally

            let left = UILabel()
            left.text = obs.title
            left.font = .systemFont(ofSize: 16)

            let right = UILabel()
            right.text = obs.value
            right.font = .systemFont(ofSize: 16)
            right.textAlignment = .right

            hStack.addArrangedSubview(left)
            hStack.addArrangedSubview(right)

            stackView.addArrangedSubview(hStack)
        }
    }
}
