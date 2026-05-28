import UIKit

final class MonthMemoriesViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private var collectionView: UICollectionView!

    // MARK: - Data

    var memories: [Memory] = []
    var month: Int = 1
    var year: Int = 2024

    var onMemoriesChanged: (([Memory]) -> Void)?

    private let calendar = Calendar.current

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
}

// MARK: - Configuration

private extension MonthMemoriesViewController {
    func configureNavigationBar() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        if let date = calendar.date(from: components) {
            title = formatter.string(from: date)
        }

        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.leftBarButtonItem = closeButton
    }

    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collectionView.setCollectionViewLayout(layout, animated: false)

        collectionView.register(
            UINib(nibName: "MonthMemoryCell", bundle: nil),
            forCellWithReuseIdentifier: "MonthMemoryCell"
        )
    }
}

// MARK: - Actions

private extension MonthMemoriesViewController {
    @objc func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Collection View

extension MonthMemoriesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        memories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MonthMemoryCell",
            for: indexPath
        ) as? MonthMemoryCell else {
            fatalError("Expected MonthMemoryCell for reuse identifier 'MonthMemoryCell' at \(indexPath)")
        }

        let memory = memories[indexPath.item]

        let width = collectionView.bounds.width - 32
        cell.contentView.widthAnchor.constraint(equalToConstant: width).isActive = true

        cell.configure(with: memory)

        cell.onDelete = { [weak self] in
            self?.deleteMemory(at: indexPath.item)
        }

        cell.onEdit = { [weak self] in
            self?.openEditScreen(for: indexPath.item)
        }

        return cell
    }
}

// MARK: - Edit & Delete

private extension MonthMemoriesViewController {
    func deleteMemory(at index: Int) {
        memories.remove(at: index)
        collectionView.reloadData()
        onMemoriesChanged?(memories)
    }

    func openEditScreen(for index: Int) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryViewController"
        ) as? AddMemoryViewController else {
            fatalError("Expected AddMemoryViewController for storyboard identifier 'AddMemoryViewController'")
        }

        addVC.memoryToEdit = memories[index]
        addVC.editIndex = index
        addVC.editDelegate = self

        present(UINavigationController(rootViewController: addVC), animated: true)
    }
}

// MARK: - EditMemoryDelegate

extension MonthMemoriesViewController: EditMemoryDelegate {
    func didEditMemory(_ memory: Memory, at index: Int) {
        memories[index] = memory
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        onMemoriesChanged?(memories)
    }
}
