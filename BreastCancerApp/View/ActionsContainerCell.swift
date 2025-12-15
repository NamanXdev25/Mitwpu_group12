import UIKit

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

        contentView.backgroundColor = .clear

        // Log Self-Exam button
        logButton.setTitle("Log Self-Exam", for: .normal)
        logButton.backgroundColor = UIColor(named: "pink") ?? .systemPink
        logButton.layer.cornerRadius = 24
        logButton.clipsToBounds = true
        logButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logButton.setTitleColor(.white, for: .normal)

        // View Past Tests button
        //pastButton.setTitle("View past tests", for: .normal)
        pastButton.setTitleColor(UIColor(named: "pink") ?? .systemPink, for: .normal)
        pastButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
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
