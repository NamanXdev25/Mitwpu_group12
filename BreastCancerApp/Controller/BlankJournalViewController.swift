//
//  BlankJournalViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 26/11/25.
//

import UIKit

class BlankJournalViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    // variables
    var existingEntry: JournalEntry?
    private let placeholderText = "Start writing what’s on your mind today..."
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "New Journal"
        
        if let entry = existingEntry {
            navigationItem.title = entry.formattedDateTitle
            titleField.text = entry.title
            textView.text = entry.body
            textView.textColor = .label
        }
        
        // delegates
        titleField.delegate = self
        textView.delegate = self
        
        // function calls
        setupPlaceholder()
    }
    
    // placeholder function
    private func setupPlaceholder() {
        guard existingEntry == nil else { return }
        textView.text = placeholderText
        textView.textColor = UIColor.systemGray3
    }
    
    // IBActions
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        // text setup
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty || !body.isEmpty else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        // existing entry
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
             
        // new entry
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
        navigationController?.popViewController(animated: true)
    }
}

extension BlankJournalViewController: UITextFieldDelegate, UITextViewDelegate {
    // character limit
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

    // text view before & after typing/editing
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
