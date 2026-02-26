//
//  OnboardingMindfulnessViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 27/01/26.
//

import UIKit

class OnboardingMindfulnessViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressBar: UIView!  // Or ProgressBarView if you have that class
    @IBOutlet weak var mindfulnessImage: UIView!
    
    // MARK: - Properties
    private let features = OnboardingFeature.mindfulnessFeatures
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let mask = CAGradientLayer()
        mask.frame = mindfulnessImage.bounds

        mask.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]

        mask.locations = [0.0, 0.45, 0.95]
        mindfulnessImage.layer.mask = mask
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        // Register the XIB
        let nib = UINib(nibName: "OnboardingFeatureCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "OnboardingFeatureCell")
        
        // Set delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Configure layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 237, height: 50)
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    private func setupUI() {
        // Update progress bar if it's a custom ProgressBarView
        if let progressBarView = progressBar as? ProgressBarView {
            progressBarView.setProgress(0.4) // Adjust based on your onboarding flow
        }
        
        // Style next button if needed
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
    }
    
    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // Navigate to next screen
        performSegue(withIdentifier: "showNext", sender: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingMindfulnessViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "OnboardingFeatureCell",
            for: indexPath
        ) as? OnboardingFeatureCell else {
            return UICollectionViewCell()
        }
        
        let feature = features[indexPath.item]
        cell.configure(with: feature)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OnboardingMindfulnessViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Optional: Handle cell selection if needed
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingMindfulnessViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32 // Accounting for padding
        return CGSize(width: width, height: 50)
    }
}
