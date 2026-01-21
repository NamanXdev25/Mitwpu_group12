import UIKit

final class MemoryViewerViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Data
    var image: UIImage?
    var note: String?
    var date: Date?

    private let calendar = Calendar.current

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDateLabel()
        configureImageView()
        configureNoteLabel()
    }
}

// MARK: - Configuration
private extension MemoryViewerViewController {

    func configureView() {
        view.backgroundColor = .white
    }

    func configureDateLabel() {
        guard let date else {
            dateLabel.isHidden = true
            return
        }

        dateLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .center

        if calendar.isDateInToday(date) {
            dateLabel.text = "Today"
        } else if calendar.isDateInYesterday(date) {
            dateLabel.text = "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            dateLabel.text = formatter.string(from: date)
        }
    }

    func configureImageView() {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }

    func configureNoteLabel() {
        guard let note, !note.isEmpty else {
            noteLabel.isHidden = true
            return
        }

        noteLabel.text = note
        noteLabel.font = .systemFont(ofSize: 15)
        noteLabel.textColor = .label
        noteLabel.numberOfLines = 0
    }
}
