import UIKit

final class MemoryViewerViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noteLabel: UILabel!

    var image: UIImage?
    var note: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureImageView()
        configureNoteLabel()
    }
}

// MARK: - Configuration
private extension MemoryViewerViewController {

    func configureView() {
        view.backgroundColor = .white
    }

    func configureImageView() {
        imageView.image = image
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
