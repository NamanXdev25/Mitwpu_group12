import UIKit

class ProgressBarView: UIView {
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var contentView: UIView!
    private var progressFillView: UIView?
    private var progressWidthConstraint: NSLayoutConstraint?

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
        let nib = UINib(nibName: "ProgressBarView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView

        guard contentView != nil else { return }

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        progressFillView = contentView.viewWithTag(100)

        if let fillView = progressFillView {
            progressWidthConstraint = fillView.constraints.first(where: { $0.firstAttribute == .width })
        }
    }

    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0, min(1, progress))
        let targetWidth = bounds.width * clampedProgress

        progressWidthConstraint?.constant = targetWidth

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    func setProgress(currentStep: Int, totalSteps: Int, animated: Bool = true) {
        let progress = CGFloat(currentStep) / CGFloat(totalSteps)
        setProgress(progress, animated: animated)
    }
}
