//
//  NewAppointmentNoteCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/03/26.
//

import UIKit

class NewAppointmentNoteCell: UICollectionViewCell {

    @IBOutlet weak var noteTextView: UITextView!

    var onTextChange: ((String) -> Void)?
    private let placeholder = "Add any additional notes or reminders..."

    override func awakeFromNib() {
        super.awakeFromNib()
        noteTextView.delegate = self
        noteTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        showPlaceholder()
    }

    func configure(text: String?) {
        if let t = text, !t.isEmpty {
            noteTextView.text = t
            noteTextView.textColor = .black
        } else {
            showPlaceholder()
        }
    }

    var currentText: String {
        let t = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return t == placeholder ? "" : t
    }

    private func showPlaceholder() {
        noteTextView.text = placeholder
        noteTextView.textColor = .lightGray
    }
}

extension NewAppointmentNoteCell: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showPlaceholder()
        }
        onTextChange?(currentText)
    }
}
