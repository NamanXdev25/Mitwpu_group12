import UIKit

class CircularTimerView: UIView {

    // UI Layers
    private var trackLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var timerLabel = UILabel()
    
    // Settings
    // Increased radius to 125 for that "Big" look you wanted
    private let radius: CGFloat = 125
    private let lineWidth: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
            self.backgroundColor = .clear
            
            // 1. Define the Path
            let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                            radius: radius,
                                            startAngle: -CGFloat.pi / 2,
                                            endAngle: 2 * CGFloat.pi,
                                            clockwise: true)
            
            // 2. Setup Track Layer (The Background Circle)
            trackLayer.path = circularPath.cgPath
            
            // CHANGE A: Add a "Glassy" Fill Color (Matches your reference image!)
            trackLayer.fillColor = UIColor.white.withAlphaComponent(0.2).cgColor
            
            // CHANGE B: Make the border thinner/fainter
            trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
            trackLayer.lineWidth = lineWidth
            layer.addSublayer(trackLayer)
            
            // 3. Setup Progress Layer (The Moving Ring)
            progressLayer.path = circularPath.cgPath
            progressLayer.strokeColor = UIColor.white.cgColor
            progressLayer.lineWidth = lineWidth
            progressLayer.fillColor = UIColor.clear.cgColor // Keep foreground clear
            progressLayer.lineCap = .round
            progressLayer.strokeEnd = 1.0
            layer.addSublayer(progressLayer)
            
            // 4. Setup Label
            timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .medium)
            timerLabel.textColor = .white
            timerLabel.textAlignment = .center
            timerLabel.text = "00:00"
            
            addSubview(timerLabel)
            
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: radius + 40)
            ])
        }
    
    // We need to update the path when the view layout changes (e.g. screen rotation)
    override func layoutSubviews() {
        super.layoutSubviews()
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(arcCenter: centerPoint,
                                        radius: radius,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 2 * CGFloat.pi,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    // MARK: - Public Functions (The Controller calls these!)
    
    func updateProgress(secondsRemaining: Int, totalDuration: Int) {
        // 1. Update Text
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        // 2. Update Ring
        if totalDuration > 0 {
            let percentage = CGFloat(secondsRemaining) / CGFloat(totalDuration)
            progressLayer.strokeEnd = percentage
        } else {
            progressLayer.strokeEnd = 1.0
        }
    }
    
    func reset() {
        progressLayer.strokeEnd = 1.0
        timerLabel.text = "00:00"
    }
}
