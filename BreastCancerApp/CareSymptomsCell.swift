import UIKit

class CareSymptomsCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var SymptomsContainer: UIView!
    @IBOutlet weak var SymptomsLabel: UILabel!
    @IBOutlet weak var InsightCellCollectionView: UICollectionView!
    @IBOutlet weak var SeperatorView: UIView!
    @IBOutlet weak var ViewInsightsButton: UIButton!
    
    var symptoms: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInternalCollectionView()
    }
    
    private func setupInternalCollectionView() {
        InsightCellCollectionView.delegate = self
        InsightCellCollectionView.dataSource = self
        
        let nib = UINib(nibName: "CareInsightCell", bundle: nil)
        InsightCellCollectionView.register(nib, forCellWithReuseIdentifier: "CareInsightCell")
        
        if let layout = InsightCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
        }
    }

    func configure(title: String, loggedSymptoms: [String]) {
        SymptomsLabel.text = title
        self.symptoms = loggedSymptoms
        InsightCellCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareInsightCell", for: indexPath) as! CareInsightCell
        cell.InsightLabel.text = symptoms[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = symptoms[indexPath.item]
        let width = text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]).width + 30
        return CGSize(width: width, height: 51)
    }
}
