//
//  AddMedicationViewController.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class AddMedicationViewController: UIViewController,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegate,
                                   UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            UINib(nibName: "HeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "HeaderCell"
        )
        
        collectionView.register(
            UINib(nibName: "DetailsHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "DetailsHeaderCell"
        )
        
        collectionView.register(
            UINib(nibName: "NameRowCell", bundle: nil),
            forCellWithReuseIdentifier: "NameRowCell"
        )

    }
    
    // MARK: - Sections
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3  // Section 0 = Header, Section 1 = Details header , Section 2 = NameRow
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1   // each section has only 1 cell for now
    }
    
    // MARK: - Cells
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            // SECTION 0 = HEADER
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HeaderCell",
                for: indexPath
            ) as! HeaderCell
            return cell
        }
        
        // SECTION 1 = DETAILS HEADER
        if indexPath.section == 1 {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DetailsHeaderCell",
                for: indexPath
            ) as! DetailsHeaderCell
            
            cell.titleLabel.text = "Details"
            return cell
        }
    
        
        // Section 2 → Name cell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NameRowCell",
            for: indexPath
        ) as! NameRowCell
        return cell
        
    }
    
    // MARK: - Sizes
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.width, height: 120)
        }
        if indexPath.section == 1 {
            return CGSize(width: collectionView.frame.width, height: 60)
        }
        
        
        return CGSize(width: collectionView.frame.width, height: 60)
        
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}
