import UIKit

final class MemoryViewerViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage?
    var note: String?

    private let noteLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        imageView.image = image

        setupNoteLabel()
    }

    // MARK: - Note (NO BACKGROUND, ABOVE DELETE)
    private func setupNoteLabel() {
        guard let note = note, !note.isEmpty else { return }

        noteLabel.text = note
        noteLabel.font = .systemFont(ofSize: 15)
        noteLabel.textColor = .label
        noteLabel.numberOfLines = 0
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(noteLabel)

        NSLayoutConstraint.activate([
            noteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // ⬆️ MOVE ABOVE DELETE BUTTON AREA
            noteLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -90
            )
        ])
    }
}
