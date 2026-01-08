import UIKit

class CircularProgressView: UIView {
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    var lineWidth: CGFloat = 10 {
        didSet { setNeedsLayout() }
    }
    
    var trackColor: UIColor = UIColor(white: 0.92, alpha: 1.0) {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    var progressColor: UIColor = UIColor.systemPink {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            progress = min(max(progress, 0), 1)
            updateProgress()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - Setup
    private func setupLayers() {
        backgroundColor = .clear
        
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (2 * CGFloat.pi)
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        trackLayer.path = circularPath.cgPath
        trackLayer.lineWidth = lineWidth
        
        progressLayer.path = circularPath.cgPath
        progressLayer.lineWidth = lineWidth
        
        updateProgress()
    }
    
    // MARK: - Progress Update
    private func updateProgress() {
        progressLayer.strokeEnd = progress
    }
    
    // MARK: - Animation
    func setProgress(_ value: CGFloat, animated: Bool) {
        let clampedValue = min(max(value, 0), 1)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedValue
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progress = clampedValue
    }
}
