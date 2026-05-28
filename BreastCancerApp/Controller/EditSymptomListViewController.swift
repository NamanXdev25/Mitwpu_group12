import UIKit

class EditSymptomListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var BackButton: UIBarButtonItem!

    private let dataSource = SymptomDataSource.shared

    private var tempUserSymptoms: [Symptom] = []
    private var tempAvailableSymptoms: [Symptom] = []

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

    @IBAction func backButtonTapped(_: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func doneButtonTapped(_: Any) {
        saveChanges()

        navigationController?.popViewController(animated: true)
        onDismiss?()
    }

    private func saveChanges() {
        let originalUserSymptoms = dataSource.getUserSymptoms()
        let originalIds = Set(originalUserSymptoms.map { $0.id })
        let newIds = Set(tempUserSymptoms.map { $0.id })

        let removedIds = originalIds.subtracting(newIds)
        for id in removedIds {
            dataSource.removeSymptomFromUserList(symptomId: id)
        }

        let addedIds = newIds.subtracting(originalIds)
        for id in addedIds {
            dataSource.addSymptomToUserList(symptomId: id)
        }

        dataSource.updateUserSymptomsOrderInMemory(tempUserSymptoms)
    }
}

extension EditSymptomListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tempUserSymptoms.count
        } else {
            return tempAvailableSymptoms.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditSymptomCell", for: indexPath) as? EditSymptomCell else {
            fatalError("Expected EditSymptomCell for reuse identifier 'EditSymptomCell'")
        }

        if indexPath.section == 0 {
            let symptom = tempUserSymptoms[indexPath.row]
            cell.configure(with: symptom, isInUserList: true)
            cell.onActionTapped = { [weak self] in
                self?.removeSymptomFromTemp(symptomId: symptom.id)
            }
            cell.onInfoTapped = { [weak self] in
                self?.showInfoAlert(for: symptom)
            }

        } else {
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

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Your List" : "Add"
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 36
    }

    func tableView(_: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
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

        let movedSymptom = tempUserSymptoms.remove(at: sourceIndexPath.row)
        tempUserSymptoms.insert(movedSymptom, at: destinationIndexPath.row)
    }

    func tableView(
        _: UITableView,
        editingStyleForRowAt _: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }

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

extension EditSymptomListViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
