import UIKit

class JourneyViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private var diagnosisModel = DiagnosisModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Journey"
    }
    
    private func setupCollectionView() {
        // Register the XIB cell
        let nib = UINib(nibName: "DiagnosisCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "DiagnosisCell")
        
        // Set delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set background color
        collectionView.backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0)
        
        // Configure flow layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension JourneyViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // Just the diagnosis cell for now
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiagnosisCell", for: indexPath) as? DiagnosisCell else {
            print("❌ Failed to dequeue DiagnosisCell")
            return UICollectionViewCell()
        }
        
        print("✅ Cell dequeued successfully")
        
        // Configure the cell
        cell.configure(with: diagnosisModel)
        
        // Handle date selection
        cell.onDateSelected = { [weak self] date in
            print("📅 Date selected: \(date)")
            self?.diagnosisModel.diagnosisDate = date
        }
        
        // Handle save button tap
        cell.onSaveButtonTapped = { [weak self] in
            print("💾 Save button tapped")
            self?.diagnosisModel.status = "Completed"
        }
        
        // Handle cell height changes
        cell.onCellHeightChanged = { [weak self] in
            print("📏 Cell height changed")
            UIView.animate(withDuration: 0.3) {
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JourneyViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Use view.bounds.width instead of collectionView.bounds.width
        let totalWidth = view.bounds.width
        let padding: CGFloat = 32 // 16 on each side
        let cellWidth = totalWidth - padding
        
        print("📱 Screen width: \(UIScreen.main.bounds.width)")
        print("📐 View width: \(view.bounds.width)")
        print("✅ Calculated cell width: \(cellWidth)")
        
        // Get height based on cell state
        var height: CGFloat = 180
        
        if let cell = collectionView.cellForItem(at: indexPath) as? DiagnosisCell {
            height = cell.getCellHeight()
        }
        
        print("✅ Cell height: \(height)")
        print("📦 Final size: width=\(cellWidth), height=\(height)")
        
        return CGSize(width: cellWidth, height: height)
    }
}
