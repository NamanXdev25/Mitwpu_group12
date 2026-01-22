import UIKit

final class MemoryHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "MemoryHeaderView"

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
