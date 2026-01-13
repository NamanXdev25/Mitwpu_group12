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

    // MARK: - UI Setup
    private func configureUI() {
        title = "Memories"
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

        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        collectionView.delaysContentTouches = false
    }

    // MARK: - Add Button
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Open Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })

        sheet.addAction(UIAlertAction(title: "Add from Gallery", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }

        present(sheet, animated: true)
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

    // MARK: - Navigation
    private func openAddMemoryScreen(with image: UIImage) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryViewController"
        ) as! AddMemoryViewController

        addVC.image = image
        addVC.delegate = self

        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }

    // MARK: - AddMemoryDelegate
    func didAddMemory(_ memory: Memory) {
        memories.append(memory)
        MemoryStore.save(memories)
        sortAndGroupMemories()
        collectionView.reloadData()
    }

    // MARK: - MemoryDeleteDelegate
    func didDeleteMemory(at index: Int) {
        memories.remove(at: index)
        MemoryStore.save(memories)
        sortAndGroupMemories()
        collectionView.reloadData()
    }

    // MARK: - Grouping
    private func sortAndGroupMemories() {
        memories.sort { $0.date > $1.date }

        let grouped = Dictionary(grouping: memories) {
            calendar.startOfDay(for: $0.date)
        }

        groupedMemories = grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.0 > $1.0 }
    }

    // MARK: - CollectionView DataSource
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

    // MARK: - Date Formatting
    private func formattedDate(_ date: Date) -> String {
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Open Viewer (STRUCT-SAFE)
    private func openViewer(section: Int, item: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let pageVC = storyboard.instantiateViewController(
            withIdentifier: "MemoryPageViewController"
        ) as! MemoryPageViewController

        let flatMemories = groupedMemories.flatMap { $0.items }
        let startIndex = groupedMemories[..<section]
            .reduce(0) { $0 + $1.items.count } + item

        pageVC.memories = flatMemories
        pageVC.startIndex = startIndex
        pageVC.deleteDelegate = self
        pageVC.modalPresentationStyle = .fullScreen

        present(pageVC, animated: true)
    }
}
