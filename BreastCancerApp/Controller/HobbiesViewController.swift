//
//  HobbiesViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class HobbiesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    private let hobbies = OnboardingDataSource.hobbies
    private var selectedHobbies: Set<String> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 4, totalSteps: 4, animated: true)
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
        let nib = UINib(nibName: "HobbyCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "HobbyCell")
        
        // Setup flow layout with left alignment
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView.collectionViewLayout = layout
    }
    
    private func updateNextButtonState() {
        let isValid = !selectedHobbies.isEmpty
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }
    
    private func saveData() {
        OnboardingData.shared.selectedHobbies = Array(selectedHobbies)
    }
    
    // MARK: - Actions
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped - Hobbies")
        // Navigate to next screen or home
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveData()
        print("Hobbies saved: \(selectedHobbies)")
        performSegue(withIdentifier: "showCompletion", sender: nil)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HobbiesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hobbies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyCell", for: indexPath) as! HobbyCell
        
        let hobby = hobbies[indexPath.item]
        cell.configure(with: hobby, isSelected: selectedHobbies.contains(hobby))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hobby = hobbies[indexPath.item]
        
        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else {
            selectedHobbies.insert(hobby)
        }
        
        collectionView.reloadItems(at: [indexPath])
        updateNextButtonState()
    }
}
