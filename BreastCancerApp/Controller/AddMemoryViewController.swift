import UIKit

protocol EditMemoryDelegate: AnyObject {
    func didEditMemory(_ memory: Memory, at index: Int)
}

final class AddMemoryViewController: UIViewController {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!

    // Add mode
    var image: UIImage!
    weak var delegate: AddMemoryDelegate?

    // Edit mode
    var memoryToEdit: Memory?
    var editIndex: Int?
    weak var editDelegate: EditMemoryDelegate?

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
                noteTextView.text = note
                noteTextView.textColor = .label
            } else {
                noteTextView.text = "Add Note"
                noteTextView.textColor = .systemGray
            }
        } else {
            cameraImageView.image = image
            noteTextView.text = "Add Note"
            noteTextView.textColor = .systemGray
        }

        cameraImageView.contentMode = .scaleAspectFill
        cameraImageView.clipsToBounds = true
        noteTextView.delegate = self

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

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        let note = noteTextView.textColor == .systemGray ? nil : noteTextView.text

        if isEditMode, let original = memoryToEdit, let index = editIndex {
            let edited = Memory(
                image: original.image, // image stays the same in edit mode
                date: original.date,   // preserve original date
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
        if textView.text.isEmpty {
            textView.text = "Add Note"
            textView.textColor = .systemGray
        }
    }
}
