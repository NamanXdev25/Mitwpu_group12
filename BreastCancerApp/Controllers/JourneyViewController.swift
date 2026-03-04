import UIKit

class JourneyViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    private var diagnosisModel = DiagnosisModel()
    private var waitModel = WaitModel()
    private var treatmentModel = TreatmentModel()

    private var cellHeights: [Int: CGFloat] = [
        0: 280,  // DiagnosisCell — title + separator + date label + textfield + save button
        1: 510,  // WaitCell
        2: 150,  // TreatmentCell
        3: 445   // PostTreatmentCell
    ]
    
    private var selectedPostTreatmentDate: Date?

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
        collectionView.register(UINib(nibName: "DiagnosisCell", bundle: nil), forCellWithReuseIdentifier: "DiagnosisCell")
        collectionView.register(UINib(nibName: "WaitCell", bundle: nil), forCellWithReuseIdentifier: "WaitCell")
        collectionView.register(UINib(nibName: "TreatmentCell", bundle: nil), forCellWithReuseIdentifier: "TreatmentCell")
        collectionView.register(UINib(nibName: "PostTreatmentCell", bundle: nil), forCellWithReuseIdentifier: "PostTreatmentCell")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }

    // MARK: - Height Update
    private func updateHeight(for index: Int, height: CGFloat) {
        guard cellHeights[index] != height else { return }
        cellHeights[index] = height
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates(nil)
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
////////////////////////////////////////////////////////////

extension JourneyViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.item {

        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DiagnosisCell",
                for: indexPath) as? DiagnosisCell else { return UICollectionViewCell() }

            cell.configure(with: diagnosisModel)

            cell.onDateSelected = { [weak self] date in
                self?.diagnosisModel.diagnosisDate = date
            }

            cell.onSaveButtonTapped = { [weak self] in
                self?.diagnosisModel.status = "Completed"
            }

            cell.onCellHeightChanged = { [weak self] in
                guard let self = self else { return }
                self.updateHeight(for: 0, height: cell.getCellHeight())
            }

            return cell

        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "WaitCell",
                for: indexPath) as? WaitCell else { return UICollectionViewCell() }

            cell.configure(with: waitModel)

            cell.onSaveButtonTapped = { [weak self] in
                self?.waitModel.status = "Completed"
            }

            cell.onCellHeightChanged = { [weak self] in
                guard let self = self else { return }
                self.updateHeight(for: 1, height: cell.getCellHeight())
            }

            return cell

        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TreatmentCell",
                for: indexPath) as? TreatmentCell else { return UICollectionViewCell() }

            cell.configure(with: treatmentModel)

            cell.onSaveButtonTapped = { [weak self] phase, index in
                self?.treatmentModel.phases.append(phase)
            }

            cell.onCellHeightChanged = { [weak self] in
                guard let self = self else { return }
                self.updateHeight(for: 2, height: cell.getCellHeight())
            }

            return cell

        default:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PostTreatmentCell",
                for: indexPath) as? PostTreatmentCell else { return UICollectionViewCell() }

            cell.configure()

            cell.onDateTapped = { [weak self] in
                self?.presentPostTreatmentCalendar()
            }

            cell.onCellHeightChanged = { [weak self] in
                guard let self = self else { return }
                self.updateHeight(for: 3, height: cell.getCellHeight())
            }

            return cell
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - Calendar Presentation
////////////////////////////////////////////////////////////

extension JourneyViewController {
    
    private func presentPostTreatmentCalendar() {
        
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimView.tag = 999
        dimView.alpha = 0
        view.addSubview(dimView)
        
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        dimView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 340),
            container.heightAnchor.constraint(equalToConstant: 420)
        ])
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(datePicker)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            doneButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            doneButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        UIView.animate(withDuration: 0.25) {
            dimView.alpha = 1
        }
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        doneButton.addAction(UIAction { [weak self] _ in
            self?.dismissCalendarPopup()
        }, for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCalendarPopup))
        tap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(tap)
    }

    @objc private func dateChanged(_ picker: UIDatePicker) {
        selectedPostTreatmentDate = picker.date
    }

    @objc private func dismissCalendarPopup() {
        
        guard let dimView = view.viewWithTag(999) else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            dimView.alpha = 0
        }) { _ in
            dimView.removeFromSuperview()
        }
        
        if let date = selectedPostTreatmentDate {
            let indexPath = IndexPath(item: 3, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? PostTreatmentCell {
                cell.updateSelectedDate(date)
            }
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDelegateFlowLayout
////////////////////////////////////////////////////////////

extension JourneyViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalWidth = view.bounds.width
        let padding: CGFloat = 32
        let cellWidth = totalWidth - padding
        let height = cellHeights[indexPath.item] ?? 200
        
        return CGSize(width: cellWidth, height: height)
    }
}
