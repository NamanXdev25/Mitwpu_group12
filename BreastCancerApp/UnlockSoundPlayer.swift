import AVFoundation
import Foundation

final class UnlockSoundPlayer {
    static let shared = UnlockSoundPlayer()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format: AVAudioFormat

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.95

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {}
    }

    func playUnlock() {
        if !engine.isRunning {
            try? engine.start()
        }

        let buffer = makeUnlockBuffer()
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        player.play()
    }

    private func makeUnlockBuffer() -> AVAudioPCMBuffer {
        let sampleRate = format.sampleRate
        let totalDuration = 0.70
        let frameCount = AVAudioFrameCount(totalDuration * sampleRate)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let channel = buffer.floatChannelData![0]

        func addNote(start: Double, duration: Double, freq: Double, amp: Double) {
            let startFrame = max(0, Int(start * sampleRate))
            let endFrame = min(Int(Double(frameCount)), Int((start + duration) * sampleRate))
            guard endFrame > startFrame else { return }

            let attack = 0.010

            for frame in startFrame ..< endFrame {
                let t = Double(frame - startFrame) / sampleRate
                let phase = 2.0 * Double.pi * freq * t

                let env: Double
                if t < attack {
                    env = t / attack
                } else {
                    env = exp(-4.8 * (t - attack) / duration)
                }

                let tone =
                    sin(phase) +
                    0.38 * sin(phase * 2.0) +
                    0.17 * sin(phase * 3.0)

                channel[frame] += Float(tone * env * amp)
            }
        }

        addNote(start: 0.00, duration: 0.19, freq: 523.25, amp: 0.20)
        addNote(start: 0.12, duration: 0.19, freq: 659.25, amp: 0.20)
        addNote(start: 0.24, duration: 0.21, freq: 783.99, amp: 0.20)
        addNote(start: 0.39, duration: 0.24, freq: 1046.50, amp: 0.24)

        addNote(start: 0.43, duration: 0.10, freq: 1567.98, amp: 0.07)
        addNote(start: 0.50, duration: 0.09, freq: 1318.51, amp: 0.06)

        for i in 0 ..< Int(frameCount) {
            channel[i] = max(-0.95, min(0.95, channel[i]))
        }

        return buffer
    }
}
