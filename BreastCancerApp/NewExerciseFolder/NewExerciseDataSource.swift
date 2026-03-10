//
//  NewExerciseDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/02/26.
//

import UIKit

enum NewExerciseSectionType: Int, CaseIterable {
    case header = 0
    case note = 1
    case exercises = 2
}

class NewExerciseDataSource: NSObject {
    
    var exercisePlan: NewExercisePlan
    weak var delegate: DetailExerciseCellDelegate?
    
    init(exercisePlan: NewExercisePlan) {
        self.exercisePlan = exercisePlan
        super.init()
    }
    
    private func hasNote() -> Bool {
        return exercisePlan.note != nil
    }
}

// MARK: - UICollectionViewDataSource
extension NewExerciseDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 // header, note (optional), exercises
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = NewExerciseSectionType(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .header:
            return 0 // Using supplementary view
        case .note:
            return hasNote() ? 1 : 0
        case .exercises:
            return exercisePlan.exercises.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = NewExerciseSectionType(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType {
        case .header:
            return UICollectionViewCell() // Not used
            
        case .note:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "NewExerciseNoteCell",
                for: indexPath
            ) as? NewExerciseNoteCell else {
                return UICollectionViewCell()
            }
            
            if let note = exercisePlan.note {
                cell.configure(with: note)
            }
            return cell
            
        case .exercises:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DetailExerciseCell",
                for: indexPath
            ) as? DetailExerciseCell else {
                return UICollectionViewCell()
            }
            
            let exercise = exercisePlan.exercises[indexPath.item]

            // Ask the VC whether this exercise has been completed
            let isCompleted = (delegate as? NewExerciseViewController)?
                .isExerciseCompleted(at: indexPath.item) ?? false

            cell.configure(
                title: exercise.title,
                subtitle: "\(exercise.category) • \(exercise.difficulty)",
                time: exercise.duration,
                imageName: exercise.imageName,
                completed: isCompleted
            )
            cell.delegate = delegate
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 0 {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "NewExerciseHeaderCell",
                for: indexPath
            ) as? NewExerciseHeaderCell else {
                return UICollectionReusableView()
            }
            
            headerView.configure(with: exercisePlan)
            return headerView
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewExerciseDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 150)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        
        guard let sectionType = NewExerciseSectionType(rawValue: indexPath.section) else {
            return .zero
        }
        
        switch sectionType {
        case .header:
            return .zero
        case .note:
            // Dynamic height based on note text
            let noteText = exercisePlan.note ?? ""
            let padding: CGFloat = 32 + 24 // horizontal + vertical padding
            let maxWidth = width - 32 - 32 // cell margins + container margins
            
            let font = UIFont.systemFont(ofSize: 14)
            let boundingRect = noteText.boundingRect(
                with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font],
                context: nil
            )
            
            let height = ceil(boundingRect.height) + padding
            return CGSize(width: width, height: max(height, 60))
            
        case .exercises:
            return CGSize(width: width - 32, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == NewExerciseSectionType.exercises.rawValue ? 12 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let sectionType = NewExerciseSectionType(rawValue: section) else {
            return .zero
        }
        
        switch sectionType {
        case .header:
            return .zero
        case .note:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .exercises:
            return UIEdgeInsets(top: 16, left: 16, bottom: 100, right: 16) // Bottom padding for fixed buttons
        }
    }
}
