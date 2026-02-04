import UIKit

class CareHeaderCell: UICollectionViewCell {

    @IBOutlet weak var Titlelabel: UILabel!
    @IBOutlet weak var Managelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Titlelabel.text = ""
        Managelabel.text = "Manage"
    }

    func configure(title: String, showManage: Bool) {
        Titlelabel.text = title
        Managelabel.isHidden = !showManage
        
    }
}
