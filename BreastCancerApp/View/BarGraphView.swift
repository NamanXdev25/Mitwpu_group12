import UIKit

class BarGraphView: UIView {
    var dataPoints: [Int] = [] {
        didSet { setNeedsDisplay(); updateDayLabels(); hidePopup() }
    }
    
    private let popupView = GraphPopupView()
    private var barRects: [CGRect] = []
    private var dayLabels: [UILabel] = []
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private var selectedIndex: Int? { didSet { setNeedsDisplay() } }
    
    private let sideMargin: CGFloat = 20
    private let topMargin: CGFloat = 30
    private let bottomLabelPadding: CGFloat = 30
    private var xibBarColor: UIColor = .systemPink
    private var graphAccentColor: UIColor {
        UIColor(named: "primary_colour")
            ?? UIColor(named: "primary_color")
            ?? UIColor(named: "PrimaryColor")
            ?? .systemPink
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.xibBarColor = graphAccentColor
        self.backgroundColor = .clear
        self.clipsToBounds = false
        setupTouch()
    }
    
    private func setupTouch() {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tap)
        popupView.alpha = 0
        addSubview(popupView)
    }

    private func updateDayLabels() {
        dayLabels.forEach { $0.removeFromSuperview() }
        dayLabels.removeAll()
        for name in dayNames {
            let label = UILabel()
            label.text = name; label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = .systemGray2; label.textAlignment = .center
            addSubview(label); dayLabels.append(label)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let colWidth = (bounds.width - (2 * sideMargin)) / CGFloat(dayNames.count)
        for (i, label) in dayLabels.enumerated() {
            let x = sideMargin + CGFloat(i) * colWidth
            label.frame = CGRect(x: x, y: bounds.height - 20, width: colWidth, height: 20)
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let colWidth = (bounds.width - 2 * sideMargin) / CGFloat(dayNames.count)
        for index in 0..<dataPoints.count {
            let columnX = sideMargin + CGFloat(index) * colWidth
            if location.x >= columnX && location.x <= columnX + colWidth {
                selectedIndex = index; showPopup(at: index); return
            }
        }
        selectedIndex = nil; hidePopup()
    }

    private func showPopup(at index: Int) {
        guard index < dataPoints.count, index < barRects.count else { return }
        let value = dataPoints[index]
        let rect = barRects[index]
        
        let attributedText = NSMutableAttributedString(string: "\(dayNames[index])\n", attributes: [
            .foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ])
        attributedText.append(NSAttributedString(string: "minutes : \(value)", attributes: [
            .foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]))
        
        popupView.textLabel.attributedText = attributedText
        let size = popupView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        popupView.frame.size = CGSize(width: size.width + 24, height: size.height + 16)
        popupView.center = CGPoint(x: rect.midX, y: rect.origin.y - (popupView.frame.height / 2) - 10)
        
        bringSubviewToFront(popupView)
        UIView.animate(withDuration: 0.2) { self.popupView.alpha = 1 }
    }

    private func hidePopup() { UIView.animate(withDuration: 0.2) { self.popupView.alpha = 0 } }

    override func draw(_ rect: CGRect) {
        guard !dataPoints.isEmpty else { return }
        let availableWidth = rect.width - (2 * sideMargin)
        let colWidth = availableWidth / CGFloat(dayNames.count)
        let usableHeight = rect.height - topMargin - bottomLabelPadding
        let maxValue = CGFloat(max(dataPoints.max() ?? 60, 1))
        
        barRects.removeAll()
        for (i, val) in dataPoints.enumerated() {
            let barWidth = colWidth * 0.55
            let barHeight = (CGFloat(val) / maxValue) * usableHeight
            let x = sideMargin + (CGFloat(i) * colWidth) + (colWidth - barWidth) / 2
            let y = (rect.height - bottomLabelPadding) - barHeight
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            barRects.append(barRect)
            
            if i == selectedIndex {
                let highlightRect = CGRect(x: sideMargin + CGFloat(i) * colWidth, y: topMargin - 10, width: colWidth, height: rect.height - bottomLabelPadding - topMargin + 10)
                xibBarColor.withAlphaComponent(0.08).setFill()
                UIRectFill(highlightRect)
            }
            
            let path = UIBezierPath(roundedRect: barRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 4.0, height: 4.0))
            xibBarColor.setFill(); path.fill()
        }
    }
}
