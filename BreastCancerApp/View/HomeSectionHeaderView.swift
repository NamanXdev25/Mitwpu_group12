import UIKit

class HomeSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func seeAllTapped(_ sender: UIButton) {
        print("See All Tapped")
    }
}
