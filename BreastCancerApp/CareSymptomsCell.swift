import UIKit

// MARK: - Delegate Protocol
protocol CareSymptomsCellDelegate: AnyObject {
    func careSymptomsCellDidTapViewInsights(_ cell: CareSymptomsCell)
}

class CareSymptomsCell: UICollectionViewCell {

    @IBOutlet weak var SymptomsContainer: UIView!
    @IBOutlet weak var SymptomsLabel: UILabel!
    @IBOutlet weak var InsightCellCollectionView: UICollectionView!
    @IBOutlet weak var SeperatorView: UIView!
    @IBOutlet weak var ViewInsightsButton: UIButton!

    weak var delegate: CareSymptomsCellDelegate?

    private var symptoms: [String] = []

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInternalCollectionView()
    }

    // MARK: - Setup
    private func setupInternalCollectionView() {
        InsightCellCollectionView.delegate = self
        InsightCellCollectionView.dataSource = self

        InsightCellCollectionView.register(
            UINib(nibName: "CareInsightCell", bundle: nil),
            forCellWithReuseIdentifier: "CareInsightCell"
        )

        InsightCellCollectionView.register(
            UINib(nibName: "CareSymptomEmptyCell", bundle: nil),
            forCellWithReuseIdentifier: "CareSymptomEmptyCell"
        )

        InsightCellCollectionView.contentInset = .zero
        InsightCellCollectionView.scrollIndicatorInsets = .zero
        InsightCellCollectionView.backgroundColor = .clear

        if let layout = InsightCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = .zero
        }
    }

    // MARK: - Public Configure
    func configure(title: String, loggedSymptoms: [String]) {
        SymptomsLabel.text = title
        self.symptoms = loggedSymptoms

        if let layout = InsightCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if loggedSymptoms.isEmpty {
                layout.sectionInset = .zero
            } else if loggedSymptoms.count == 1 {
                layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            } else {
                layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }

        InsightCellCollectionView.reloadData()
    }

    // MARK: - IBAction
    @IBAction func viewInsightsButtonTapped(_ sender: UIButton) {
        delegate?.careSymptomsCellDidTapViewInsights(self)
    }
}

// MARK: - UICollectionViewDataSource
extension CareSymptomsCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return symptoms.isEmpty ? 1 : symptoms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if symptoms.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CareSymptomEmptyCell",
                for: indexPath
            ) as! CareSymptomEmptyCell
            cell.Nosymptomsloggedcell.text = "No symptoms logged"
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareInsightCell",
            for: indexPath
        ) as! CareInsightCell

        let label = symptoms[indexPath.item]
        cell.InsightLabel.text = label

        let isOverflow = label.hasPrefix("+")
        cell.contentView.backgroundColor = isOverflow
            ? UIColor.clear
            : UIColor(named: "SymptomChipColor") ?? UIColor.clear
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CareSymptomsCell: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        if symptoms.isEmpty {
            return CGSize(
                width: collectionView.bounds.width,
                height: collectionView.bounds.height
            )
        }

        let text = symptoms[indexPath.item]
        let textWidth = text.size(
            withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
        ).width
        return CGSize(width: textWidth + 30, height: 51)
    }
}

// MARK: - UICollectionViewDelegate (optional interactions)
extension CareSymptomsCell: UICollectionViewDelegate { }
