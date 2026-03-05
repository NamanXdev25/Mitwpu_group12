//
//  NewAppointmentReminderTimeCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/03/26.
//

import UIKit

class NewAppointmentReminderTimeCell: UICollectionViewCell {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addReminderButton: UIButton!

    var onAdd: (() -> Void)?
    var onDelete: ((Int) -> Void)?

    var reminderOffsets: [ReminderOffset] = [] {
        didSet {
            tableView.reloadData()
            tableHeightConstraint.constant = CGFloat(reminderOffsets.count) * 44
            tableView.isHidden = reminderOffsets.isEmpty
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = 44
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RRow")
        tableView.isHidden = true
    }

    @IBAction func addReminderTapped(_ sender: UIButton) {
        onAdd?()
    }
}

extension NewAppointmentReminderTimeCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        reminderOffsets.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RRow", for: indexPath)
        cell.textLabel?.text = reminderOffsets[indexPath.row].rawValue
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.selectionStyle = .none
        cell.backgroundColor = .white

        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .systemRed
        btn.tag = indexPath.row
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
        cell.accessoryView = btn
        return cell
    }

    @objc private func deleteTapped(_ btn: UIButton) {
        onDelete?(btn.tag)
    }
}
