//
//  EditSymptomListViewController.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class EditSymptomListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let dataSource = SymptomDataSource.shared
    private var userSymptoms: [Symptom] = []
    private var availableSymptoms: [Symptom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EditSymptomCell", bundle: nil), forCellReuseIdentifier: "EditSymptomCell")
    }
    
    private func loadData() {
        userSymptoms = dataSource.getUserSymptoms()
        availableSymptoms = dataSource.getAvailableSymptoms()
        tableView.reloadData()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true)
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
        case "Headache":
            message = "Headaches can have many causes. Stay hydrated and track their frequency and intensity."
        case "Dizziness":
            message = "Dizziness should be reported to your care team, especially if it affects your balance or daily activities."
        case "Fever":
            message = "Fever can be a sign of infection. Contact your care team if your temperature is above 100.4°F (38°C)."
        case "Cough":
            message = "A persistent cough should be monitored and reported to your care team."
        default:
            message = "Track this symptom and discuss with your care team if it persists or worsens."
        }
        
        let alert = UIAlertController(title: symptom.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension EditSymptomListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userSymptoms.count
        } else {
            return availableSymptoms.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditSymptomCell", for: indexPath) as! EditSymptomCell
        
        if indexPath.section == 0 {
            
            let symptom = userSymptoms[indexPath.row]
            cell.configure(with: symptom, isInUserList: true)
            
            cell.onActionTapped = { [weak self] in
                self?.removeSymptom(symptomId: symptom.id)
            }
            
            cell.onInfoTapped = { [weak self] in
                self?.showInfoAlert(for: symptom)
            }
        } else {
            
            let symptom = availableSymptoms[indexPath.row]
            cell.configure(with: symptom, isInUserList: false)
            
            cell.onActionTapped = { [weak self] in
                self?.addSymptom(symptomId: symptom.id)
            }
            
            cell.onInfoTapped = { [weak self] in
                self?.showInfoAlert(for: symptom)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Your List"
        } else {
            return "Add"
        }
    }
    
    private func removeSymptom(symptomId: String) {
        dataSource.removeSymptomFromUserList(symptomId: symptomId)
        loadData()
    }
    
    private func addSymptom(symptomId: String) {
        dataSource.addSymptomToUserList(symptomId: symptomId)
        loadData()
    }
}

// MARK: - UITableViewDelegate
extension EditSymptomListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
