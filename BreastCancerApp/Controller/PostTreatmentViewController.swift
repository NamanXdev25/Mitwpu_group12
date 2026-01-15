//
//  PostTreatmentViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class PostTreatmentViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var completionDatePicker: UIDatePicker!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let interests = OnboardingDataSource.postTreatmentInterests
    private var selectedInterests: Set<String> = []
    
    // override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 3, totalSteps: 5, animated: true)
    }
    
    // func def
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButtonState()
        
        // set max date to today
        completionDatePicker.maximumDate = Date()
        completionDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        
        // register XIB cell
        let nib = UINib(nibName: "InterestsCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "InterestsCell")
        
        // set flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        let totalSpacing: CGFloat = 24 + 16 + 24 // left padding + spacing + right padding
        let cellWidth = (UIScreen.main.bounds.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: cellWidth, height: 120)
        
        collectionView.collectionViewLayout = layout
    }
    
    @objc private func datePickerChanged() {
        updateNextButtonState()
    }
    
    private func updateNextButtonState() {
        let hasSelection = !selectedInterests.isEmpty
        let isValid = hasSelection
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }
    
    private func saveData() {
        OnboardingData.shared.treatmentCompletionDate = completionDatePicker.date
        OnboardingData.shared.selectedInterests = Array(selectedInterests)
    }
    
    // action buttons
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped - Post Treatment")
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveData()
        print("Post Treatment data saved:")
        print("- Completion Date: \(completionDatePicker.date)")
        print("- Selected Interests: \(selectedInterests)")
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

// delegate & datasource
extension PostTreatmentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
