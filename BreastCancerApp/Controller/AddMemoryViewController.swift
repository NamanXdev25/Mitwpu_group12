import UIKit

protocol EditMemoryDelegate: AnyObject {
    func didEditMemory(_ memory: Memory, at index: Int)
}

final class AddMemoryViewController: UIViewController {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!

    var image: UIImage!
    weak var delegate: AddMemoryDelegate?

    var memoryToEdit: Memory?
    var editIndex: Int?
    weak var editDelegate: EditMemoryDelegate?

    private let placeholderText = "Add Note"
    private let maxNoteCharacters = 80

    private var isEditMode: Bool { memoryToEdit != nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isEditMode ? "Edit Memory" : "Add Memory"
        setupUI()
    }

    private func setupUI() {
        if isEditMode, let memory = memoryToEdit {
            cameraImageView.image = memory.image

            if let note = memory.note, !note.isEmpty {
                noteTextView.text = String(note.prefix(maxNoteCharacters))
                noteTextView.textColor = .label
            } else {
                showPlaceholder()
            }
        } else {
            cameraImageView.image = image
            showPlaceholder()
        }

        cameraImageView.contentMode = .scaleAspectFill
        cameraImageView.clipsToBounds = true

        noteTextView.delegate = self
        noteTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        doneButton.tintColor = UIColor(named: "QuoteColor")
        navigationItem.rightBarButtonItem = doneButton
    }

    private func showPlaceholder() {
        noteTextView.text = placeholderText
        noteTextView.textColor = .systemGray
    }

    private func sanitizedNote() -> String? {
        guard noteTextView.textColor != .systemGray else { return nil }

        let trimmed = noteTextView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return nil }

        return String(trimmed.prefix(maxNoteCharacters))
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        let note = sanitizedNote()

        if isEditMode, let original = memoryToEdit, let index = editIndex {
            let edited = Memory(
                image: original.image,
                date: original.date,
                note: note
            )

            dismiss(animated: true) { [weak self] in
                self?.editDelegate?.didEditMemory(edited, at: index)
            }
        } else {
            let memory = Memory(
                image: image,
                date: Date(),
                note: note
            )

            dismiss(animated: true) { [weak self] in
                self?.delegate?.didAddMemory(memory)
            }
        }
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
        let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            showPlaceholder()
        } else {
            textView.text = String(trimmed.prefix(maxNoteCharacters))
            textView.textColor = .label
        }
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let currentText = textView.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: text)

        if textView.textColor == .systemGray {
            return text.count <= maxNoteCharacters
        }

        return updatedText.count <= maxNoteCharacters
    }
}
