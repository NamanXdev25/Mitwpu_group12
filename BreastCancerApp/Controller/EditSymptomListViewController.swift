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
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadData()
        tableView.isEditing = true
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
        dismiss(animated: true) {
            self.onDismiss?()
        }
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.onDismiss?()
        }
    }
    
    private func showInfoAlert(for symptom: Symptom) {
        let message = dataSource.getDescription(for: symptom.name)
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
        return section == 0 ? "Your List" : "Add"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        guard sourceIndexPath.section == 0,
              destinationIndexPath.section == 0 else {
            tableView.reloadData()
            return
        }

        let movedSymptom = userSymptoms.remove(at: sourceIndexPath.row)
        userSymptoms.insert(movedSymptom, at: destinationIndexPath.row)
//
//        // 🔥 Persist new order
//        dataSource.updateUserSymptomsOrder(userSymptoms)
        
        dataSource.updateUserSymptomsOrderInMemory(userSymptoms)
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        header.textLabel?.textColor = .secondaryLabel
    }
}
