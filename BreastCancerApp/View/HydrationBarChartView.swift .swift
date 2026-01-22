import UIKit

final class HydrationBarChartView: UIView {

    enum Mode {
        case weekly
        case monthly
    }

    private var values: [Double] = []
    private var xLabels: [String] = []
    private var mode: Mode = .weekly

    private var maxY: Double {
        max(4.0, (values.max() ?? 0).rounded(.up))
    }

    private var step: Double {
        switch maxY {
        case 0...4:
            return 0.5
        case 4...8:
            return 1.0
        default:
            return 2.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isOpaque = false
    }

    func configure(values: [Double], labels: [String], mode: Mode) {
        self.values = values
        self.xLabels = labels
        self.mode = mode
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !values.isEmpty else { return }

        let leftPadding: CGFloat = 36
        let bottomPadding: CGFloat = 28
        let topPadding: CGFloat = 12
        let chartHeight = rect.height - topPadding - bottomPadding

        drawYAxis(ctx, rect, leftPadding, chartHeight)
        drawXAxis(rect, leftPadding)
        drawBars(ctx, rect, leftPadding, chartHeight)
    }

    private func drawYAxis(_ ctx: CGContext, _ rect: CGRect, _ left: CGFloat, _ height: CGFloat) {
        for value in stride(from: 0.0, through: maxY, by: step) {
            let y = yPosition(for: value, height)

            String(format: "%.1f", value).draw(
                at: CGPoint(x: 4, y: y - 7),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
            )

            ctx.setStrokeColor(UIColor.lightGray.cgColor)
            ctx.setLineWidth(0.5)
            ctx.move(to: CGPoint(x: left, y: y))
            ctx.addLine(to: CGPoint(x: rect.width - 8, y: y))
            ctx.strokePath()
        }
    }

    private func drawXAxis(_ rect: CGRect, _ left: CGFloat) {
        let count = xLabels.count
        guard count > 0 else { return }

        let rightPadding: CGFloat = 12
        let usableWidth = rect.width - left - rightPadding
        let slotWidth = usableWidth / CGFloat(count)

        for (index, label) in xLabels.enumerated() {
            if mode == .monthly, index % 5 != 0 { continue }

            let xCenter = left + CGFloat(index) * slotWidth + slotWidth / 2
            let size = label.size(withAttributes: [.font: UIFont.systemFont(ofSize: 10)])

            label.draw(
                at: CGPoint(x: xCenter - size.width / 2, y: rect.height - 20),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
            )
        }
    }

    private func drawBars(_ ctx: CGContext, _ rect: CGRect, _ left: CGFloat, _ height: CGFloat) {
        let count = values.count
        guard count > 0 else { return }

        let rightPadding: CGFloat = 12
        let usableWidth = rect.width - left - rightPadding
        let slotWidth = usableWidth / CGFloat(count)
        let barWidth = slotWidth * 0.6

        let barColor = UIColor(named: "bg") ?? .systemPink

        for (index, value) in values.enumerated() {
            let barHeight = CGFloat(value / maxY) * height
            let x = left + CGFloat(index) * slotWidth + (slotWidth - barWidth) / 2
            let y = rect.height - 28 - barHeight

            ctx.setFillColor(barColor.cgColor)
            ctx.fill(CGRect(x: x, y: y, width: barWidth, height: barHeight))
        }
    }

    private func yPosition(for value: Double, _ height: CGFloat) -> CGFloat {
        bounds.height - 28 - CGFloat(value / maxY) * height
    }
}
