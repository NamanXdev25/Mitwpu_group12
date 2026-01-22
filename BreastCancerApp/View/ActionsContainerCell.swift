import UIKit

protocol ActionsContainerCellDelegate: AnyObject {
    func didTapLogSelfExam(from cell: ActionsContainerCell)
    func didTapViewPastTests(from cell: ActionsContainerCell)
}

final class ActionsContainerCell: UICollectionViewCell {

    @IBOutlet private weak var logButton: UIButton!
    @IBOutlet private weak var pastButton: UIButton!

    weak var delegate: ActionsContainerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        let pink = UIColor(named: "TabBarcolor1")

        logButton.setTitle("Log Self-Exam", for: .normal)
        logButton.setTitleColor(.white, for: .normal)
        logButton.backgroundColor = pink
        logButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)

        pastButton.setTitleColor(pink, for: .normal)
        pastButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        pastButton.backgroundColor = .clear
    }

    @IBAction private func logButtonTapped(_ sender: UIButton) {
        delegate?.didTapLogSelfExam(from: self)
    }

    @IBAction private func pastButtonTapped(_ sender: UIButton) {
        delegate?.didTapViewPastTests(from: self)
    }
}
