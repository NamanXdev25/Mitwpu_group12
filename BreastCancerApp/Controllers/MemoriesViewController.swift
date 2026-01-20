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
    private var groupedMemories: [(date: Date, items: [Memory])] = []

    // MARK: - Filter State
    private var isFiltering = false
    private var filteredMemories: [Memory] = []
    private var selectedMonth: Int?
    private var selectedYear: Int?

    private let calendar = Calendar.current

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Memories"

        memories = MemoryStore.load()
        sortAndGroupMemories()

        configureCollectionView()
        configureAddButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.cornerRadius = addButton.bounds.height / 2
    }

    // MARK: - UI
    private func configureAddButton() {
        addButton.configuration = nil
        addButton.backgroundColor = .pink
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        collectionView.setCollectionViewLayout(layout, animated: false)

        collectionView.register(
            UINib(nibName: "MemoryImageCell", bundle: nil),
            forCellWithReuseIdentifier: MemoryImageCell.reuseIdentifier
        )

        
        collectionView.register(
            UINib(nibName: "MemoryHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MemoryHeaderView.reuseIdentifier
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
    }

    func didDeleteMemory(at index: Int) {
        memories.remove(at: index)
        MemoryStore.save(memories)
        sortAndGroupMemories()
        collectionView.reloadData()
    }

    // MARK: - Grouping
    private func sortAndGroupMemories() {
        let source = isFiltering ? filteredMemories : memories

        groupedMemories = Dictionary(grouping: source) {
            calendar.startOfDay(for: $0.date)
        }
        .map { ($0.key, $0.value) }
        .sorted { $0.0 > $1.0 }
    }

    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        groupedMemories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        groupedMemories[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MemoryImageCell.reuseIdentifier,
            for: indexPath
        ) as! MemoryImageCell

        let memory = groupedMemories[indexPath.section].items[indexPath.item]
        cell.configure(with: memory.image!)

        cell.onTap = { [weak self] in
            self?.openViewer(section: indexPath.section, item: indexPath.item)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow: CGFloat = 4
        let spacing: CGFloat = 8
        let totalSpacing = (itemsPerRow - 1) * spacing + 24
        let width = floor((collectionView.bounds.width - totalSpacing) / itemsPerRow)

        return CGSize(width: width, height: width)
    }

    // MARK: - Viewer
    private func openViewer(section: Int, item: Int) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)

        let pageVC = storyboard.instantiateViewController(
            withIdentifier: "MemoryPageViewController"
        ) as! MemoryPageViewController

        let flat = groupedMemories.flatMap { $0.items }
        let startIndex = groupedMemories[..<section]
            .reduce(0) { $0 + $1.items.count } + item

        pageVC.memories = flat
        pageVC.startIndex = startIndex
        pageVC.deleteDelegate = self
        pageVC.modalPresentationStyle = .fullScreen

        present(pageVC, animated: true)
    }
}
