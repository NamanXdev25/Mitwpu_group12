import UIKit

final class AddMemoryViewController: UIViewController {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!

    var image: UIImage!
    weak var delegate: AddMemoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Memory"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        cameraImageView.image = image
        cameraImageView.contentMode = .scaleAspectFill
        cameraImageView.clipsToBounds = true

        noteTextView.text = "Add Note"
        noteTextView.textColor = .systemGray
        noteTextView.delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        let note = noteTextView.textColor == .systemGray ? nil : noteTextView.text

        let memory = Memory(
            image: image,
            date: Date(),
            note: note
        )

        delegate?.didAddMemory(memory)
        dismiss(animated: true)
    }
}

extension AddMemoryViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Note"
            textView.textColor = .systemGray
        }
    }
}
