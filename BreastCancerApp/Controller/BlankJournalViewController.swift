//
//  BlankJournalViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 26/11/25.
//

import UIKit

class BlankJournalViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!


    private let placeholderText = "Start writing what’s on your mind today..."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "New Journal"
        
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
    }
    
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        print("Submit Tapped")
        // add submit + save logic here
        /*
        let entry = JournalEntry(
            title: userProvidedTitle,
            body: userProvidedBody,
            date: Date(),
            type: .regular
        )

        JournalDataSource.shared.addEntry(entry)
         */
    }

    
    private func setupPlaceholder() {
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
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BlankJournalViewController: UITextViewDelegate {
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
