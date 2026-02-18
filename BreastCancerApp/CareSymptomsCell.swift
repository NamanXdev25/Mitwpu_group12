//import UIKit
//
//class CareSymptomsCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    @IBOutlet weak var SymptomsContainer: UIView!
//    @IBOutlet weak var SymptomsLabel: UILabel!
//    @IBOutlet weak var InsightCellCollectionView: UICollectionView!
//    @IBOutlet weak var SeperatorView: UIView!
//    @IBOutlet weak var ViewInsightsButton: UIButton!
//    
//    var symptoms: [String] = []
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupInternalCollectionView()
//    }
//    
//    private func setupInternalCollectionView() {
//        InsightCellCollectionView.delegate = self
//        InsightCellCollectionView.dataSource = self
//        
//        let nib = UINib(nibName: "CareInsightCell", bundle: nil)
//        InsightCellCollectionView.register(nib, forCellWithReuseIdentifier: "CareInsightCell")
//        
//        if let layout = InsightCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//            layout.minimumInteritemSpacing = 8
//        }
//    }
//
//    func configure(title: String, loggedSymptoms: [String]) {
//        SymptomsLabel.text = title
//        self.symptoms = loggedSymptoms
//        InsightCellCollectionView.reloadData()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return symptoms.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareInsightCell", for: indexPath) as! CareInsightCell
//        cell.InsightLabel.text = symptoms[indexPath.item]
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let text = symptoms[indexPath.item]
//        let width = text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]).width + 30
//        return CGSize(width: width, height: 51)
//    }
//}
//
//import UIKit
//
//// MARK: - Delegate Protocol
//protocol CareSymptomsCellDelegate: AnyObject {
//    func careSymptomsCellDidTapViewInsights(_ cell: CareSymptomsCell)
//}
//
//class CareSymptomsCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    @IBOutlet weak var SymptomsContainer: UIView!
//    @IBOutlet weak var SymptomsLabel: UILabel!
//    @IBOutlet weak var InsightCellCollectionView: UICollectionView!
//    @IBOutlet weak var SeperatorView: UIView!
//    @IBOutlet weak var ViewInsightsButton: UIButton!
//
//    weak var delegate: CareSymptomsCellDelegate?
//
//    private var allSymptoms: [String] = []
//    private var displaySymptoms: [String] = []
//    private var isEmpty: Bool = true
//    private let maxVisible = 3
//
//    private let emptyCellIdentifier   = "CareSymptomEmptyCell"
//    private let insightCellIdentifier = "CareInsightCell"
//
//    // MARK: - Lifecycle
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupInternalCollectionView()
//    }
//
//    // MARK: - Setup
//    private func setupInternalCollectionView() {
//        InsightCellCollectionView.delegate = self
//        InsightCellCollectionView.dataSource = self
//        InsightCellCollectionView.backgroundColor = .clear
//        InsightCellCollectionView.isScrollEnabled = false
//
//        InsightCellCollectionView.register(
//            UINib(nibName: insightCellIdentifier, bundle: nil),
//            forCellWithReuseIdentifier: insightCellIdentifier
//        )
//        InsightCellCollectionView.register(
//            UINib(nibName: emptyCellIdentifier, bundle: nil),
//            forCellWithReuseIdentifier: emptyCellIdentifier
//        )
//
//        if let layout = InsightCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//            layout.minimumInteritemSpacing = 8
//            layout.minimumLineSpacing = 8
//        }
//    }
//
//    // MARK: - Configure
//    func configure(title: String, loggedSymptoms: [String]) {
//        SymptomsLabel.text = title
//        allSymptoms = loggedSymptoms
//        isEmpty = loggedSymptoms.isEmpty
//
//        // Separator and Log Symptoms button always visible
//        SeperatorView.isHidden = false
//        ViewInsightsButton.isHidden = false
//
//        if isEmpty {
//            displaySymptoms = []
//        } else {
//            buildDisplaySymptoms()
//        }
//
//        InsightCellCollectionView.reloadData()
//    }
//
//    // Caps at 3 real symptoms + "+N" overflow chip
//    private func buildDisplaySymptoms() {
//        let overflow = allSymptoms.count - maxVisible
//        if overflow > 0 {
//            displaySymptoms = Array(allSymptoms.prefix(maxVisible)) + ["+\(overflow)"]
//        } else {
//            displaySymptoms = allSymptoms
//        }
//    }
//
//    // MARK: - Actions
//    @IBAction func viewInsightsButtonTapped(_ sender: UIButton) {
//        delegate?.careSymptomsCellDidTapViewInsights(self)
//    }
//
//    // MARK: - UICollectionViewDataSource
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // Empty state: 1 item (CareSymptomEmptyCell)
//        // Has symptoms: show displaySymptoms chips (CareInsightCell)
//        return isEmpty ? 1 : displaySymptoms.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if isEmpty {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: emptyCellIdentifier,
//                for: indexPath
//            ) as! CareSymptomEmptyCell
//            cell.Nosymptomsloggedcell.text = "No symptoms logged"
//            return cell
//        } else {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: insightCellIdentifier,
//                for: indexPath
//            ) as! CareInsightCell
//            cell.InsightLabel.text = displaySymptoms[indexPath.item]
//            return cell
//        }
//    }
//
//    // MARK: - UICollectionViewDelegateFlowLayout
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if isEmpty {
//            // Full width so the "No symptoms logged" text is centred, same height as chip
//            return CGSize(width: collectionView.bounds.width, height: 34)
//        }
//        let text = displaySymptoms[indexPath.item]
//        let font = UIFont.systemFont(ofSize: 14)
//        let textWidth = text.size(withAttributes: [.font: font]).width
//        return CGSize(width: textWidth + 30, height: 51)
//    }
//}

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

    /// Chip labels: empty array → show empty state; 1-4 strings → show chips (last one may be "+N")
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

        // Symptom chip cell
        InsightCellCollectionView.register(
            UINib(nibName: "CareInsightCell", bundle: nil),
            forCellWithReuseIdentifier: "CareInsightCell"
        )

        // Empty-state cell
        InsightCellCollectionView.register(
            UINib(nibName: "CareSymptomEmptyCell", bundle: nil),
            forCellWithReuseIdentifier: "CareSymptomEmptyCell"
        )

        // Zero out content inset so the empty-state label starts at the same
        // leading edge as the "Symptoms logged" title label above it.
        InsightCellCollectionView.contentInset = .zero
        InsightCellCollectionView.scrollIndicatorInsets = .zero
        InsightCellCollectionView.backgroundColor = .clear

        if let layout = InsightCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = .zero   // no extra leading padding before first chip/empty cell
        }
    }

    // MARK: - Public Configure
    /// Pass an empty array when no symptoms have been logged today.
    /// Pass up to 3 symptom names (+ optional "+N" overflow string) when symptoms exist.
    func configure(title: String, loggedSymptoms: [String]) {
        SymptomsLabel.text = title
        self.symptoms = loggedSymptoms

        // Both chips and empty state flush-align with the title.
        // The collection view's leading constraint in the XIB should match SymptomsLabel's leading.
        if let layout = InsightCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // top/bottom gives chips breathing room; left/right always 0 so chips align with title
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
        // Always show exactly 1 item: either the empty-state cell or the chips
        // (The chips are all rendered inside a single flow-layout collection view,
        //  so we return symptoms.count for chips and 1 for the empty state.)
        return symptoms.isEmpty ? 1 : symptoms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // ── Empty state ──────────────────────────────────────────────────────
        if symptoms.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CareSymptomEmptyCell",
                for: indexPath
            ) as! CareSymptomEmptyCell
            cell.Nosymptomsloggedcell.text = "No symptoms logged"
            return cell
        }

        // ── Symptom chip ─────────────────────────────────────────────────────
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareInsightCell",
            for: indexPath
        ) as! CareInsightCell

        let label = symptoms[indexPath.item]
        cell.InsightLabel.text = label

        // Style the overflow "+N" chip differently so it stands out
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

        // Empty-state cell fills the whole collection view
        if symptoms.isEmpty {
            return CGSize(
                width: collectionView.bounds.width,
                height: collectionView.bounds.height
            )
        }

        // Chip width = text width + horizontal padding
        let text = symptoms[indexPath.item]
        let textWidth = text.size(
            withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
        ).width
        return CGSize(width: textWidth + 30, height: 51)
    }
}

// MARK: - UICollectionViewDelegate (optional interactions)
extension CareSymptomsCell: UICollectionViewDelegate { }
