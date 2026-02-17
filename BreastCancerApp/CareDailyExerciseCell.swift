//import UIKit
//
//class CareDailyExerciseCell: UICollectionViewCell {
//
//    @IBOutlet weak var ExerciseContainer: UIView!
//    @IBOutlet weak var ExerciseImage: UIImageView!
//    @IBOutlet weak var ExerciseTitle: UILabel!
//    @IBOutlet weak var ExerciseTime: UILabel!
//    @IBOutlet weak var ExerciseBeginButton: UIButton!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // The "Begin" button usually looks like a pill
//        ExerciseBeginButton.layer.cornerRadius = ExerciseBeginButton.frame.height / 2
//    }
//
//    func configure(title: String, duration: String, image: UIImage?) {
//        ExerciseTitle.text = title
//        ExerciseTime.text = duration
//        ExerciseImage.image = image
//    }
//}

import UIKit

// MARK: - Protocol
protocol CareDailyExerciseCellDelegate: AnyObject {
    func careDailyExerciseCellDidTap(_ cell: CareDailyExerciseCell)
}

class CareDailyExerciseCell: UICollectionViewCell {

    @IBOutlet weak var ExerciseContainer: UIView!
    @IBOutlet weak var ExerciseImage: UIImageView!
    @IBOutlet weak var ExerciseTitle: UILabel!
    @IBOutlet weak var ExerciseTime: UILabel!
    @IBOutlet weak var ExerciseBeginButton: UIButton!
    
    weak var delegate: CareDailyExerciseCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        ExerciseBeginButton.layer.cornerRadius = ExerciseBeginButton.frame.height / 2
        
        // ✅ Wire up the Begin button tap
        ExerciseBeginButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    func configure(title: String, duration: String, image: UIImage?) {
        ExerciseTitle.text = title
        ExerciseTime.text = duration
        ExerciseImage.image = image
    }
    
    @objc private func handleTap() {
        delegate?.careDailyExerciseCellDidTap(self)
    }
}
