//
//  CurrentFocusViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class CurrentFocusViewController: UIViewController {

    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    private var selectedFocusIndices = Set<Int>()
    private let focusOptions = OnboardingDataSource.currentFocusOptions
    private let focusCellID  = "InterestsCell"
    private let headerCellID = "OnboardingFocusSectionHeaderCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 4, totalSteps: 5, animated: true)
    }

    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButton()
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: focusCellID,  bundle: nil),
                                forCellWithReuseIdentifier: focusCellID)
        collectionView.register(UINib(nibName: headerCellID, bundle: nil),
                                forCellWithReuseIdentifier: headerCellID)
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = makeLayout()
        collectionView.isScrollEnabled      = false
        collectionView.alwaysBounceVertical = false
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            sectionIndex == 0 ? Self.makeHeaderSection() : Self.makeFocusGridSection()
        }
    }

    private static func makeHeaderSection() -> NSCollectionLayoutSection {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(60))
        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(60))
        let group     = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }

    private static func makeFocusGridSection() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 12
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                               heightDimension: .fractionalWidth(0.4))
        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing / 2,
                                                     bottom: 0, trailing: spacing / 2)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(0.4))
        let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item, item])
        let section   = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets     = NSDirectionalEdgeInsets(top: 8,
                                                            leading: 16 + spacing / 2,
                                                            bottom: 16,
                                                            trailing: 16 + spacing / 2)
        return section
    }

    private func updateNextButton() {
        let isValid      = !selectedFocusIndices.isEmpty
        nextButton.isEnabled = isValid
        nextButton.alpha     = isValid ? 1.0 : 0.5
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        OnboardingData.shared.currentFocus = selectedFocusIndices.map { focusOptions[$0].title }
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

extension CurrentFocusViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 1 : focusOptions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: headerCellID, for: indexPath
            ) as! OnboardingFocusSectionHeaderCell
            cell.configure(title: "What is your focus right now?")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: focusCellID, for: indexPath
            ) as! InterestsCell
            let option     = focusOptions[indexPath.item]
            let isSelected = selectedFocusIndices.contains(indexPath.item)
            cell.configure(with: option.title, icon: option.icon, isSelected: isSelected)
            return cell
        }
    }
}

extension CurrentFocusViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        if selectedFocusIndices.contains(indexPath.item) {
            selectedFocusIndices.remove(indexPath.item)
        } else {
            selectedFocusIndices.insert(indexPath.item)
        }
        collectionView.reloadItems(at: [indexPath])
        updateNextButton()
    }
}
