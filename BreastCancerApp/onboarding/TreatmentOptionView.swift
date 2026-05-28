import UIKit

class TreatmentOptionView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var checkmarkImageView: UIImageView!

    var isSelectedOption: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TreatmentOptionView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        updateSelectionState()
    }

    @objc private func handleTap() {
        onTap?()
    }

    private func updateSelectionState() {
        if isSelectedOption {
            contentView.borderWidth = 2
            contentView.borderColor = UIColor(named: "OnboardingPrimaryColor")
            checkmarkImageView.isHidden = false
        } else {
            contentView.borderWidth = 0
            contentView.borderColor = nil
            checkmarkImageView.isHidden = true
        }
    }
}
