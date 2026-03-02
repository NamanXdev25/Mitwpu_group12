////////
////////  BlankJournalViewController.swift
////////  BreastCancerApp
////////
//////
//////import UIKit
//////
//////class BlankJournalViewController: UIViewController {
//////
//////    @IBOutlet weak var titleField: UITextField!
//////    @IBOutlet weak var textView: UITextView!
//////     
//////    var prefilledTitle: String?
//////    var existingEntry: JournalEntry?
//////    private let placeholderText = "Start writing what’s on your mind today..."
//////
//////    override func viewDidLoad() {
//////        super.viewDidLoad()
//////
//////        view.backgroundColor = UIColor(named: "BackgroundColor")
//////        navigationItem.title = "New Journal"
//////
//////        if let entry = existingEntry {
//////            navigationItem.title = entry.formattedDateTitle
//////            titleField.text = entry.title
//////            textView.text = entry.body
//////            textView.textColor = .label
//////        }
//////        
//////        if existingEntry == nil,
//////           let prefilledTitle,
//////           !prefilledTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//////            titleField.text = prefilledTitle
//////        }
//////
//////        titleField.delegate = self
//////        textView.delegate = self
//////        setupPlaceholder()
//////    }
//////
//////    private func setupPlaceholder() {
//////        guard existingEntry == nil else { return }
//////        textView.text = placeholderText
//////        textView.textColor = UIColor.systemGray3
//////    }
//////
//////    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
//////        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//////        let body = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
//////
//////        guard !title.isEmpty || !body.isEmpty else {
//////            closeAfterSave()
//////            return
//////        }
//////
//////        if let old = existingEntry {
//////            let updated = JournalEntry(
//////                id: old.id,
//////                title: title,
//////                body: body,
//////                date: old.date,
//////                type: old.type,
//////                question: old.question,
//////                category: old.category
//////            )
//////            JournalStore.shared.update(updated)
//////        } else {
//////            let newEntry = JournalEntry(
//////                title: title.isEmpty ? "Untitled" : title,
//////                body: body,
//////                date: Date(),
//////                type: .regular,
//////                question: nil,
//////                category: nil
//////            )
//////            JournalStore.shared.add(newEntry)
//////        }
//////
//////        closeAfterSave()
//////    }
//////
//////    private func closeAfterSave() {
//////        if let nav = navigationController,
//////           nav.viewControllers.count == 1,
//////           nav.presentingViewController != nil {
//////            nav.dismiss(animated: true) // Home modal case
//////        } else {
//////            navigationController?.popViewController(animated: true) // Journal push case
//////        }
//////    }
//////}
//////
//////extension BlankJournalViewController: UITextFieldDelegate, UITextViewDelegate {
//////
//////    func textField(_ textField: UITextField,
//////                   shouldChangeCharactersIn range: NSRange,
//////                   replacementString string: String) -> Bool {
//////        let maxTitleLength = 60
//////        let current = textField.text ?? ""
//////        let newLength = current.count + string.count - range.length
//////        return newLength <= maxTitleLength
//////    }
//////
//////    func textView(_ textView: UITextView,
//////                  shouldChangeTextIn range: NSRange,
//////                  replacementText text: String) -> Bool {
//////        let maxBodyLength = 1500
//////        let current = textView.text ?? ""
//////        let newLength = current.count + text.count - range.length
//////        return newLength <= maxBodyLength
//////    }
//////
//////    func textViewDidBeginEditing(_ textView: UITextView) {
//////        if textView.text == placeholderText {
//////            textView.text = ""
//////            textView.textColor = .label
//////        }
//////    }
//////
//////    func textViewDidEndEditing(_ textView: UITextView) {
//////        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//////            setupPlaceholder()
//////        }
//////    }
//////}
////
////import UIKit
////
////class BlankJournalViewController: UIViewController {
////
////    @IBOutlet weak var titleTextView: UITextView!
////    @IBOutlet weak var textView: UITextView!
////
////    var existingEntry: JournalEntry?
////    var prefilledTitle: String?
////
////    private let bodyPlaceholderText = "Start writing what’s on your mind today..."
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        view.backgroundColor = UIColor(named: "BackgroundColor")
////        navigationItem.title = "New Journal"
////
////        titleTextView.delegate = self
////        textView.delegate = self
////
////        applyTitleStyle()
////
////        if let entry = existingEntry {
////            navigationItem.title = entry.formattedDateTitle
////            titleTextView.text = entry.title
////            titleTextView.textColor = .label
////
////            textView.text = entry.body
////            textView.textColor = .label
////        } else {
////            titleTextView.text = prefilledTitle?.trimmingCharacters(in: .whitespacesAndNewlines)
////            titleTextView.textColor = .label
////
////            setupBodyPlaceholder()
////        }
////    }
////
////    private func applyTitleStyle() {
////        titleTextView.font = UIFont.preferredFont(forTextStyle: .title1)
////        titleTextView.adjustsFontForContentSizeCategory = true
////        titleTextView.textColor = .label
////        titleTextView.backgroundColor = .clear
////        titleTextView.isScrollEnabled = false
////        titleTextView.textContainerInset = .zero
////        titleTextView.textContainer.lineFragmentPadding = 0
////    }
////
////    private func setupBodyPlaceholder() {
////        guard existingEntry == nil else { return }
////        textView.text = bodyPlaceholderText
////        textView.textColor = .systemGray3
////    }
////
////    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
////        let title = titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
////        let body = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
////
////        guard !title.isEmpty || !body.isEmpty else {
////            closeAfterSave()
////            return
////        }
////
////        if let old = existingEntry {
////            let updated = JournalEntry(
////                id: old.id,
////                title: title,
////                body: body,
////                date: old.date,
////                type: old.type,
////                question: old.question,
////                category: old.category
////            )
////            JournalStore.shared.update(updated)
////        } else {
////            let newEntry = JournalEntry(
////                title: title.isEmpty ? "Untitled" : title,
////                body: body,
////                date: Date(),
////                type: .regular,
////                question: nil,
////                category: nil
////            )
////            JournalStore.shared.add(newEntry)
////        }
////
////        closeAfterSave()
////    }
////
////    private func closeAfterSave() {
////        if let nav = navigationController,
////           nav.viewControllers.count == 1,
////           nav.presentingViewController != nil {
////            nav.dismiss(animated: true)
////        } else {
////            navigationController?.popViewController(animated: true)
////        }
////    }
////}
////
////extension BlankJournalViewController: UITextViewDelegate {
////
////    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
////        if textView === titleTextView {
////            let maxTitleLength = 300
////            let current = textView.text ?? ""
////            let newLength = current.count + text.count - range.length
////            return newLength <= maxTitleLength
////        } else {
////            let maxBodyLength = 1500
////            let current = textView.text ?? ""
////            let newLength = current.count + text.count - range.length
////            return newLength <= maxBodyLength
////        }
////    }
////
////    func textViewDidBeginEditing(_ textView: UITextView) {
////        if textView === self.textView, textView.text == bodyPlaceholderText {
////            textView.text = ""
////            textView.textColor = .label
////        }
////    }
////
////    func textViewDidEndEditing(_ textView: UITextView) {
////        if textView === self.textView,
////           textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
////            setupBodyPlaceholder()
////        }
////    }
////}
//
//import UIKit
//
//class BlankJournalViewController: UIViewController {
//
//    @IBOutlet weak var titleTextView: UITextView!
//    @IBOutlet weak var textView: UITextView!
//
//    var existingEntry: JournalEntry?
//    var prefilledTitle: String?
//
//    private let titlePlaceholderText = "Title"
//    private let bodyPlaceholderText = "Start writing what’s on your mind today..."
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = UIColor(named: "BackgroundColor")
//        navigationItem.title = "New Journal"
//
//        titleTextView.delegate = self
//        textView.delegate = self
//
//        applyTitleStyle()
//
//        if let entry = existingEntry {
//            navigationItem.title = entry.formattedDateTitle
//            titleTextView.text = entry.title
//            titleTextView.textColor = .label
//
//            textView.text = entry.body
//            textView.textColor = .label
//        } else {
//            if let prefilledTitle,
//               !prefilledTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                titleTextView.text = prefilledTitle
//                titleTextView.textColor = .label
//            } else {
//                titleTextView.text = titlePlaceholderText
//                titleTextView.textColor = .systemGray3
//            }
//
//            setupBodyPlaceholder()
//        }
//    }
//
//    private func applyTitleStyle() {
//        titleTextView.font = UIFont.preferredFont(forTextStyle: .title1)
//        titleTextView.adjustsFontForContentSizeCategory = true
//        titleTextView.backgroundColor = .clear
//        titleTextView.isScrollEnabled = false
//        titleTextView.textContainerInset = .zero
//        titleTextView.textContainer.lineFragmentPadding = 0
//    }
//
//    private func setupBodyPlaceholder() {
//        guard existingEntry == nil else { return }
//        textView.text = bodyPlaceholderText
//        textView.textColor = .systemGray3
//    }
//
//    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
//        let rawTitle = titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
//        let title = (rawTitle == titlePlaceholderText) ? "" : rawTitle
//
//        let rawBody = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
//        let body = (rawBody == bodyPlaceholderText) ? "" : rawBody
//
//        guard !title.isEmpty || !body.isEmpty else {
//            closeAfterSave()
//            return
//        }
//
//        if let old = existingEntry {
//            let updated = JournalEntry(
//                id: old.id,
//                title: title,
//                body: body,
//                date: old.date,
//                type: old.type,
//                question: old.question,
//                category: old.category
//            )
//            JournalStore.shared.update(updated)
//        } else {
//            let newEntry = JournalEntry(
//                title: title.isEmpty ? "Untitled" : title,
//                body: body,
//                date: Date(),
//                type: .regular,
//                question: nil,
//                category: nil
//            )
//            JournalStore.shared.add(newEntry)
//        }
//
//        closeAfterSave()
//    }
//
//    private func closeAfterSave() {
//        if let nav = navigationController,
//           nav.viewControllers.count == 1,
//           nav.presentingViewController != nil {
//            nav.dismiss(animated: true)
//        } else {
//            navigationController?.popViewController(animated: true)
//        }
//    }
//}
//
//extension BlankJournalViewController: UITextViewDelegate {
//
//    func textView(_ textView: UITextView,
//                  shouldChangeTextIn range: NSRange,
//                  replacementText text: String) -> Bool {
//        if textView === titleTextView {
//            let maxTitleLength = 300
//            let current = textView.text ?? ""
//            let newLength = current.count + text.count - range.length
//            return newLength <= maxTitleLength
//        } else {
//            let maxBodyLength = 1500
//            let current = textView.text ?? ""
//            let newLength = current.count + text.count - range.length
//            return newLength <= maxBodyLength
//        }
//    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView === titleTextView, textView.text == titlePlaceholderText {
//            textView.text = ""
//            textView.textColor = .label
//        }
//
//        if textView === self.textView, textView.text == bodyPlaceholderText {
//            textView.text = ""
//            textView.textColor = .label
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView === titleTextView,
//           textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            textView.text = titlePlaceholderText
//            textView.textColor = .systemGray3
//        }
//
//        if textView === self.textView,
//           textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            setupBodyPlaceholder()
//        }
//    }
//}

import UIKit

class BlankJournalViewController: UIViewController {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var textView: UITextView!

    var existingEntry: JournalEntry?
    var prefilledTitle: String?

    private let titlePlaceholderText = "Title"
    private let bodyPlaceholderText = "Start writing what’s on your mind today..."

    private var isPrefilledHomeTitle: Bool {
        guard existingEntry == nil else { return false }
        let value = prefilledTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !value.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "New Journal"

        titleTextView.delegate = self
        textView.delegate = self

        applyTitleStyle()

        if let entry = existingEntry {
            navigationItem.title = entry.formattedDateTitle
            titleTextView.text = entry.title
            titleTextView.textColor = .label
            titleTextView.isEditable = true
            titleTextView.isSelectable = true

            textView.text = entry.body
            textView.textColor = .label
        } else {
            if isPrefilledHomeTitle {
                titleTextView.text = prefilledTitle!.trimmingCharacters(in: .whitespacesAndNewlines)
                titleTextView.textColor = .label

                // Fixed title: not editable on Home modal flow
                titleTextView.isEditable = false
                titleTextView.isSelectable = false
                titleTextView.isUserInteractionEnabled = false
            } else {
                titleTextView.text = titlePlaceholderText
                titleTextView.textColor = .systemGray3
                titleTextView.isEditable = true
                titleTextView.isSelectable = true
                titleTextView.isUserInteractionEnabled = true
            }

            setupBodyPlaceholder()
        }
    }

    private func applyTitleStyle() {
        titleTextView.font = UIFont.preferredFont(forTextStyle: .title1)
        titleTextView.adjustsFontForContentSizeCategory = true
        titleTextView.backgroundColor = .clear
        titleTextView.isScrollEnabled = false
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
    }

    private func setupBodyPlaceholder() {
        guard existingEntry == nil else { return }
        textView.text = bodyPlaceholderText
        textView.textColor = .systemGray3
    }

    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        let rawTitle = titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = (rawTitle == titlePlaceholderText) ? "" : rawTitle

        let rawBody = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = (rawBody == bodyPlaceholderText) ? "" : rawBody

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
            nav.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension BlankJournalViewController: UITextViewDelegate {

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if textView === titleTextView {
            // If fixed prefilled home title, block edits fully
            if isPrefilledHomeTitle {
                return false
            }

            let maxTitleLength = 300
            let current = textView.text ?? ""
            let newLength = current.count + text.count - range.length
            return newLength <= maxTitleLength
        } else {
            let maxBodyLength = 1500
            let current = textView.text ?? ""
            let newLength = current.count + text.count - range.length
            return newLength <= maxBodyLength
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === titleTextView, textView.text == titlePlaceholderText {
            textView.text = ""
            textView.textColor = .label
        }

        if textView === self.textView, textView.text == bodyPlaceholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === titleTextView,
           !isPrefilledHomeTitle,
           textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = titlePlaceholderText
            textView.textColor = .systemGray3
        }

        if textView === self.textView,
           textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setupBodyPlaceholder()
        }
    }
}
