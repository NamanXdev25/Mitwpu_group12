//
//  SymptomsViewController.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class SymptomsViewController: UIViewController {
    
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var todayTableView: UITableView!
    @IBOutlet weak var logSymptomButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet var logTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var todayTableViewHeightConstraint: NSLayoutConstraint!
    
    private let dataSource = SymptomDataSource.shared
    private var userSymptoms: [Symptom] = []
    private var selectedSymptoms: [String: Int] = [:]
    private var todayLogs: [SymptomLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViews()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        
        updateLogButtonState()
    }
    
    private func setupTableViews() {
        // Setup Log Table View
        logTableView.delegate = self
        logTableView.dataSource = self
        logTableView.register(UINib(nibName: "SymptomSelectionCell", bundle: nil), forCellReuseIdentifier: "SymptomSelectionCell")
        
        // Setup Today Table View
        todayTableView.delegate = self
        todayTableView.dataSource = self
        todayTableView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellReuseIdentifier: "SymptomLogCell")
    }
    
    private func loadData() {
        userSymptoms = dataSource.getUserSymptoms()
        todayLogs = dataSource.getTodayLogs()
        logTableView.reloadData()
        todayTableView.reloadData()
        updateLogTableViewHeight()
        updateTodayTableViewHeight()
    }
    
    private func updateLogTableViewHeight() {
        var totalHeight: CGFloat = 0
        
        for (_, symptom) in userSymptoms.enumerated() {
            let isSelected = selectedSymptoms[symptom.id] != nil
            let cellHeight: CGFloat = isSelected ? 120 : 60
            totalHeight += cellHeight
        }
        
        logTableViewHeightConstraint.constant = totalHeight
        
    }
    
    private func updateTodayTableViewHeight() {
        var totalHeight: CGFloat = 0
        
        if todayLogs.isEmpty {
            // Show empty state message - just enough height for the message
            totalHeight = 100
        } else {
            // Calculate based on logs
            for _ in todayLogs {
                totalHeight += 80 // height per cell
            }
        }
        
        todayTableViewHeightConstraint.constant = totalHeight
    }
    
    private func updateLogButtonState() {
        if selectedSymptoms.isEmpty {
            logSymptomButton.isEnabled = false
        } else {
            logSymptomButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditList" {
            if let navController = segue.destination as? UINavigationController,
               let editVC = navController.viewControllers.first as? EditSymptomListViewController {
                editVC.onDismiss = { [weak self] in
                    self?.loadData()
                }
            }
        }
    }
    
//    @IBAction func editButtonTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "showEditList", sender: nil)
//    }
    @IBAction func logSymptomButtonTapped(_ sender: UIButton) {
        // Log all selected symptoms
        for (symptomId, severity) in selectedSymptoms {
            if let symptom = userSymptoms.first(where: { $0.id == symptomId }) {
                dataSource.logSymptom(symptomId: symptomId, symptomName: symptom.name, severity: severity)
            }
        }
        
        // Clear selections
        selectedSymptoms.removeAll()
        
        // Reload data
        loadData()
        updateLogButtonState()
    }
    
    private func toggleSymptomSelection(symptomId: String) {
        if selectedSymptoms[symptomId] != nil {
            selectedSymptoms.removeValue(forKey: symptomId)
        } else {
            selectedSymptoms[symptomId] = 0 // Default to mild
        }
        logTableView.reloadData()
        updateLogButtonState()
        updateLogTableViewHeight()
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
}

// MARK: - UITableViewDataSource
extension SymptomsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == logTableView {
            return userSymptoms.count
        } else {
            return todayLogs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == logTableView {
            // Log table - SymptomSelectionCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomSelectionCell", for: indexPath) as! SymptomSelectionCell
            let symptom = userSymptoms[indexPath.row]
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
        } else {
            // Today table - SymptomLogCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomLogCell", for: indexPath) as! SymptomLogCell
            let log = todayLogs[indexPath.row]
            cell.configure(with: log)
            return cell
        }
    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if tableView == logTableView {
//            return "Log"
//        } else {
//            return "Today"
//        }
//    }
}

// MARK: - UITableViewDelegate
extension SymptomsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == logTableView {
            let symptom = userSymptoms[indexPath.row]
            let isSelected = selectedSymptoms[symptom.id] != nil
            return isSelected ? 120 : 60
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == todayTableView && todayLogs.isEmpty {
            let emptyView = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "No symptoms logged yet"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 16)
            
            emptyView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
            ])
            
            return emptyView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == todayTableView && todayLogs.isEmpty {
            return 100
        }
        return 0
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//
//        let titleLabel = UILabel()
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
//        titleLabel.textColor = .label
//
//        if tableView == logTableView {
//            titleLabel.text = "Log"
//
//            let editButton = UIButton(type: .system)
//            editButton.translatesAutoresizingMaskIntoConstraints = false
//            editButton.setTitle("Edit", for: .normal)
//            editButton.setTitleColor(
//                UIColor(named: "SymptomsPrimaryColor"),
//                for: .normal
//            )
//            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
//
//            headerView.addSubview(titleLabel)
//            headerView.addSubview(editButton)
//
//            NSLayoutConstraint.activate([
//                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//
//                editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//                editButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
//            ])
//        } else {
//            titleLabel.text = "Today"
//
//            headerView.addSubview(titleLabel)
//
//            NSLayoutConstraint.activate([
//                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
//            ])
//        }
//
//        return headerView
//    }
}
