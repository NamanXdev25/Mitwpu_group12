//
//  BarGraphView.swift
//  BreastCancerApp
//
//  Created by Shloka on 10/02/26.
//
import UIKit

class BarGraphView: UIView {
    
    var dataPoints: [Int] = [] {
        didSet { setNeedsDisplay(); updateDayLabels(); hidePopup() }
    }
    
    private let popupView = GraphPopupView()
    private var barRects: [CGRect] = []
    private var dayLabels: [UILabel] = []
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  
    private var selectedIndex: Int? {
        didSet { setNeedsDisplay() }
    }
    
    private let sideMargin: CGFloat = 20
    private let topMargin: CGFloat = 30
    private let bottomLabelPadding: CGFloat = 30

    private var xibBarColor: UIColor = .systemPink

    override func awakeFromNib() {
        super.awakeFromNib()
     
        self.xibBarColor = self.backgroundColor ?? .systemPink
        
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
            label.text = name
            label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = .systemGray2
            label.textAlignment = .center
            addSubview(label)
            dayLabels.append(label)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let availableWidth = bounds.width - (2 * sideMargin)
        let colWidth = availableWidth / CGFloat(dayNames.count)
        
        for (i, label) in dayLabels.enumerated() {
            let x = sideMargin + CGFloat(i) * colWidth
            label.frame = CGRect(x: x, y: bounds.height - 20, width: colWidth, height: 20)
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        var foundIndex: Int?
        
        let colWidth = (bounds.width - 2 * sideMargin) / CGFloat(dayNames.count)
        for index in 0..<dataPoints.count {
            let columnX = sideMargin + CGFloat(index) * colWidth
            if location.x >= columnX && location.x <= columnX + colWidth {
                foundIndex = index
                break
            }
        }
        
        if let index = foundIndex {
            selectedIndex = index
            showPopup(at: index)
        } else {
            selectedIndex = nil
            hidePopup()
        }
    }

    private func showPopup(at index: Int) {
        guard index < dataPoints.count else { return }
        let value = dataPoints[index]
        let rect = barRects.indices.contains(index) ? barRects[index] : .zero
        
        let dayText = "\(dayNames[index])\n"
        let attributedText = NSMutableAttributedString(string: dayText, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ])
        attributedText.append(NSAttributedString(string: "minutes : \(value)", attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]))
        
        popupView.textLabel.attributedText = attributedText
        let size = popupView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        popupView.frame.size = CGSize(width: size.width + 24, height: size.height + 16)
        
        popupView.center = CGPoint(x: rect.midX, y: rect.origin.y - (popupView.frame.height / 2) - 10)
        
        bringSubviewToFront(popupView)
        UIView.animate(withDuration: 0.2) { self.popupView.alpha = 1 }
    }

    private func hidePopup() {
        UIView.animate(withDuration: 0.2) { self.popupView.alpha = 0 }
    }

    override func draw(_ rect: CGRect) {
        guard !dataPoints.isEmpty else { return }
        
        let availableWidth = rect.width - (2 * sideMargin)
        let colWidth = availableWidth / CGFloat(dayNames.count)
        let usableHeight = rect.height - topMargin - bottomLabelPadding
        let maxValue = CGFloat(max(dataPoints.max() ?? 60, 1))
        
        let selectionHighlight = xibBarColor.withAlphaComponent(0.1)
        
        barRects.removeAll()
        
        for (i, val) in dataPoints.enumerated() {
            let barWidth = colWidth * 0.6
            let barHeight = (CGFloat(val) / maxValue) * usableHeight
            let x = sideMargin + (CGFloat(i) * colWidth) + (colWidth - barWidth) / 2
            let y = (rect.height - bottomLabelPadding) - barHeight
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            barRects.append(barRect)
            
            if i == selectedIndex {
                let highlightRect = CGRect(x: sideMargin + CGFloat(i) * colWidth,
                                           y: 0,
                                           width: colWidth,
                                           height: rect.height - bottomLabelPadding)
                let highlightPath = UIBezierPath(rect: highlightRect)
                selectionHighlight.setFill()
                highlightPath.fill()
            }
            
            // 2. Draw Bar using XIB color with square bottom corners
            let path = UIBezierPath(roundedRect: barRect,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 8, height: 8))
            xibBarColor.setFill()
            path.fill()
        }
    }
}
