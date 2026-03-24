import UIKit

@IBDesignable
class CircularProgressView: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    @IBInspectable var progressColor: UIColor = UIColor(named: "TabBarcolour") ?? UIColor.systemPink {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
    @IBInspectable var trackColor: UIColor = UIColor(named: "logsbgcolor") ?? UIColor.systemGray6 {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    @IBInspectable var lineWidth: CGFloat = 7 {
        didSet {
            progressLayer.lineWidth = lineWidth
            trackLayer.lineWidth = lineWidth
            updatePaths()
        }
    }
    
    @IBInspectable var progress: CGFloat = 0.6 {
        didSet {
            let clampedProgress = max(0, min(progress, 1))
            progressLayer.lineCap = clampedProgress >= 1 ? .round : .butt
            progressLayer.strokeEnd = clampedProgress
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
    }
    
    private func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .butt
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
        
        trackLayer.strokeColor = trackColor.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        trackLayer.lineWidth = lineWidth
        progressLayer.lineWidth = lineWidth
    }
    
    private func updatePaths() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2 * 0.800
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
}
