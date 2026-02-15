////
////  EditSymptomListViewController.swift
////  symptomTracking
////
////  Created by Shivani Dinesh on 04/01/26.
////
//
//import UIKit
//
//class EditSymptomListViewController: UIViewController {
//    
//    // IBOutlets
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var doneButton: UIBarButtonItem!
//    @IBOutlet weak var BackButton: UIBarButtonItem!
//    
//    // variable definitions
//    private let dataSource = SymptomDataSource.shared
//    
//    // Temporary local copies - work with these instead of modifying dataSource directly
//    private var tempUserSymptoms: [Symptom] = []
//    private var tempAvailableSymptoms: [Symptom] = []
//    
//    var onDismiss: (() -> Void)?
//    
//    // override funcs
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTableView()
//        loadData()
//        tableView.isEditing = true
//    }
//    
//    // func definitions
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: "EditSymptomCell", bundle: nil), forCellReuseIdentifier: "EditSymptomCell")
//    }
//    
//    private func loadData() {
//        // Load into temporary arrays - don't modify dataSource yet
//        tempUserSymptoms = dataSource.getUserSymptoms()
//        tempAvailableSymptoms = dataSource.getAvailableSymptoms()
//        tableView.reloadData()
//    }
//    
//    private func showInfoAlert(for symptom: Symptom) {
//        let message = dataSource.getDescription(for: symptom.name)
//        let alert = UIAlertController(title: symptom.name, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    // IBActions
//    @IBAction func closeButtonTapped(_ sender: Any) {
//        // Discard all changes - just dismiss without saving
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func doneButtonTapped(_ sender: Any) {
//        // Save all changes to dataSource
//        saveChanges()
//        
//        dismiss(animated: true) {
//            self.onDismiss?()
//        }
//    }
//    
//    private func saveChanges() {
//        // Get original user symptoms
//        let originalUserSymptoms = dataSource.getUserSymptoms()
//        let originalIds = Set(originalUserSymptoms.map { $0.id })
//        let newIds = Set(tempUserSymptoms.map { $0.id })
//        
//        // Find symptoms that were removed
//        let removedIds = originalIds.subtracting(newIds)
//        for id in removedIds {
//            dataSource.removeSymptomFromUserList(symptomId: id)
//        }
//        
//        // Find symptoms that were added
//        let addedIds = newIds.subtracting(originalIds)
//        for id in addedIds {
//            dataSource.addSymptomToUserList(symptomId: id)
//        }
//        
//        // Update the order for all user symptoms
//        dataSource.updateUserSymptomsOrderInMemory(tempUserSymptoms)
//    }
//}
//
//// UITableViewDataSource - tableview setup
//extension EditSymptomListViewController: UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return tempUserSymptoms.count
//        } else {
//            return tempAvailableSymptoms.count
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "EditSymptomCell", for: indexPath) as! EditSymptomCell
//        
//        if indexPath.section == 0 { // your list section
//            
//            let symptom = tempUserSymptoms[indexPath.row]
//            cell.configure(with: symptom, isInUserList: true)
//            cell.onActionTapped = { [weak self] in
//                self?.removeSymptomFromTemp(symptomId: symptom.id)
//            }
//            cell.onInfoTapped = { [weak self] in
//                self?.showInfoAlert(for: symptom)
//            }
//            
//        } else { // add section
//            
//            let symptom = tempAvailableSymptoms[indexPath.row]
//            cell.configure(with: symptom, isInUserList: false)
//            cell.onActionTapped = { [weak self] in
//                self?.addSymptomToTemp(symptomId: symptom.id)
//            }
//            cell.onInfoTapped = { [weak self] in
//                self?.showInfoAlert(for: symptom)
//            }
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return section == 0 ? "Your List" : "Add"
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 36
//    }
//    
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return indexPath.section == 0
//    }
//    
//    func tableView(
//        _ tableView: UITableView,
//        moveRowAt sourceIndexPath: IndexPath,
//        to destinationIndexPath: IndexPath
//    ) {
//        guard sourceIndexPath.section == 0,
//              destinationIndexPath.section == 0
//        else {
//            tableView.reloadData()
//            return
//        }
//        
//        // Reorder in temporary array only
//        let movedSymptom = tempUserSymptoms.remove(at: sourceIndexPath.row)
//        tempUserSymptoms.insert(movedSymptom, at: destinationIndexPath.row)
//    }
//    
//    func tableView(
//        _ tableView: UITableView,
//        editingStyleForRowAt indexPath: IndexPath
//    ) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//    
//    // Work with temporary arrays instead of dataSource
//    private func removeSymptomFromTemp(symptomId: String) {
//        guard let index = tempUserSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
//        let symptom = tempUserSymptoms.remove(at: index)
//        tempAvailableSymptoms.append(symptom)
//        tempAvailableSymptoms.sort { $0.name < $1.name }
//        tableView.reloadData()
//    }
//    
//    private func addSymptomToTemp(symptomId: String) {
//        guard let index = tempAvailableSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
//        let symptom = tempAvailableSymptoms.remove(at: index)
//        tempUserSymptoms.append(symptom)
//        tableView.reloadData()
//    }
//}
//
//// UITableViewDelegate
//extension EditSymptomListViewController: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//}


//
//  EditSymptomListViewController.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class EditSymptomListViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var BackButton: UIBarButtonItem!
    
    // variable definitions
    private let dataSource = SymptomDataSource.shared
    
    // Temporary local copies - work with these instead of modifying dataSource directly
    private var tempUserSymptoms: [Symptom] = []
    private var tempAvailableSymptoms: [Symptom] = []
    
    var onDismiss: (() -> Void)?
    
    // override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadData()
        tableView.isEditing = true
    }
    
    // func definitions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EditSymptomCell", bundle: nil), forCellReuseIdentifier: "EditSymptomCell")
    }
    
    private func loadData() {
        // Load into temporary arrays - don't modify dataSource yet
        tempUserSymptoms = dataSource.getUserSymptoms()
        tempAvailableSymptoms = dataSource.getAvailableSymptoms()
        tableView.reloadData()
    }
    
    private func showInfoAlert(for symptom: Symptom) {
        let message = dataSource.getDescription(for: symptom.name)
        let alert = UIAlertController(title: symptom.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        // Discard all changes - pop back to SymptomsViewController
        navigationController?.popViewController(animated: true)
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        // Save all changes to dataSource
        saveChanges()
        
        // Pop back to SymptomsViewController
        navigationController?.popViewController(animated: true)
        onDismiss?()
    }
    
    private func saveChanges() {
        // Get original user symptoms
        let originalUserSymptoms = dataSource.getUserSymptoms()
        let originalIds = Set(originalUserSymptoms.map { $0.id })
        let newIds = Set(tempUserSymptoms.map { $0.id })
        
        // Find symptoms that were removed
        let removedIds = originalIds.subtracting(newIds)
        for id in removedIds {
            dataSource.removeSymptomFromUserList(symptomId: id)
        }
        
        // Find symptoms that were added
        let addedIds = newIds.subtracting(originalIds)
        for id in addedIds {
            dataSource.addSymptomToUserList(symptomId: id)
        }
        
        // Update the order for all user symptoms
        dataSource.updateUserSymptomsOrderInMemory(tempUserSymptoms)
    }
}

// UITableViewDataSource - tableview setup
extension EditSymptomListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tempUserSymptoms.count
        } else {
            return tempAvailableSymptoms.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditSymptomCell", for: indexPath) as! EditSymptomCell
        
        if indexPath.section == 0 { // your list section
            
            let symptom = tempUserSymptoms[indexPath.row]
            cell.configure(with: symptom, isInUserList: true)
            cell.onActionTapped = { [weak self] in
                self?.removeSymptomFromTemp(symptomId: symptom.id)
            }
            cell.onInfoTapped = { [weak self] in
                self?.showInfoAlert(for: symptom)
            }
            
        } else { // add section
            
            let symptom = tempAvailableSymptoms[indexPath.row]
            cell.configure(with: symptom, isInUserList: false)
            cell.onActionTapped = { [weak self] in
                self?.addSymptomToTemp(symptomId: symptom.id)
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
              destinationIndexPath.section == 0
        else {
            tableView.reloadData()
            return
        }
        
        // Reorder in temporary array only
        let movedSymptom = tempUserSymptoms.remove(at: sourceIndexPath.row)
        tempUserSymptoms.insert(movedSymptom, at: destinationIndexPath.row)
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // Work with temporary arrays instead of dataSource
    private func removeSymptomFromTemp(symptomId: String) {
        guard let index = tempUserSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        let symptom = tempUserSymptoms.remove(at: index)
        tempAvailableSymptoms.append(symptom)
        tempAvailableSymptoms.sort { $0.name < $1.name }
        tableView.reloadData()
    }
    
    private func addSymptomToTemp(symptomId: String) {
        guard let index = tempAvailableSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        let symptom = tempAvailableSymptoms.remove(at: index)
        tempUserSymptoms.append(symptom)
        tableView.reloadData()
    }
}

// UITableViewDelegate
extension EditSymptomListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
