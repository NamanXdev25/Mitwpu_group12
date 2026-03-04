import UIKit

final class MemoriesViewController: UIViewController,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate,
                                    AddMemoryDelegate,
                                    MemoryDeleteDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!

    // MARK: - Data
    private var memories: [Memory] = []
    private var groupedMemories: [(month: Int, year: Int, items: [Memory])] = []

    // MARK: - Filter State
    private var isFiltering = false
    private var filteredMemories: [Memory] = []
    private var selectedMonth: Int?
    private var selectedYear: Int?

    private let calendar = Calendar.current

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        memories = MemoryStore.load()
        sortAndGroupMemories()

        configureCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.cornerRadius = addButton.bounds.height / 2
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView.setCollectionViewLayout(layout, animated: false)

        collectionView.register(
            UINib(nibName: "MemoryMonthGroupCell", bundle: nil),
            forCellWithReuseIdentifier: MemoryMonthGroupCell.reuseIdentifier
        )
    }

    // MARK: - Filter
    @IBAction func filterTapped(_ sender: UIBarButtonItem) {
        isFiltering ? clearFilter() : presentFilterSheet()
    }

    private func presentFilterSheet() {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)

        let pickerVC = storyboard.instantiateViewController(
            withIdentifier: "MonthYearPickerViewController"
        ) as! MonthYearPickerViewController

        pickerVC.onApply = { [weak self] month, year in
            self?.applyFilter(month: month, year: year)
        }

        pickerVC.modalPresentationStyle = .pageSheet

        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.custom { _ in 300 }]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 24
        }

        present(pickerVC, animated: true)
    }

    private func applyFilter(month: Int, year: Int) {
        selectedMonth = month
        selectedYear = year
        isFiltering = true

        filteredMemories = memories.filter {
            let c = calendar.dateComponents([.month, .year], from: $0.date)
            return c.month == month && c.year == year
        }

        sortAndGroupMemories()
        collectionView.reloadData()
    }

    private func clearFilter() {
        isFiltering = false
        selectedMonth = nil
        selectedYear = nil
        filteredMemories.removeAll()

        sortAndGroupMemories()
        collectionView.reloadData()
    }

    // MARK: - Add Memory
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)

        let popup = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryPopupViewController"
        ) as! AddMemoryPopupViewController

        popup.modalPresentationStyle = .popover
        popup.preferredContentSize = CGSize(width: 260, height: 150)

        popup.onCamera = { [weak self] in
            self?.presentImagePicker(sourceType: .camera)
        }

        popup.onPhotos = { [weak self] in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }

        guard let popover = popup.popoverPresentationController else { return }
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = [.up, .down]
        popover.delegate = popup

        present(popup, animated: true)
    }

    // MARK: - Image Picker
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }

        picker.dismiss(animated: true) {
            self.openAddMemoryScreen(with: image)
        }
    }

    private func openAddMemoryScreen(with image: UIImage) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)

        let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryViewController"
        ) as! AddMemoryViewController

        addVC.image = image
        addVC.delegate = self

        present(UINavigationController(rootViewController: addVC), animated: true)
    }

    // MARK: - Delegates
    func didAddMemory(_ memory: Memory) {
        memories.append(memory)
        MemoryStore.save(memories)
        sortAndGroupMemories()
        collectionView.reloadData()

        // Award coins for new memory (once per day)
        CoinRewardService.shared.awardMemoryCoinsIfEligible(on: self)
    }



    func didDeleteMemory(at index: Int) {
        memories.remove(at: index)
        MemoryStore.save(memories)
        sortAndGroupMemories()
        collectionView.reloadData()
    }

    // MARK: - Grouping (CHANGED TO MONTHLY)
    private func sortAndGroupMemories() {
        let source = isFiltering ? filteredMemories : memories

        // Group by month and year
        let grouped = Dictionary(grouping: source) { memory -> String in
            let components = calendar.dateComponents([.month, .year], from: memory.date)
            return "\(components.year!)-\(components.month!)"
        }
        
        groupedMemories = grouped.map { key, memories in
            let parts = key.split(separator: "-")
            let year = Int(parts[0])!
            let month = Int(parts[1])!
            return (month: month, year: year, items: memories.sorted { $0.date > $1.date })
        }
        .sorted { a, b in
            // Sort by year descending, then month descending
            if a.year != b.year {
                return a.year > b.year
            }
            return a.month > b.month
        }
    }

    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        groupedMemories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MemoryMonthGroupCell.reuseIdentifier,
            for: indexPath
        ) as! MemoryMonthGroupCell

        let group = groupedMemories[indexPath.item]
        cell.configure(with: group.items, month: group.month, year: group.year)

        cell.onTap = { [weak self] in
            self?.openViewer(groupIndex: indexPath.item)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        return CGSize(width: width, height: 280)
    }

    // MARK: - Viewer
    private func openViewer(groupIndex: Int) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)
        
        let navController = storyboard.instantiateViewController(
            withIdentifier: "MonthMemoriesNavigationController"
        ) as! UINavigationController
        
        let monthVC = navController.viewControllers.first as! MonthMemoriesViewController
        
        let group = groupedMemories[groupIndex]
        monthVC.memories = group.items
        monthVC.month = group.month
        monthVC.year = group.year
        
        // Normal modal presentation with dimmed background
        navController.modalPresentationStyle = .pageSheet
        
        // Optional: Configure the sheet presentation
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
        }
        
        present(navController, animated: true)
    }
}
