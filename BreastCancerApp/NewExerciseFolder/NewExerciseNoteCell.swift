//
//  NewExerciseNoteCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/02/26.
//

import UIKit

class NewExerciseNoteCell: UICollectionViewCell {
    
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with note: String) {
        noteLabel.text = note
    }
}
