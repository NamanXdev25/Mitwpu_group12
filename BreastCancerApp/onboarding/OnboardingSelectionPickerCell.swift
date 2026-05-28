import UIKit

class OnboardingSelectionPickerCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var placeholderLabel: UILabel!

    var onOptionSelected: ((String) -> Void)?

    func configure(title: String, fieldName _: String, options: [String], selectedValue: String?) {
        titleLabel.text = title

        let actions = options.map { option in
            UIAction(
                title: option,
                state: option == selectedValue ? .on : .off
            ) { [weak self] _ in
                self?.onOptionSelected?(option)
            }
        }

        if let cardView = contentView.subviews.first,
           let menuButton = cardView.subviews.compactMap({ $0 as? UIButton }).first {
            menuButton.menu = UIMenu(title: "", children: actions)
            menuButton.showsMenuAsPrimaryAction = true
        }
    }
}
