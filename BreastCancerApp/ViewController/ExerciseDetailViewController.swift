import UIKit

class ExerciseDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DetailExerciseCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    
    var pageTitle: String = ""

   
    var sections: [DetailSectionData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = pageTitle

        // CollectionView setup
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear

        // Register nibs
        collectionView.register(UINib(nibName: "DetailExerciseCell", bundle: nil), forCellWithReuseIdentifier: "DetailExerciseCell")
        collectionView.register(UINib(nibName: "SectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")

        loadData()
    }

    //Loading JSON
    func loadData() {
        guard let url = Bundle.main.url(forResource: "exerciseDetails", withExtension: "json") else {
            print("Error: exerciseDetails.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let allData = try JSONDecoder().decode(ExerciseDatabase.self, from: data)

            if let specificPageData = allData[pageTitle] {
                self.sections = specificPageData
            } else {
                self.sections = []
            }

            collectionView.reloadData()
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }

    // Layout
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 20, bottom: 4, trailing: 20)
        
       
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    // UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].exercises.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailExerciseCell", for: indexPath) as! DetailExerciseCell
        let item = sections[indexPath.section].exercises[indexPath.row]

        // Configure cell
        cell.configure(title: item.title, subtitle: item.subtitle, time: item.time, imageName: item.imageName)

        
        cell.delegate = self

        return cell
    }

    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
        header.titleLabel.text = sections[indexPath.section].title
        header.titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        header.titleLabel.textColor = .black
        return header
    }

    // DetailExerciseCellDelegate
    func didTapChevron(on cell: DetailExerciseCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let item = sections[indexPath.section].exercises[indexPath.row]

        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        if let playerVC = storyboard.instantiateViewController(withIdentifier: "ExercisePlayerViewController") as? ExercisePlayerViewController {
            playerVC.exerciseData = item
            self.navigationController?.pushViewController(playerVC, animated: true)
        } else {
            print("Error: Could not instantiate ExercisePlayerViewController")
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section].exercises[indexPath.row]
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        if let playerVC = storyboard.instantiateViewController(withIdentifier: "ExercisePlayerViewController") as? ExercisePlayerViewController {
            playerVC.exerciseData = item
            self.navigationController?.pushViewController(playerVC, animated: true)
        }
    }
}
