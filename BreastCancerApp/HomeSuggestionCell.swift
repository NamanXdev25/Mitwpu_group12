import UIKit

class HomeSuggestionCell: UICollectionViewCell {

    @IBOutlet weak var SuggestionView: UIView!
    @IBOutlet weak var SuggestionImageView: UIImageView!
    @IBOutlet weak var SuggestionTitleLabel: UILabel!
    @IBOutlet weak var SuggestionSubheadLabel: UILabel!

    private var tapGesture: UITapGestureRecognizer?
    var onTap: (() -> Void)? {
        didSet {
            if onTap != nil {
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                contentView.addGestureRecognizer(tap)
                tapGesture = tap
            } else {
                if let tap = tapGesture {
                    contentView.removeGestureRecognizer(tap)
                    tapGesture = nil
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTap = nil
    }

    // MARK: - Configure
    func configure(with suggestion: Suggestion) {
        SuggestionTitleLabel.text = suggestion.title
        SuggestionSubheadLabel.text = suggestion.subtitle
        SuggestionImageView.image = UIImage(named: suggestion.imageName)
    }

    // MARK: - Tap
    @objc private func handleTap() {
        guard let onTap else { return }
        animatePress { onTap() }
    }

    private func animatePress(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            self.SuggestionView.alpha = 0.55
            self.SuggestionView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.SuggestionView.alpha = 1.0
                self.SuggestionView.transform = .identity
            }) { _ in
                completion()
            }
        }
    }

    // MARK: - Highlight feedback for breathing cell (no onTap)
    override var isHighlighted: Bool {
        didSet {
            guard onTap == nil else { return }
            UIView.animate(withDuration: 0.12, delay: 0,
                           options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.SuggestionView.alpha = self.isHighlighted ? 0.55 : 1.0
                self.SuggestionView.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }
}
