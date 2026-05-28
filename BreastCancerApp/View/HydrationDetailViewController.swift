import UIKit

class HydrationDetailViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var goalLabel: UILabel!

    // MARK: - Properties

    private var entries: [HydrationEntry] = []
    private let dataManager = HydrationDataManager.shared
    private let dailyGoal = 3000

    // MARK: - Lifecycle

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

    // MARK: - Setup

    private func setupUI() {
        title = "Hydration · \(getCurrentDateString())"
        navigationController?.navigationBar.prefersLargeTitles = false

        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTapped))
        closeButton.tintColor = .label
        navigationItem.rightBarButtonItem = closeButton

        goalLabel?.text = "Goal: \(formatML(dailyGoal))"
        goalLabel?.textColor = .systemGray
        goalLabel?.font = .systemFont(ofSize: 15, weight: .regular)
    }

    private func setupTableView() {
        guard let tableView else {
            assertionFailure("tableView outlet is nil — check the IBOutlet connection in the storyboard for HydrationDetailViewController")
            return
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HydrationEntryCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func loadData() {
        let calendar = Calendar.current
        let today = Date()
        entries = dataManager.entries.filter {
            calendar.isDate($0.timestamp, inSameDayAs: today)
        }
        updateProgressUI()
        tableView?.reloadData()
    }

    private func updateProgressUI() {
        let total = entries.reduce(0) { $0 + $1.amountML }
        totalLabel?.text = formatML(total)
        totalLabel?.font = .systemFont(ofSize: 32, weight: .bold)

        let glasses = Double(total) / 250.0
        progressLabel?.text = String(format: "%.0f / %d glasses", glasses, dailyGoal / 250)
        progressLabel?.textColor = .systemGray
        progressLabel?.font = .systemFont(ofSize: 15, weight: .regular)
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @IBAction func addGlassTapped(_: UIButton) {
        showAddEntryAlert()
    }

    @IBAction func saveChangesTapped(_: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods

    private func showAddEntryAlert() {
        let alert = UIAlertController(title: "Add Water", message: "Enter amount in ml", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Amount (ml)"
            textField.keyboardType = .numberPad
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            guard let textField = alert?.textFields?.first,
                  let text = textField.text,
                  let amount = Int(text),
                  amount > 0 else { return }

            let entry = HydrationEntry(amountML: amount)
            self?.dataManager.addEntry(entry)
            self?.loadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func showEditEntryAlert(for entry: HydrationEntry) {
        let alert = UIAlertController(title: "Edit Water", message: "Enter new amount in ml", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Amount (ml)"
            textField.text = "\(entry.amountML)"
            textField.keyboardType = .numberPad
        }

        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self, weak alert] _ in
            guard let textField = alert?.textFields?.first,
                  let text = textField.text,
                  let amount = Int(text),
                  amount > 0 else { return }

            self?.dataManager.updateEntry(withId: entry.id, newAmount: amount)
            self?.loadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(updateAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: Date())
    }

    private func formatML(_ ml: Int) -> String {
        if ml < 1000 {
            return "\(ml) ml"
        } else {
            let liters = Double(ml) / 1000.0
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            let litersString = formatter.string(from: NSNumber(value: liters)) ?? "\(liters)"
            return "\(litersString) L"
        }
    }
}

// MARK: - UITableViewDataSource

extension HydrationDetailViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HydrationEntryCell", for: indexPath)
        let entry = entries[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = formatML(entry.amountML)
        config.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
        config.textProperties.color = .label

        config.secondaryText = entry.dateString
        config.secondaryTextProperties.font = .systemFont(ofSize: 15, weight: .regular)
        config.secondaryTextProperties.color = .systemGray

        cell.contentConfiguration = config
        cell.accessoryType = .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HydrationDetailViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let entry = entries[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.dataManager.deleteEntry(withId: entry.id)
            self?.loadData()
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemPink

        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            self?.showEditEntryAlert(for: entry)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemGray

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
