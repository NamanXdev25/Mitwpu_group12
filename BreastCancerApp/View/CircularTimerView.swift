import UIKit

class CircularTimerView: UIView {

    // Properties
    private let glassContainer = UIView()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let timerLabel = UILabel()
    private let staticBorderView = UIView()
    
    private var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    private let pinkColor = UIColor(red: 232/255, green: 106/255, blue: 146/255, alpha: 1.0)
    
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
        
        glassContainer.clipsToBounds = true
        glassContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glassContainer)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        glassContainer.addSubview(blurEffectView)
        
        staticBorderView.backgroundColor = .clear
        staticBorderView.layer.borderWidth = 2.0
        staticBorderView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        staticBorderView.translatesAutoresizingMaskIntoConstraints = false
        glassContainer.addSubview(staticBorderView)
        
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.numberOfLines = 0
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timerLabel)
        
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            glassContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            glassContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            glassContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            glassContainer.heightAnchor.constraint(equalTo: glassContainer.widthAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: glassContainer.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: glassContainer.bottomAnchor),
            
            staticBorderView.topAnchor.constraint(equalTo: glassContainer.topAnchor),
            staticBorderView.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor),
            staticBorderView.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor),
            staticBorderView.bottomAnchor.constraint(equalTo: glassContainer.bottomAnchor),
            
            timerLabel.centerXAnchor.constraint(equalTo: glassContainer.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: glassContainer.centerYAnchor),
            timerLabel.widthAnchor.constraint(equalTo: glassContainer.widthAnchor, constant: -20)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = glassContainer.frame.width / 2
        glassContainer.layer.cornerRadius = radius
        staticBorderView.layer.cornerRadius = radius
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard progress > 0 else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (glassContainer.frame.width / 2)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (2 * CGFloat.pi * progress)
        
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        pinkColor.setStroke()
        path.lineWidth = 10.0
        path.lineCapStyle = .round
        path.stroke()
    }

    // Helper Methods

    // Hides/Shows the timer text (Fixes togglePlayPause error)
    func setTimerTextHidden(_ hidden: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.timerLabel.alpha = hidden ? 0 : 1
        }
    }
    
    // Forces the border to be fully pink 
    func setFullProgress() {
        self.progress = 1.0
    }

    func updateProgress(secondsRemaining: Int, totalDuration: Int) {
        showTime(secondsRemaining)
        
        // Calculate how much of the border should be drawn
        if totalDuration > 0 {
            let elapsed = CGFloat(totalDuration - secondsRemaining)
            self.progress = elapsed / CGFloat(totalDuration)
        }
    }

    func showTime(_ secondsRemaining: Int) {
        timerLabel.isHidden = false
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    func showMessage(_ text: String) {
        timerLabel.isHidden = false
        timerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        timerLabel.text = text
    }
    
    func reset() {
        self.progress = 0
        timerLabel.text = ""
        timerLabel.alpha = 1
    }
}
