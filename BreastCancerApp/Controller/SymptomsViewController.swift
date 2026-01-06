//
//  SymptomsViewController.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class SymptomsViewController: UIViewController {
    
    
    @IBOutlet var logTableView: UITableView!
    @IBOutlet var todayTableView: UITableView!
    @IBOutlet weak var logSymptomButton: UIButton!
    
    private let dataSource = SymptomDataSource.shared
    private var userSymptoms: [Symptom] = []
    private var selectedSymptoms: [String: Int] = [:]
    private var todayLogs: [SymptomLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        title = "Symptoms"
        
        
        logSymptomButton.layer.cornerRadius = 25
        logSymptomButton.backgroundColor = .systemGray5
        logSymptomButton.setTitleColor(.systemGray, for: .normal)
        logSymptomButton.isEnabled = false
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        editButton.tintColor = .systemPink
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        tableView.register(UINib(nibName: "SymptomSelectionCell", bundle: nil), forCellReuseIdentifier: "SymptomSelectionCell")
        tableView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellReuseIdentifier: "SymptomLogCell")
    }
    
    private func loadData() {
        userSymptoms = dataSource.getUserSymptoms()
        todayLogs = dataSource.getTodayLogs()
        tableView.reloadData()
    }
    
    private func updateLogButtonState() {
        if selectedSymptoms.isEmpty {
            logSymptomButton.backgroundColor = .systemGray5
            logSymptomButton.setTitleColor(.systemGray, for: .normal)
            logSymptomButton.isEnabled = false
        } else {
            logSymptomButton.backgroundColor = .systemPink
            logSymptomButton.setTitleColor(.white, for: .normal)
            logSymptomButton.isEnabled = true
        }
    }
    
    @objc private func editButtonTapped() {
        performSegue(withIdentifier: "showEditList", sender: nil)
    }
    
    @IBAction func logSymptomButtonTapped(_ sender: UIButton) {
        for (symptomId, severity) in selectedSymptoms {
            if let symptom = userSymptoms.first(where: { $0.id == symptomId }) {
                dataSource.logSymptom(symptomId: symptomId, symptomName: symptom.name, severity: severity)
            }
        }
        
        selectedSymptoms.removeAll()
        
        loadData()
        updateLogButtonState()
    }
}

// MARK: - UITableViewDataSource
extension SymptomsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userSymptoms.count
        } else {
            return todayLogs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
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
            
            cell.onInfoTapped = {
                self.showInfoAlert(for: symptom)
            }
            
            return cell
        } else {
            // Today section - SymptomLogCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomLogCell", for: indexPath) as! SymptomLogCell
            let log = todayLogs[indexPath.row]
            cell.configure(with: log)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Log"
        } else {
            return "Today"
        }
    }
    
    private func toggleSymptomSelection(symptomId: String) {
        if selectedSymptoms[symptomId] != nil {
            selectedSymptoms.removeValue(forKey: symptomId)
        } else {
            selectedSymptoms[symptomId] = 0
        }
        tableView.reloadData()
        updateLogButtonState()
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

// MARK: - UITableViewDelegate
extension SymptomsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let symptom = userSymptoms[indexPath.row]
            let isSelected = selectedSymptoms[symptom.id] != nil
            return isSelected ? 120 : 60
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        
        if section == 0 {
            titleLabel.text = "Log"
        } else {
            titleLabel.text = "Today"
        }
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        if section == 0 {
            let editButton = UIButton(type: .system)
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.setTitle("Edit", for: .normal)
            editButton.setTitleColor(.systemPink, for: .normal)
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            
            headerView.addSubview(editButton)
            
            NSLayoutConstraint.activate([
                editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                editButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
            ])
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
