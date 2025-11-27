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
        print("Submitted guided Journal")
        /*
        let entry = JournalEntry(
            title: question.category.rawValue.uppercased(),    // or "Guided Reflection"
            body: answerText,
            date: Date(),
            type: .guided,
            question: question.question,
            category: question.category.rawValue
        )

        JournalDataSource.shared.addEntry(entry)
         */
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
