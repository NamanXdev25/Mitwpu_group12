import UIKit

class CircularTimerView: UIView {

    // UI Layers
    private var trackLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var timerLabel = UILabel()
    
    // Settings
    private let radius: CGFloat = 125
    private let lineWidth: CGFloat = 6
    
    // Custom Pink Color (Safe Unwrap)
    private let pinkColor = UIColor(named: "primary_color") ?? UIColor.systemPink
    
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
        
        // 1. Define Path
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: radius,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 2 * CGFloat.pi,
                                        clockwise: true)
        
        // 2. Track Layer (Background Ring & Fill)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        trackLayer.lineWidth = lineWidth
        // Dark transparent background for readability
        trackLayer.fillColor = UIColor.black.withAlphaComponent(0.4).cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // 3. Progress Layer (Pink Filling Ring)
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = pinkColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0 // Starts Empty
        layer.addSublayer(progressLayer)
        
        // 4. Label Setup
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.numberOfLines = 3 // Allow more lines for the end message
        timerLabel.text = ""
        
        addSubview(timerLabel)
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            timerLabel.widthAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    // MARK: - Public Helper Functions
    
    func showMessage(_ text: String) {
        timerLabel.isHidden = false
        timerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        timerLabel.text = text
    }
    
    func showTime(_ secondsRemaining: Int) {
        timerLabel.isHidden = false
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // NEW: Function to hide/show the text (used when pausing)
    func setTimerTextHidden(_ hidden: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.timerLabel.alpha = hidden ? 0 : 1
        }
    }
    
    func updateProgress(secondsRemaining: Int, totalDuration: Int) {
        // Update Text
        showTime(secondsRemaining)
        
        // Update Ring (Fill UP from 0 to 1)
        if totalDuration > 0 {
            let timeElapsed = CGFloat(totalDuration - secondsRemaining)
            let percentage = timeElapsed / CGFloat(totalDuration)
            progressLayer.strokeEnd = percentage
        }
    }
    
    func setFullProgress() {
        progressLayer.strokeEnd = 1.0 // Force full circle
    }
    
    func reset() {
        timerLabel.text = ""
        timerLabel.alpha = 1 // Ensure visible
        progressLayer.strokeEnd = 0.0
    }
}
