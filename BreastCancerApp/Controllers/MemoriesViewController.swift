import UIKit

final class MemoriesViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    AddMemoryDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!

    // MARK: - Data
    private var memories: [Memory] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        view.backgroundColor = .systemBackground
    }

    private func configureAddButton() {
        addButton.configuration = nil
        addButton.backgroundColor = .systemPink
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "MemoryImageCell", bundle: nil),
            forCellWithReuseIdentifier: MemoryImageCell.reuseIdentifier
        )
    }

    // MARK: - Add Button
    @IBAction func addButtonTapped(_ sender: UIButton) {

        let sheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        sheet.addAction(
            UIAlertAction(title: "Open Camera", style: .default) { _ in
                self.presentImagePicker(sourceType: .camera)
            }
        )

        sheet.addAction(
            UIAlertAction(title: "Add from Gallery", style: .default) { _ in
                self.presentImagePicker(sourceType: .photoLibrary)
            }
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad safety
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
        picker.allowsEditing = false

        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
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

        guard let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryViewController"
        ) as? AddMemoryViewController else {
            fatalError("AddMemoryViewController not found in storyboard")
        }

        addVC.image = image
        addVC.delegate = self

        let navVC = UINavigationController(rootViewController: addVC)
        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: true)
    }

    // MARK: - AddMemoryDelegate
    func didAddMemory(_ memory: Memory) {
        memories.insert(memory, at: 0)
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        memories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MemoryImageCell.reuseIdentifier,
            for: indexPath
        ) as! MemoryImageCell

        cell.configure(with: memories[indexPath.item].image)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let itemsPerRow: CGFloat = 4
        let spacing: CGFloat = 8
        let totalSpacing = (itemsPerRow - 1) * spacing + 24
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow

        return CGSize(width: width, height: width)
    }
}
