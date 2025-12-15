import UIKit

// Delegate for action callbacks
protocol ActionsContainerCellDelegate: AnyObject {
    func didTapLogSelfExam(from cell: ActionsContainerCell)
    func didTapViewPastTests(from cell: ActionsContainerCell)
}

class ActionsContainerCell: UICollectionViewCell {

    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var pastButton: UIButton!

    weak var delegate: ActionsContainerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        let pink = UIColor(named: "pink") ?? .systemPink

        logButton.setTitle("Log Self-Exam", for: .normal)
        logButton.setTitleColor(.white, for: .normal)
        logButton.backgroundColor = pink
        logButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)

        pastButton.setTitleColor(pink, for: .normal)
        pastButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        pastButton.backgroundColor = .clear
    }

    // MARK: - Actions
    @IBAction func logButtonTapped(_ sender: UIButton) {
        delegate?.didTapLogSelfExam(from: self)
    }

    @IBAction func pastButtonTapped(_ sender: UIButton) {
        delegate?.didTapViewPastTests(from: self)
    }
}
