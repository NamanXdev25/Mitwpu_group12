//
//  BlankJournalViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 26/11/25.
//

import UIKit

class BlankJournalViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    var existingEntry: JournalEntry?

    private let placeholderText = "Start writing what’s on your mind today..."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "New Journal"
        
        titleField.delegate = self
        textView.delegate = self
        setupPlaceholder()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        if let entry = existingEntry {
            navigationItem.title = "Edit Journal"
            titleField.text = entry.title
            textView.text = entry.body
            textView.textColor = .label
        }
    }
    
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {

        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty || !body.isEmpty else {
            navigationController?.popViewController(animated: true)
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

        navigationController?.popViewController(animated: true)
    }

    private func setupPlaceholder() {
        guard existingEntry == nil else { return }
        textView.text = placeholderText
        textView.textColor = UIColor.systemGray3
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            toolbarBottomConstraint.constant = frame.height + 8
            view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        toolbarBottomConstraint.constant = 16
        view.layoutIfNeeded()
    }
    
    @IBAction func textFormatTapped(_ sender: UIButton) {}
    @IBAction func bulletTapped(_ sender: UIButton) {}
    @IBAction func tableTapped(_ sender: UIButton) {}
    @IBAction func attachTapped(_ sender: UIButton) {}
    @IBAction func alignmentTapped(_ sender: UIButton) {}

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

    // placeholder text
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
