import UIKit

final class MemoryViewerViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        imageView.image = image
    }
}
