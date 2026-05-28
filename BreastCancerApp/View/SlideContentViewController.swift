import UIKit

class SlideContentViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var actionButton: UIButton!

    var slide: MindfulnessSlide?
    var pageIndex: Int?
    var didTapButton: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        guard let slide = slide else { return }
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
        actionButton.setTitle(slide.buttonText, for: .normal)
    }

    @IBAction func buttonPressed(_: UIButton) {
        didTapButton?()
    }
}
