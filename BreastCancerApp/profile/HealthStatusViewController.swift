//
//  HealthStatusViewController.swift
//  BreastCancerApp
//

import UIKit

// MARK: - Card decoration view
final class CardBackgroundView: UICollectionReusableView {
    static let kind = "CardBackgroundView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor     = .white
        layer.cornerRadius  = 18
        layer.masksToBounds = false
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset  = CGSize(width: 0, height: 2)
        layer.shadowRadius  = 10
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Card flow layout
final class CardFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        register(CardBackgroundView.self, forDecorationViewOfKind: CardBackgroundView.kind)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(CardBackgroundView.self, forDecorationViewOfKind: CardBackgroundView.kind)
    }

    override func layoutAttributesForElements(
        in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        guard var all = super.layoutAttributesForElements(in: rect) else { return nil }

        let section1 = all.filter {
            $0.representedElementCategory == .cell && $0.indexPath.section == 1
        }
        guard let first = section1.first, let last = section1.last else { return all }

        let cv              = collectionView!
        let margin: CGFloat = 20

        let deco = UICollectionViewLayoutAttributes(
            forDecorationViewOfKind: CardBackgroundView.kind,
            with: IndexPath(item: 0, section: 1))
        deco.frame  = CGRect(x: margin,
                             y: first.frame.minY,
                             width: cv.bounds.width - margin * 2,
                             height: last.frame.maxY - first.frame.minY)
        deco.zIndex = -1
        all.append(deco)
        return all
    }
}

// MARK: - HealthStatusViewController
class HealthStatusViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var profile      = UserProfileStore.shared.profile  // HealthProfileModel
    var isEditingProfile     = false

    private let firstNameIP  = IndexPath(item: 0, section: 1)
    private let lastNameIP   = IndexPath(item: 1, section: 1)

    private var brandPink: UIColor {
        UIColor(named: "primary_pink") ?? UIColor(red: 215/255, green: 112/255, blue: 145/255, alpha: 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        profile = UserProfileStore.shared.profile   // always load fresh
        isEditingProfile = false
        title = "Health Status"
        setupCollectionView()
        registerCells()
        updateNavButton()
    }
}

// MARK: - Setup
extension HealthStatusViewController {

    private func setupCollectionView() {
        let bg = UIColor(named: "BackgroundColor")
               ?? UIColor(red: 252/255, green: 245/255, blue: 248/255, alpha: 1)
        view.backgroundColor           = bg
        collectionView.backgroundColor = .clear

        let layout                          = CardFlowLayout()
        layout.minimumLineSpacing           = 0
        layout.minimumInteritemSpacing      = 0
        collectionView.collectionViewLayout = layout
        collectionView.dataSource           = self
        collectionView.delegate             = self
        collectionView.contentInset         = UIEdgeInsets(top: 16, left: 0, bottom: 40, right: 0)
    }

    private func updateNavButton() {
        let bar        = navigationController?.navigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "BackgroundColor")
            ?? UIColor(red: 252/255, green: 245/255, blue: 248/255, alpha: 1)
        appearance.shadowColor     = .clear

        let btnAppearance = UIBarButtonItemAppearance(style: .plain)
        btnAppearance.normal.backgroundImage      = UIImage()
        btnAppearance.highlighted.backgroundImage = UIImage()
        appearance.buttonAppearance               = btnAppearance
        appearance.doneButtonAppearance           = btnAppearance

        bar?.standardAppearance   = appearance
        bar?.scrollEdgeAppearance = appearance
        bar?.compactAppearance    = appearance
        bar?.isTranslucent        = false

        if isEditingProfile {
            let size: CGFloat       = 36
            let wrapper             = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            wrapper.backgroundColor = .clear

            let btn                = UIButton(type: .custom)
            btn.frame              = CGRect(x: 0, y: 0, width: size, height: size)
            btn.backgroundColor    = brandPink
            btn.layer.cornerRadius = size / 2
            btn.clipsToBounds      = true
            let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            btn.setImage(UIImage(systemName: "checkmark", withConfiguration: cfg), for: .normal)
            btn.tintColor = .white
            btn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
            wrapper.addSubview(btn)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: wrapper)

        } else {
            let btn                 = UIButton(type: .custom)
            btn.setTitle("Edit", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
            btn.titleLabel?.font    = .systemFont(ofSize: 15, weight: .semibold)
            btn.backgroundColor     = brandPink
            btn.layer.cornerRadius  = 18
            btn.contentEdgeInsets   = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
            btn.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
            btn.sizeToFit()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        }
    }

    private func registerCells() {
        collectionView.register(UINib(nibName: "UserProfileHeaderCell", bundle: nil),
                                forCellWithReuseIdentifier: "UserProfileHeaderCell")
        ["HealthFieldCell", "HealthDateCell", "HealthDropdownCell"].forEach {
            collectionView.register(UINib(nibName: $0, bundle: nil),
                                    forCellWithReuseIdentifier: $0)
        }
    }
}

// MARK: - Edit / Save
extension HealthStatusViewController {

    @objc private func editTapped() {
        isEditingProfile = true
        updateNavButton()
        collectionView.reloadData()
    }

    @objc private func saveTapped() {
        if let c = collectionView.cellForItem(at: firstNameIP) as? HealthFieldCell {
            profile.firstName = c.valueTextField.text ?? profile.firstName
        }
        if let c = collectionView.cellForItem(at: lastNameIP) as? HealthFieldCell {
            profile.lastName = c.valueTextField.text ?? profile.lastName
        }
        UserProfileStore.shared.save(profile)
        isEditingProfile = false
        updateNavButton()
        collectionView.reloadData()
    }
}

// MARK: - DataSource
extension HealthStatusViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 1 : 6
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "UserProfileHeaderCell",
                for: indexPath) as! UserProfileHeaderCell
            cell.configure(name: "\(profile.firstName) \(profile.lastName)",
                           image: profile.profileImage)
            cell.onImageTap = { [weak self] in
                guard let self, self.isEditingProfile else { return }
                self.showImagePicker()
            }
            return cell
        }

        switch indexPath.item {

        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HealthFieldCell", for: indexPath) as! HealthFieldCell
            cell.configure(title: "First Name", value: profile.firstName,
                           isEditing: isEditingProfile)
            cell.delegate           = self
            cell.valueTextField.tag = 1
            addSeparator(to: cell)
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HealthFieldCell", for: indexPath) as! HealthFieldCell
            cell.configure(title: "Last Name", value: profile.lastName,
                           isEditing: isEditingProfile)
            cell.delegate           = self
            cell.valueTextField.tag = 2
            addSeparator(to: cell)
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HealthDateCell", for: indexPath) as! HealthDateCell
            cell.configure(title: "Date of diagnosis", date: profile.diagnosisDate,
                           isEditing: isEditingProfile)
            addSeparator(to: cell)
            cell.onDateChanged = { [weak self] d in self?.profile.diagnosisDate = d }
            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HealthDropdownCell", for: indexPath) as! HealthDropdownCell
            cell.configure(title: "Gender", value: profile.gender.rawValue,
                           isEditing: isEditingProfile)
            addSeparator(to: cell)
            cell.onDropdownTap = { [weak self] in
                guard let self, self.isEditingProfile else { return }
                self.showOptionsPopup(
                    title: "Gender",
                    options: Gender.allCases.map { $0.rawValue },
                    selected: self.profile.gender.rawValue,
                    sourceCell: cell
                ) { [weak self] chosen in
                    if let g = Gender.allCases.first(where: { $0.rawValue == chosen }) {
                        self?.profile.gender = g
                        self?.collectionView.reloadData()
                    }
                }
            }
            return cell

        case 4:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HealthDateCell", for: indexPath) as! HealthDateCell
            cell.configure(title: "Date of Birth", date: profile.dateOfBirth,
                           isEditing: isEditingProfile)
            addSeparator(to: cell)
            cell.onDateChanged = { [weak self] d in self?.profile.dateOfBirth = d }
            return cell

        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HealthDropdownCell", for: indexPath) as! HealthDropdownCell
            cell.configure(title: "Treatment Phase", value: profile.treatmentPhase.rawValue,
                           isEditing: isEditingProfile)
            cell.layer.sublayers?.filter { $0.name == "sep" }.forEach { $0.removeFromSuperlayer() }
            cell.onDropdownTap = { [weak self] in
                guard let self, self.isEditingProfile else { return }
                self.showOptionsPopup(
                    title: "Treatment Phase",
                    options: TreatmentPhase.allCases.map { $0.rawValue },
                    selected: self.profile.treatmentPhase.rawValue,
                    sourceCell: cell
                ) { [weak self] chosen in
                    if let p = TreatmentPhase.allCases.first(where: { $0.rawValue == chosen }) {
                        self?.profile.treatmentPhase = p
                        self?.collectionView.reloadData()
                    }
                }
            }
            return cell
        }
    }

    private func addSeparator(to cell: UICollectionViewCell) {
        cell.layer.sublayers?.filter { $0.name == "sep" }.forEach { $0.removeFromSuperlayer() }
        cell.layoutIfNeeded()
        let line             = CALayer()
        line.name            = "sep"
        line.backgroundColor = UIColor.separator.cgColor
        line.frame           = CGRect(x: 16, y: cell.bounds.height - 0.5,
                                      width: cell.bounds.width - 32, height: 0.5)
        cell.layer.addSublayer(line)
    }
}

// MARK: - HealthFieldCell Delegate
extension HealthStatusViewController: HealthFieldCellDelegate {

    func healthFieldCell(_ cell: HealthFieldCell, didChangeText text: String) {
        switch cell.valueTextField.tag {
        case 1: profile.firstName = text
        case 2: profile.lastName  = text
        default: break
        }
        if let h = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
            as? UserProfileHeaderCell {
            h.configure(name: "\(profile.firstName) \(profile.lastName)",
                        image: profile.profileImage)
        }
    }
}

// MARK: - Layout
extension HealthStatusViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullW = collectionView.bounds.width
        let cardW = fullW - 40
        return CGSize(width: indexPath.section == 0 ? fullW : cardW,
                      height: indexPath.section == 0 ? 190 : 58)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        section == 0 ? .zero : UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
}

// MARK: - Options Popup
extension HealthStatusViewController {

    func showOptionsPopup(title: String, options: [String], selected: String,
                          sourceCell: UICollectionViewCell,
                          onSelect: @escaping (String) -> Void) {
        let vc = OptionsPopupViewController(
            title: title, options: options, selected: selected, brandPink: brandPink
        ) { [weak self] choice in
            onSelect(choice)
            self?.dismiss(animated: true)
        }
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize   = CGSize(width: 260, height: 44 + options.count * 48)
        if let pop = vc.popoverPresentationController {
            pop.sourceView               = sourceCell.contentView
            pop.sourceRect               = sourceCell.contentView.bounds
            pop.permittedArrowDirections = [.up, .down]
            pop.delegate                 = self
        }
        present(vc, animated: true)
    }
}

// MARK: - Popover Delegate
extension HealthStatusViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { .none }
}

// MARK: - Image Picker
extension HealthStatusViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func showImagePicker() {
        let alert = UIAlertController(title: "Change Profile Photo", message: nil,
                                      preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.presentPicker(source: .camera) })
        }
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentPicker(source: .photoLibrary) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func presentPicker(source: UIImagePickerController.SourceType) {
        let p = UIImagePickerController()
        p.sourceType    = source
        p.delegate      = self
        p.allowsEditing = true
        present(p, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        profile.profileImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Options Popup VC
final class OptionsPopupViewController: UIViewController,
                                        UITableViewDataSource, UITableViewDelegate {

    private let optionTitle: String
    private let options:     [String]
    private let selected:    String
    private let brandPink:   UIColor
    private let onSelect:    (String) -> Void
    private var tableView:   UITableView!

    init(title: String, options: [String], selected: String,
         brandPink: UIColor, onSelect: @escaping (String) -> Void) {
        self.optionTitle = title; self.options = options; self.selected = selected
        self.brandPink = brandPink; self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor    = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds      = true

        let hdr           = UILabel()
        hdr.text          = optionTitle
        hdr.font          = .systemFont(ofSize: 13, weight: .semibold)
        hdr.textColor     = .secondaryLabel
        hdr.textAlignment = .center
        hdr.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hdr)

        let sep             = UIView()
        sep.backgroundColor = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sep)

        tableView                 = UITableView(frame: .zero, style: .plain)
        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.isScrollEnabled = false
        tableView.separatorInset  = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "opt")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            hdr.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            hdr.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hdr.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hdr.heightAnchor.constraint(equalToConstant: 24),
            sep.topAnchor.constraint(equalTo: hdr.bottomAnchor, constant: 8),
            sep.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),
            tableView.topAnchor.constraint(equalTo: sep.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ t: UITableView, numberOfRowsInSection s: Int) -> Int { options.count }

    func tableView(_ t: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell   = t.dequeueReusableCell(withIdentifier: "opt", for: ip)
        let option = options[ip.row]
        let isSel  = option == selected
        cell.textLabel?.text      = option
        cell.textLabel?.font      = .systemFont(ofSize: 16, weight: isSel ? .medium : .regular)
        cell.textLabel?.textColor = isSel ? brandPink : .label
        cell.accessoryType        = isSel ? .checkmark : .none
        cell.tintColor            = brandPink
        return cell
    }

    func tableView(_ t: UITableView, heightForRowAt ip: IndexPath) -> CGFloat { 48 }

    func tableView(_ t: UITableView, didSelectRowAt ip: IndexPath) {
        t.deselectRow(at: ip, animated: true)
        onSelect(options[ip.row])
    }
}
