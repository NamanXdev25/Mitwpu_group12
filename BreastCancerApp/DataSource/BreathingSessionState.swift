import Foundation

final class BreathingSessionState {
    let totalDuration: Int
    private(set) var secondsRemaining: Int

    private var timer: Timer?
    private(set) var isRunning: Bool = false

    var onTick: ((Int, Int) -> Void)?
    var onFinished: (() -> Void)?

    init(duration: Int) {
        totalDuration = duration
        secondsRemaining = duration
    }

    func start() {
        stop()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func reset() {
        stop()
        secondsRemaining = totalDuration
    }

    private func tick() {
        guard secondsRemaining > 0 else {
            finish()
            return
        }

        secondsRemaining -= 1
        onTick?(secondsRemaining, totalDuration)
    }

    private func finish() {
        stop()
        onFinished?()
    }
}
