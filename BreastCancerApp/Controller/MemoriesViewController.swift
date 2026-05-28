import UIKit

final class MemoriesViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    AddMemoryDelegate,
    MemoryDeleteDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    // MARK: - Outlets

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addButton: UIButton!

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

    @IBAction func filterTapped(_: UIBarButtonItem) {
        if isFiltering {
            clearFilter()
        } else {
            presentFilterSheet()
        }
    }

    private func presentFilterSheet() {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)

        guard let pickerVC = storyboard.instantiateViewController(
            withIdentifier: "MonthYearPickerViewController"
        ) as? MonthYearPickerViewController else {
            fatalError("Expected MonthYearPickerViewController for identifier 'MonthYearPickerViewController'")
        }

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

        guard let popup = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryPopupViewController"
        ) as? AddMemoryPopupViewController else {
            fatalError("Expected AddMemoryPopupViewController for identifier 'AddMemoryPopupViewController'")
        }

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

        guard let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryViewController"
        ) as? AddMemoryViewController else {
            fatalError("Expected AddMemoryViewController for identifier 'AddMemoryViewController'")
        }

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

        CoinRewardService.shared.awardMemoryCoinsIfEligible(on: self)
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

        let grouped = Dictionary(grouping: source) { memory -> String in
            let components = calendar.dateComponents([.month, .year], from: memory.date)
            let year = components.year ?? 2000
            let month = components.month ?? 1
            return "\(year)-\(month)"
        }

        groupedMemories = grouped.compactMap { key, memories in
            let parts = key.split(separator: "-")
            guard parts.count >= 2,
                  let year = Int(parts[0]),
                  let month = Int(parts[1]) else { return nil }
            return (month: month, year: year, items: memories.sorted { $0.date > $1.date })
        }
        .sorted { a, b in
            if a.year != b.year { return a.year > b.year }
            return a.month > b.month
        }
    }

    // MARK: - CollectionView

    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        groupedMemories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MemoryMonthGroupCell.reuseIdentifier,
            for: indexPath
        ) as? MemoryMonthGroupCell else {
            fatalError("Expected MemoryMonthGroupCell for reuse identifier '\(MemoryMonthGroupCell.reuseIdentifier)'")
        }

        let group = groupedMemories[indexPath.item]
        let isLast = indexPath.item == groupedMemories.count - 1

        cell.configure(with: group.items, month: group.month, year: group.year, isLast: isLast)

        cell.onTap = { [weak self] in
            self?.openViewer(groupIndex: indexPath.item)
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 280)
    }

    // MARK: - Viewer

    private func openViewer(groupIndex: Int) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)

        guard let navController = storyboard.instantiateViewController(
            withIdentifier: "MonthMemoriesNavigationController"
        ) as? UINavigationController else {
            fatalError("Expected UINavigationController for identifier 'MonthMemoriesNavigationController'")
        }

        guard let monthVC = navController.viewControllers.first as? MonthMemoriesViewController else {
            fatalError("Expected MonthMemoriesViewController as the root of navigation controller")
        }

        let group = groupedMemories[groupIndex]
        monthVC.memories = group.items
        monthVC.month = group.month
        monthVC.year = group.year

        monthVC.onMemoriesChanged = { [weak self] updatedMemories in
            guard let self else { return }
            self.memories.removeAll { memory in
                let c = self.calendar.dateComponents([.month, .year], from: memory.date)
                return c.month == group.month && c.year == group.year
            }
            self.memories.append(contentsOf: updatedMemories)
            MemoryStore.save(self.memories)
            self.sortAndGroupMemories()
            self.collectionView.reloadData()
        }

        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
        }

        present(navController, animated: true)
    }
}
