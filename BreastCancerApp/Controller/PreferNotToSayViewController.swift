//
//  PreferNotToSayViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class PreferNotToSayViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Properties
    private let interests = OnboardingDataSource.preferNotToSayInterests
    private var selectedInterests: Set<String> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 3, totalSteps: 4, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButtonState()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        
        // Register XIB cell
        let nib = UINib(nibName: "InterestsCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "InterestsCell")
        
        // Setup flow layout - 2 columns
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        // Calculate cell size for 2 columns
        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        let width = (collectionView.bounds.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: width, height: 140)
        
        collectionView.collectionViewLayout = layout
    }
    
    private func updateNextButtonState() {
        // User can proceed without selecting interests
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
    }
    
    private func saveData() {
        OnboardingData.shared.selectedInterests = Array(selectedInterests)
    }
    
    // MARK: - Actions
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped - Prefer not to say")
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveData()
        print("Interests selected: \(selectedInterests)")
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PreferNotToSayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCell", for: indexPath) as! InterestsCell
        
        let interest = interests[indexPath.item]
        let isSelected = selectedInterests.contains(interest.title)
        cell.configure(with: interest.title, icon: interest.icon, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let interest = interests[indexPath.item]
        
        if selectedInterests.contains(interest.title) {
            selectedInterests.remove(interest.title)
        } else {
            selectedInterests.insert(interest.title)
        }
        
        collectionView.reloadItems(at: [indexPath])
        updateNextButtonState()
    }
}
