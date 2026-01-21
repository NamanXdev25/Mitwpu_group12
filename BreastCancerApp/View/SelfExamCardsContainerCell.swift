import UIKit

final class SelfExamCardsContainerCell: UICollectionViewCell,
                                        UICollectionViewDataSource,
                                        UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout {

    @IBOutlet private weak var innerCollectionView: UICollectionView!

    private let steps: [SelfExamStep] = [
        SelfExamStep(
            title: "Lying down",
            description: "Use opposite hands to examine each breast with two fingertip pads, using small circular motions & covering entire area of breast.",
            imageName: "lying_down"
        ),
        SelfExamStep(
            title: "In the shower",
            description: "Raise your right arm. Use the finger pads of your left hand to touch every part of your right breast. Feel gently for lumps or changes.",
            imageName: "in_shower"
        ),
        SelfExamStep(
            title: "Before a mirror",
            description: "Place your arms at sides. Check for discharge, puckering, dimpling or changes in skin texture. Look for changes in breast shape.",
            imageName: "before_mirror"
        )
    ]

    override func awakeFromNib() {
        super.awakeFromNib()

        innerCollectionView.delegate = self
        innerCollectionView.dataSource = self
        innerCollectionView.showsHorizontalScrollIndicator = false
        innerCollectionView.backgroundColor = .clear

        innerCollectionView.register(
            UINib(nibName: "SelfExamCardCell", bundle: nil),
            forCellWithReuseIdentifier: "SelfExamCardCell"
        )

        if let layout = innerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
            layout.estimatedItemSize = .zero
        }

        innerCollectionView.reloadData()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        steps.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SelfExamCardCell",
            for: indexPath
        ) as! SelfExamCardCell

        let step = steps[indexPath.item]
        cell.titleLabel.text = step.title
        cell.descriptionLabel.text = step.description
        cell.descriptionLabel.numberOfLines = 3
        cell.descriptionLabel.lineBreakMode = .byTruncatingTail
        cell.thumbnailImageView.image = UIImage(named: step.imageName)

        cell.cardView.layer.cornerRadius = 12
        cell.cardView.layer.masksToBounds = true
        cell.cardView.backgroundColor = .white

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.frame.width - 32
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
}
