import UIKit

class CircularTimerView: UIView {

    // MARK: - Properties
    private let glassContainer = UIView()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let timerLabel = UILabel()
    private let staticBorderView = UIView() // The thin white background ring
    
    // Progress tracking
    private var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay() // Redraws the moving border whenever progress changes
        }
    }

    private let pinkColor = UIColor(red: 232/255, green: 106/255, blue: 146/255, alpha: 1.0) // #E86A92
    
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
        
        // 1. Setup the Glass Circle
        glassContainer.clipsToBounds = true
        glassContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glassContainer)
        
        // 2. Add Blur Effect
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        glassContainer.addSubview(blurEffectView)
        
        // 3. Static White Outer Ring (The "Track")
        staticBorderView.backgroundColor = .clear
        staticBorderView.layer.borderWidth = 1.5 // Thin border as requested
        staticBorderView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        staticBorderView.translatesAutoresizingMaskIntoConstraints = false
        glassContainer.addSubview(staticBorderView)
        
        // 4. Timer Text
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

    // MARK: - Custom Drawing (The Moving Border)
    // This replaces CAShapeLayer to create the progress line around the outskirts
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard progress > 0 else { return }
        
        // Calculate the path for the thin pink border
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
        path.lineWidth = 3.0 // Thin moving border
        path.lineCapStyle = .round
        path.stroke()
    }

    // MARK: - Public Helper Methods (Fixed Errors)

    /// Hides/Shows the timer text (Fixes togglePlayPause error)
    func setTimerTextHidden(_ hidden: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.timerLabel.alpha = hidden ? 0 : 1
        }
    }
    
    /// Forces the border to be fully pink (Fixes tick error)
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
