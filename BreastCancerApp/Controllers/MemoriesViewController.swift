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

        memories = MemoryStore.load()
        sortAndGroupMemories()

        configureUI()
        configureCollectionView()
        configureAddButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.cornerRadius = addButton.bounds.height / 2
    }

    // MARK: - UI
    private func configureUI() {
        title = "Memories"

        let filterButton = UIButton(type: .system)
        filterButton.setImage(
            UIImage(systemName: "line.3.horizontal.decrease"),
            for: .normal
        )
        filterButton.tintColor = isFiltering
            ? UIColor(named: "pink")
            : .label
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        blur.layer.cornerRadius = 18
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(filterButton)

        filterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blur.widthAnchor.constraint(equalToConstant: 36),
            blur.heightAnchor.constraint(equalToConstant: 36),
            filterButton.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            filterButton.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: blur)
    }

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
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView.setCollectionViewLayout(layout, animated: false)

        collectionView.register(
            UINib(nibName: "MemoryImageCell", bundle: nil),
            forCellWithReuseIdentifier: MemoryImageCell.reuseIdentifier
        )

        collectionView.register(
            MemoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MemoryHeaderView.reuseIdentifier
        )
    }

    // MARK: - Filter
    @objc private func filterTapped() {
        isFiltering ? clearFilter() : presentFilterSheet()
    }

    private func presentFilterSheet() {
        let pickerVC = MonthYearPickerViewController()

        pickerVC.onApply = { [weak self] month, year in
            self?.applyFilter(month: month, year: year)
        }

        pickerVC.modalPresentationStyle = .pageSheet

        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.custom { _ in 280 }]
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
        configureUI()
        collectionView.reloadData()
    }

    private func clearFilter() {
        isFiltering = false
        selectedMonth = nil
        selectedYear = nil
        filteredMemories.removeAll()

        sortAndGroupMemories()
        configureUI()
        collectionView.reloadData()
    }

    // MARK: - Add
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Add Memory",
            message: "Choose an option",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Open Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })

        alert.addAction(UIAlertAction(title: "Add from Gallery", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }




    // MARK: - Picker
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

    // MARK: - Navigation
    private func openAddMemoryScreen(with image: UIImage) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)

        let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryViewController"
        ) as! AddMemoryViewController

        addVC.image = image
        addVC.delegate = self

        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
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

        let grouped = Dictionary(grouping: source) {
            calendar.startOfDay(for: $0.date)
        }

        groupedMemories = grouped
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

    // MARK: - Headers
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MemoryHeaderView.reuseIdentifier,
            for: indexPath
        ) as! MemoryHeaderView

        header.label.text = formattedDate(groupedMemories[indexPath.section].date)
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }

    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow: CGFloat = 4
        let spacing: CGFloat = 8
        let sectionInsets: CGFloat = 24

        let totalSpacing = (itemsPerRow - 1) * spacing + sectionInsets
        let width = floor((collectionView.bounds.width - totalSpacing) / itemsPerRow)

        return CGSize(width: width, height: width)
    }

    // MARK: - Date Format
    private func formattedDate(_ date: Date) -> String {
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
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
