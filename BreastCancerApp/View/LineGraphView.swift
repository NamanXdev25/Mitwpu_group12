import UIKit

class LineGraphView: UIView {
    
    enum GraphType { case hydration, symptoms }
    var graphType: GraphType = .hydration
    var dataPoints: [Int] = [] {
        didSet {
            setNeedsDisplay()
            updateDayLabels()
            hidePopup()
            selectedIndex = nil
        }
    }
    
    var valueFormatter: ((Int) -> String)?
    var popupTextProvider: ((Int) -> NSAttributedString?)?
    var popupTextAlignment: NSTextAlignment = .center
    var onDataPointSelected: ((Int) -> Void)?

    private let popupView = GraphPopupView()
    private let selectionLine = CAShapeLayer()
    private var pointLocations: [CGPoint] = []
    private var dayLabels: [UILabel] = []
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let lineLayer = CAShapeLayer()
    private var dotLayers: [CAShapeLayer] = []
    private var selectedIndex: Int?
    private var graphAccentColor: UIColor {
        UIColor(named: "primary_colour")
            ?? UIColor(named: "primary_color")
            ?? UIColor(named: "PrimaryColor")
            ?? .systemPink
    }
    
    // MARK: - Layout Constants
    private let sideMargin: CGFloat = 30
    private let topMargin: CGFloat = 15    // Tightened top margin
    private let bottomLabelPadding: CGFloat = 35 // Optimized space for labels

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.clipsToBounds = false
        
        lineLayer.strokeColor = graphAccentColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        lineLayer.lineCap = .round
        self.layer.addSublayer(lineLayer)
        
        selectionLine.strokeColor = UIColor.systemGray4.cgColor
        selectionLine.lineWidth = 1
        selectionLine.lineDashPattern = [4, 4]
        selectionLine.opacity = 0
        self.layer.addSublayer(selectionLine)
        
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
            label.text = name
            label.font = .systemFont(ofSize: 10, weight: .medium)
            label.textColor = .systemGray2
            label.textAlignment = .center
            addSubview(label)
            dayLabels.append(label)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let colWidth = (bounds.width - (2 * sideMargin)) / CGFloat(dayNames.count - 1)
        for (i, label) in dayLabels.enumerated() {
            let x = sideMargin + CGFloat(i) * colWidth
            // Positions labels at the very bottom edge of the view
            label.frame = CGRect(x: x - 20, y: bounds.height - 18, width: 40, height: 15)
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        var closestIndex: Int?
        var minDistance: CGFloat = 40
        for (index, point) in pointLocations.enumerated() {
            let distance = abs(location.x - point.x)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        if let index = closestIndex {
            selectPoint(at: index, notifySelection: true)
        } else {
            selectPoint(at: nil, notifySelection: false)
        }
    }

    func selectPoint(at index: Int?, notifySelection: Bool = false) {
        selectedIndex = index

        guard let index,
              index >= 0,
              index < dataPoints.count else {
            hidePopup()
            return
        }

        if pointLocations.indices.contains(index) {
            showPopup(at: index)
        } else {
            setNeedsDisplay()
            DispatchQueue.main.async { [weak self] in
                self?.showPopup(at: index)
            }
        }

        if notifySelection {
            onDataPointSelected?(index)
        }
    }

    private func showPopup(at index: Int) {
        guard index < dataPoints.count else { return }
        let value = dataPoints[index]
        let point = pointLocations[index]
        let displayValue = valueFormatter?(value) ?? "\(value)"
        let attributedText = popupTextProvider?(index) ?? defaultPopupText(for: index, displayValue: displayValue)

        popupView.textLabel.textAlignment = popupTextAlignment
        popupView.textLabel.attributedText = attributedText
        let size = popupView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        popupView.frame.size = CGSize(width: size.width + 24, height: size.height + 16)
        
        var targetX = point.x
        if targetX - (popupView.frame.width/2) < 0 { targetX = (popupView.frame.width/2) + 5 }
        if targetX + (popupView.frame.width/2) > bounds.width { targetX = bounds.width - (popupView.frame.width/2) - 5 }

        var targetY = point.y - (popupView.frame.height / 2) - 15
        let minY = (popupView.frame.height / 2) + 4
        let maxY = bounds.height - (popupView.frame.height / 2) - 4
        if targetY < minY {
            targetY = min(point.y + (popupView.frame.height / 2) + 15, maxY)
        } else {
            targetY = min(targetY, maxY)
        }

        popupView.center = CGPoint(x: targetX, y: targetY)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: point.x, y: 0))
        linePath.addLine(to: CGPoint(x: point.x, y: bounds.height - bottomLabelPadding))
        selectionLine.path = linePath.cgPath
        
        bringSubviewToFront(popupView)
        UIView.animate(withDuration: 0.2) {
            self.popupView.alpha = 1
            self.selectionLine.opacity = 1
        }
    }

    private func hidePopup() {
        UIView.animate(withDuration: 0.2) {
            self.popupView.alpha = 0
            self.selectionLine.opacity = 0
        }
    }

    private func defaultPopupText(for index: Int, displayValue: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(dayNames[index])\n", attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ])
        attributedText.append(NSAttributedString(string: displayValue, attributes: [
            .foregroundColor: graphAccentColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]))
        return attributedText
    }

    override func draw(_ rect: CGRect) {
        guard dataPoints.count > 1 else { return }
        
        let maxValue = CGFloat(max(dataPoints.max() ?? 0, 1))
        let colWidth = (rect.width - (2 * sideMargin)) / CGFloat(dataPoints.count - 1)
        let usableHeight = rect.height - topMargin - bottomLabelPadding

        let path = UIBezierPath()
        pointLocations.removeAll()
        dotLayers.forEach { $0.removeFromSuperlayer() }
        dotLayers.removeAll()

        for (i, val) in dataPoints.enumerated() {
            let x = sideMargin + CGFloat(i) * colWidth
            // Maps the points to use the full height of the Graph View
            let y = (rect.height - bottomLabelPadding) - (CGFloat(val) / maxValue * usableHeight)
            let pt = CGPoint(x: x, y: y)
            pointLocations.append(pt)
            
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            
            let dot = CAShapeLayer()
            dot.path = UIBezierPath(arcCenter: pt, radius: 4, startAngle: 0, endAngle: .pi*2, clockwise: true).cgPath
            dot.fillColor = graphAccentColor.cgColor
            self.layer.addSublayer(dot)
            dotLayers.append(dot)
        }
        lineLayer.strokeColor = graphAccentColor.cgColor
        lineLayer.path = path.cgPath
    }
}

class GraphPopupView: UIView {
    let textLabel = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
        
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}
