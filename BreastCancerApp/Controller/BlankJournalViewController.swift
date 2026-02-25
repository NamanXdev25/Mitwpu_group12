//
//  BlankJournalViewController.swift
//  BreastCancerApp
//

import UIKit

class BlankJournalViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textView: UITextView!

    var existingEntry: JournalEntry?
    private let placeholderText = "Start writing what’s on your mind today..."

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "New Journal"

        if let entry = existingEntry {
            navigationItem.title = entry.formattedDateTitle
            titleField.text = entry.title
            textView.text = entry.body
            textView.textColor = .label
        }

        titleField.delegate = self
        textView.delegate = self
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        guard existingEntry == nil else { return }
        textView.text = placeholderText
        textView.textColor = UIColor.systemGray3
    }

    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty || !body.isEmpty else {
            closeAfterSave()
            return
        }

        if let old = existingEntry {
            let updated = JournalEntry(
                id: old.id,
                title: title,
                body: body,
                date: old.date,
                type: old.type,
                question: old.question,
                category: old.category
            )
            JournalStore.shared.update(updated)
        } else {
            let newEntry = JournalEntry(
                title: title.isEmpty ? "Untitled" : title,
                body: body,
                date: Date(),
                type: .regular,
                question: nil,
                category: nil
            )
            JournalStore.shared.add(newEntry)
        }

        closeAfterSave()
    }

    private func closeAfterSave() {
        if let nav = navigationController,
           nav.viewControllers.count == 1,
           nav.presentingViewController != nil {
            nav.dismiss(animated: true) // Home modal case
        } else {
            navigationController?.popViewController(animated: true) // Journal push case
        }
    }
}

extension BlankJournalViewController: UITextFieldDelegate, UITextViewDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let maxTitleLength = 60
        let current = textField.text ?? ""
        let newLength = current.count + string.count - range.length
        return newLength <= maxTitleLength
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        let maxBodyLength = 1500
        let current = textView.text ?? ""
        let newLength = current.count + text.count - range.length
        return newLength <= maxBodyLength
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setupPlaceholder()
        }
    }
}
