import UIKit

class HomeMoodCell: UICollectionViewCell {
    @IBOutlet var MoodCellView: UIView!
    @IBOutlet var MoodTitleLabel: UILabel!

    @IBOutlet var ExcitedImageView: UIImageView!
    @IBOutlet var ExcitedLabel: UILabel!

    @IBOutlet var HappyImageView: UIImageView!
    @IBOutlet var HappyLabel: UILabel!

    @IBOutlet var SadImageView: UIImageView!
    @IBOutlet var SadLabel: UILabel!

    @IBOutlet var TiredImageView: UIImageView!
    @IBOutlet var TiredLabel: UILabel!

    @IBOutlet var AnxiousImageView: UIImageView!
    @IBOutlet var AnxiousLabel: UILabel!

    var onMoodTapped: ((Mood) -> Void)?

    private var currentMoods: [Mood] = []
    private var didSetupTapHandlers = false
    private var selectedMoodIndex: Int?

    private let selectedAlpha: CGFloat = 1.0
    private let fadedAlpha: CGFloat = 0.3

    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageViews()
        setupTapHandlersIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedMoodIndex = nil
        applySelectionState(animated: false)
    }

    private func setupImageViews() {
        let imageViews = [ExcitedImageView, HappyImageView, SadImageView, TiredImageView, AnxiousImageView]
        for imageView in imageViews {
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
        }
    }

    private func setupTapHandlersIfNeeded() {
        guard !didSetupTapHandlers else { return }
        didSetupTapHandlers = true

        let tapTargets: [UIView?] = [
            ExcitedImageView.superview,
            HappyImageView.superview,
            SadImageView.superview,
            TiredImageView.superview,
            AnxiousImageView.superview,
        ]

        for (index, view) in tapTargets.enumerated() {
            guard let targetView = view else { continue }
            targetView.tag = index
            targetView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleMoodTap(_:)))
            targetView.addGestureRecognizer(tap)
        }
    }

    @objc
    private func handleMoodTap(_ gesture: UITapGestureRecognizer) {
        guard
            let tappedView = gesture.view,
            tappedView.tag >= 0,
            tappedView.tag < currentMoods.count
        else { return }

        selectedMoodIndex = tappedView.tag
        applySelectionState(animated: true)
        onMoodTapped?(currentMoods[tappedView.tag])
    }

    func configure(
        title: String,
        moods: [Mood],
        selectedMoodKey: String?,
        hasUserSelectedMood: Bool
    ) {
        MoodTitleLabel.text = title
        currentMoods = moods

        guard moods.count >= 5 else { return }

        ExcitedLabel.text = moods[0].title
        ExcitedImageView.image = UIImage(named: moods[0].imageName)

        HappyLabel.text = moods[1].title
        HappyImageView.image = UIImage(named: moods[1].imageName)

        SadLabel.text = moods[2].title
        SadImageView.image = UIImage(named: moods[2].imageName)

        TiredLabel.text = moods[3].title
        TiredImageView.image = UIImage(named: moods[3].imageName)

        AnxiousLabel.text = moods[4].title
        AnxiousImageView.image = UIImage(named: moods[4].imageName)

        if hasUserSelectedMood, let selectedMoodKey {
            selectedMoodIndex = moods.firstIndex { $0.title.lowercased() == selectedMoodKey.lowercased() }
        } else {
            selectedMoodIndex = nil
        }

        applySelectionState(animated: false)
    }

    private func applySelectionState(animated: Bool) {
        let imageViews: [UIImageView] = [
            ExcitedImageView, HappyImageView, SadImageView, TiredImageView, AnxiousImageView,
        ].compactMap { $0 }

        let labels: [UILabel] = [
            ExcitedLabel, HappyLabel, SadLabel, TiredLabel, AnxiousLabel,
        ].compactMap { $0 }

        let updates = {
            for index in 0 ..< min(imageViews.count, labels.count) {
                let isSelected = (self.selectedMoodIndex == index)
                let shouldFadeOthers = (self.selectedMoodIndex != nil)

                let alpha: CGFloat = shouldFadeOthers ? (isSelected ? self.selectedAlpha : self.fadedAlpha) : self.selectedAlpha
                imageViews[index].alpha = alpha
                labels[index].alpha = alpha
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
    }
}
