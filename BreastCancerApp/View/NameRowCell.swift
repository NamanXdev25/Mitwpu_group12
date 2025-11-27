//
//  NameRowCell.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 27/11/25.
//
import UIKit

class NameRowCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // styling
        textField.borderStyle = .none
        textField.placeholder = "Pill Name"
        lineView.backgroundColor = UIColor.systemGray4
    }
}

