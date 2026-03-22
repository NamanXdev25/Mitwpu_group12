import UIKit

final class MemorySavedPopupView: UIView {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var viewMemoryButton: UIButton!
    @IBOutlet private weak var stayHomeButton: UIButton!

    var onViewMemory: (() -> Void)?
    var onStayHome: (() -> Void)?

    private let gradientLayer = CAGradientLayer()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))

    static func instantiate() -> MemorySavedPopupView {
        let nib = UINib(nibName: "MemorySavedPopupView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? MemorySavedPopupView else {
            fatalError("Could not load MemorySavedPopupView.xib")
        }
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        gradientLayer.frame = viewMemoryButton.bounds
    }

    func configure(with image: UIImage?) {
        previewImageView.image = image
    }

    func show(in parentView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        parentView.addSubview(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ])

        forceCardLayout()
        layoutIfNeeded()

        cardView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.cardView.transform = .identity
        }
    }

    func dismissAnimated(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }

    @IBAction private func viewMemoryTapped(_ sender: UIButton) {
        onViewMemory?()
    }

    @IBAction private func stayHomeTapped(_ sender: UIButton) {
        onStayHome?()
    }
}

private extension MemorySavedPopupView {
    func configureUI() {
        backgroundColor = .clear

        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)

        let dimView = UIView()
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        blurView.contentView.addSubview(dimView)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor)
        ])

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 30
        cardView.layer.masksToBounds = true

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 18

        titleLabel.text = "Memory saved 🌸"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.14, green: 0.16, blue: 0.24, alpha: 1)

        subtitleLabel.text = "Your moment has been added to Little Moments"
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        subtitleLabel.textColor = UIColor(red: 0.30, green: 0.35, blue: 0.43, alpha: 1)

        detailLabel.text = "You can view it anytime in Mindfulness"
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        detailLabel.textColor = UIColor(red: 0.58, green: 0.61, blue: 0.69, alpha: 1)

        viewMemoryButton.setTitle("View Memory", for: .normal)
        viewMemoryButton.setTitleColor(.white, for: .normal)
        viewMemoryButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        viewMemoryButton.layer.cornerRadius = 18
        viewMemoryButton.clipsToBounds = true

        gradientLayer.colors = [
            UIColor(red: 0.98, green: 0.67, blue: 0.82, alpha: 1).cgColor,
            UIColor(red: 0.95, green: 0.56, blue: 0.71, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 18

        if gradientLayer.superlayer == nil {
            viewMemoryButton.layer.insertSublayer(gradientLayer, at: 0)
        }

        stayHomeButton.setTitle("Stay on Home", for: .normal)
        stayHomeButton.setTitleColor(UIColor(red: 0.42, green: 0.46, blue: 0.56, alpha: 1), for: .normal)
        stayHomeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        stayHomeButton.backgroundColor = .clear
    }

    func forceCardLayout() {
        guard let superview = cardView.superview else { return }

        cardView.translatesAutoresizingMaskIntoConstraints = false

        let constraintsToRemove = superview.constraints.filter {
            ($0.firstItem as? UIView) == cardView || ($0.secondItem as? UIView) == cardView
        }
        NSLayoutConstraint.deactivate(constraintsToRemove)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 355),
            cardView.heightAnchor.constraint(equalToConstant: 450)
        ])
    }
}
