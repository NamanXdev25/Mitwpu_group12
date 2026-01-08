//
//  SymptomsViewController.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class SymptomsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let dataSource = SymptomDataSource.shared
    private var userSymptoms: [Symptom] = []
    private var selectedSymptoms: [String: Int] = [:]
    private var todayLogs: [SymptomLog] = []
    
    private enum Section: Int, CaseIterable {
        case log = 0
        case button = 1
        case today = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        
        // Register cells
        collectionView.register(UINib(nibName: "SymptomSelectionCell", bundle: nil), forCellWithReuseIdentifier: "SymptomSelectionCell")
        collectionView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellWithReuseIdentifier: "SymptomLogCell")
        collectionView.register(
            UINib(nibName: "SymptomHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SymptomHeaderView.reuseIdentifier
        )

        collectionView.register(LogButtonCell.self, forCellWithReuseIdentifier: "LogButtonCell")
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: "EmptyStateCell")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self,
                  let sectionType = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            switch sectionType {
            case .log:
                return self.createLogSection()
            case .button:
                return self.createButtonSection()
            case .today:
                return self.createTodaySection(layoutEnvironment: layoutEnvironment)
            }
        }
        
        return layout
    }
    
    private func createLogSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        section.interGroupSpacing = 8

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
        return section
    }

    
    private func createButtonSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(66)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(66)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        
        return section
    }
    
    private func createTodaySection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // 🔥 Use list configuration for swipe actions
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = .clear
        config.headerMode = .supplementary

        // 🔥 ADD SWIPE-TO-DELETE
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            // Only apply to actual log items, not empty state
            guard !self.todayLogs.isEmpty else { return nil }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                self.confirmDelete(at: indexPath, completion: completion)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = .systemRed
            
            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
            swipeConfig.performsFirstActionWithFullSwipe = true
            
            return swipeConfig
        }
        
        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        // Fix spacing: add proper insets and spacing between items
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 8
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func loadData() {
        userSymptoms = dataSource.getUserSymptoms()
        todayLogs = dataSource.getTodayLogs()
        collectionView.reloadData()
    }
    
    @objc private func logSymptomButtonTapped() {
        guard !selectedSymptoms.isEmpty else { return }

        for (symptomId, severity) in selectedSymptoms {
            if let symptom = userSymptoms.first(where: { $0.id == symptomId }) {
                dataSource.logSymptom(
                    symptomId: symptomId,
                    symptomName: symptom.name,
                    severity: severity
                )
            }
        }

        // Clear selection
        selectedSymptoms.removeAll()

        // Refresh today logs
        todayLogs = dataSource.getTodayLogs()

        // Reload affected sections
        collectionView.reloadSections(
            IndexSet([Section.log.rawValue,
                      Section.button.rawValue,
                      Section.today.rawValue])
        )
    }
    
    private func toggleSymptomSelection(symptomId: String) {
        guard let index = userSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }

        if selectedSymptoms[symptomId] != nil {
            selectedSymptoms.removeValue(forKey: symptomId)
        } else {
            selectedSymptoms[symptomId] = 0
        }

        let logIndexPath = IndexPath(item: index, section: Section.log.rawValue)

        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [logIndexPath])
            collectionView.reloadSections(IndexSet([Section.button.rawValue]))
        }

        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // 🔥 NEW: Delete confirmation
    private func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let log = todayLogs[indexPath.item]
        
        let alert = UIAlertController(
            title: "Delete Log?",
            message: "Are you sure you want to delete this \(log.symptomName) entry?",
            preferredStyle: .alert
        )
        
        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Remove from data source
            self.dataSource.deleteLog(logId: log.id)
            
            // Update local array
            self.todayLogs = self.dataSource.getTodayLogs()
            
            // Animate deletion
            if self.todayLogs.isEmpty {
                // Show empty state
                self.collectionView.reloadSections(IndexSet([Section.today.rawValue]))
            } else {
                // Delete specific item
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            completion(true)
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        
        alert.addAction(deleteBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true)
    }
    
    private func showInfoAlert(for symptom: Symptom) {
        let message: String
        switch symptom.name {
        case "Fatigue":
            message = "Feeling unusually tired is common during treatment. It may not improve with rest, but gentle activity, good nutrition, and enough sleep can help. Talk to your care team if it feels severe or persistent."
        case "Nausea":
            message = "Feeling sick to your stomach can be managed with medication, eating small frequent meals, and avoiding strong smells."
        case "Pain":
            message = "Pain should be reported to your care team. There are many ways to manage it effectively."
        default:
            message = "Track this symptom and discuss with your care team if it persists or worsens."
        }
        
        let alert = UIAlertController(title: symptom.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func openEditList() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let editVC = storyboard.instantiateViewController(
            withIdentifier: "EditSymptomListViewController"
        ) as! EditSymptomListViewController

        editVC.onDismiss = { [weak self] in
            self?.loadData()
        }

        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension SymptomsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .log:
            return userSymptoms.count
        case .button:
            return 1
        case .today:
            return todayLogs.isEmpty ? 1 : todayLogs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType {
        case .log:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomSelectionCell", for: indexPath) as! SymptomSelectionCell
            let symptom = userSymptoms[indexPath.item]
            let isSelected = selectedSymptoms[symptom.id] != nil
            let severity = selectedSymptoms[symptom.id] ?? 0
            
            cell.configure(with: symptom, isSelected: isSelected, severity: severity)
            
            cell.onCheckboxTapped = { [weak self] in
                self?.toggleSymptomSelection(symptomId: symptom.id)
            }
            
            cell.onSliderChanged = { [weak self] severity in
                self?.selectedSymptoms[symptom.id] = severity
            }
            
            cell.onInfoTapped = { [weak self] in
                self?.showInfoAlert(for: symptom)
            }
            
            return cell
            
        case .button:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogButtonCell", for: indexPath) as! LogButtonCell
            cell.configure(isEnabled: !selectedSymptoms.isEmpty)
            cell.onButtonTapped = { [weak self] in
                self?.logSymptomButtonTapped()
            }
            return cell
            
        case .today:
            if todayLogs.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyStateCell", for: indexPath) as! EmptyStateCell
                cell.configure(message: "No symptoms logged yet")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomLogCell", for: indexPath) as! SymptomLogCell
                let log = todayLogs[indexPath.item]
                cell.configure(with: log)
                return cell
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = Section(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SymptomHeaderView.reuseIdentifier,
            for: indexPath
        ) as! SymptomHeaderView

        switch sectionType {

        case .log:
            header.configure(title: "Log", showButton: true)
            header.editTapped = { [weak self] in
                self?.openEditList()
            }

        case .today:
            header.configure(title: "Today", showButton: false)
            header.editTapped = nil

        case .button:
            return UICollectionReusableView()
        }

        return header
    }
}

// MARK: - UICollectionViewDelegate
extension SymptomsViewController: UICollectionViewDelegate {
    // Add any selection handling if needed
}

// MARK: - Custom Cells

class LogButtonCell: UICollectionViewCell {
    
    private let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Log Symptom", for: .normal)
        btn.backgroundColor = UIColor(named: "SymptomsPrimaryColor")
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 25
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return btn
    }()
    
    var onButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func configure(isEnabled: Bool) {
        button.isEnabled = isEnabled
        button.alpha = isEnabled ? 1.0 : 0.5
    }
    
    @objc private func buttonTapped() {
        onButtonTapped?()
    }
}

class EmptyStateCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.textColor = .secondaryLabel
        lbl.font = .systemFont(ofSize: 16)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(message: String) {
        label.text = message
    }
}

class SectionHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    private let editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Edit", for: .normal)
        btn.setTitleColor(UIColor(named: "SymptomsPrimaryColor"), for: .normal)
        return btn
    }()
    
    var onEditTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "SymptomsBackgroundColor")
        
        addSubview(titleLabel)
        addSubview(editButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
    }
    
    func configure(title: String, showEditButton: Bool) {
        titleLabel.text = title
        editButton.isHidden = !showEditButton
    }
    
    @objc private func editTapped() {
        onEditTapped?()
    }
}
