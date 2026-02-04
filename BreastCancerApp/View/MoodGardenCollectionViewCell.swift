import UIKit

class MoodGardenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var viewHistoryButton: UIButton!
    @IBOutlet weak var moodCalendarView: UIView! // The 'Calendar' View in your XIB

    /// Dynamically draws the 31 flowers based on JSON data
    func setupGarden(with moodColors: [String]?) {
        // Clear any old views to prevent stacking on scroll
        moodCalendarView.subviews.forEach { $0.removeFromSuperview() }
        
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.distribution = .fillEqually
        gridStack.spacing = 10
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        moodCalendarView.addSubview(gridStack)
        
        // UIKit Constraints to pin the grid
        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: moodCalendarView.topAnchor),
            gridStack.leadingAnchor.constraint(equalTo: moodCalendarView.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: moodCalendarView.trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: moodCalendarView.bottomAnchor)
        ])
        
        var currentDay = 0
        for _ in 0..<5 { // Rows
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            
            for _ in 0..<7 { // Columns (Sun-Sat)
                let container = UIView()
                if currentDay < 31 {
                    let flower = UIImageView(image: UIImage(systemName: "staroflife.fill"))
                    flower.contentMode = .scaleAspectFit
                    flower.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Map color from JSON
                    if let moods = moodColors, currentDay < moods.count {
                        flower.tintColor = getMoodColor(for: moods[currentDay])
                    } else {
                        flower.tintColor = .systemGray6
                    }
                    
                    container.addSubview(flower)
                    NSLayoutConstraint.activate([
                        flower.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                        flower.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                        flower.widthAnchor.constraint(equalToConstant: 22),
                        flower.heightAnchor.constraint(equalToConstant: 22)
                    ])
                    currentDay += 1
                }
                row.addArrangedSubview(container)
            }
            gridStack.addArrangedSubview(row)
        }
    }
    
    private func getMoodColor(for mood: String) -> UIColor {
        switch mood.lowercased() {
        case "peach": return UIColor(red: 1.0, green: 0.8, blue: 0.7, alpha: 1.0)
        case "yellow": return .systemYellow
        case "lightpink": return UIColor(red: 1.0, green: 0.75, blue: 0.85, alpha: 1.0)
        case "darkpink": return UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0)
        case "lightblue": return .systemCyan
        default: return .systemGray5
        }
    }
}
