//
//  GuidedJournalViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 27/11/25.
//

import UIKit

class GuidedJournalViewController: UIViewController {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var existingEntry: JournalEntry?
    
    private let placeholder = "Start Typing..."
    
    var categoryText: String = ""
    var questionText: String = ""
    
    let datasource = GuidedReflectionDataSource.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(named: "BackgroundColor")
        textView.delegate = self
        
        categoryLabel.text = categoryText
        questionLabel.text = questionText

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
        
        GuidedReflectionDataSource.shared.refreshIfNeeded()
        
        if let question = GuidedReflectionDataSource.shared.getTodaysQuestion() {
            updateUI(with: question)
        }
        
        if let entry = existingEntry {
            navigationItem.title = "Edit Reflection"
            categoryLabel.text = entry.category?.uppercased()
            questionLabel.text = entry.question
            textView.text = entry.body
            textView.textColor = .label
        }

    }
    
    func updateUI(with question: GuidedReflectionQuestion) {
        questionLabel.text = question.question
        categoryLabel.text = formattedCategoryTags(for: question)
    }
    
    func formattedCategoryTags(for question: GuidedReflectionQuestion) -> String {
        let categoryText = question.category.rawValue.replacingOccurrences(of: "_", with: " ").uppercased()

        guard let tags = question.tags, !tags.isEmpty else {
            return categoryText
        }

        let tagsText = tags.map { $0.uppercased() }.joined(separator: ", ")

        return "\(categoryText) • \(tagsText)"
    }

    
    @IBAction func submitTapped(_ sender: UIBarButtonItem) {
        
        let body = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        /*
        if var entry = existingEntry {
            entry.body = body
            entry.date = Date()
            JournalStore.shared.update(entry)
        }
        */
        if let old = existingEntry {
            let updated = JournalEntry(
                id: old.id,
                title: old.title,  // keep title same (guided uses the question as title)
                body: body,
                date: Date(),
                type: old.type,
                question: old.question,
                category: old.category
            )
            
            JournalStore.shared.update(updated)
        } else {
            let newEntry = JournalEntry(
                title: questionLabel.text ?? "Guided Reflection",
                body: body,
                date: Date(),
                type: .guided,
                question: questionLabel.text,
                category: categoryLabel.text
            )

            JournalStore.shared.add(newEntry)
        }

        navigationController?.popViewController(animated: true)
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GuidedJournalViewController: UITextViewDelegate {

    func setupPlaceholder() {
        guard existingEntry == nil else { return }
        textView.text = placeholder
        textView.textColor = .systemGray3
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
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
