
import Foundation

struct BreathingMediaPair {
    let videoName: String
    let audioName: String
    let loopStartTrim: Double
    let loopEndTrim: Double

    init(
        videoName: String,
        audioName: String,
        loopStartTrim: Double = 0.0,
        loopEndTrim: Double = 0.0
    ) {
        self.videoName = videoName
        self.audioName = audioName
        self.loopStartTrim = loopStartTrim
        self.loopEndTrim = loopEndTrim
    }
}

enum BreathingMediaCatalog {
    private static let mediaBySessionTitle: [String: BreathingMediaPair] = [
        "Calmer Mind": BreathingMediaPair(
            videoName: "calmermind_video",
            audioName: "calmermind_audio",
            loopStartTrim: 0.18,
            loopEndTrim: 0.04
        ),
        "Gentle Focus": BreathingMediaPair(videoName: "gentlefocus_video", audioName: "gentlefocus_audio", loopStartTrim: 0.18, loopEndTrim: 0.04),
        "Inner Calm": BreathingMediaPair(videoName: "innercalm_video", audioName: "innercalm_audio", loopStartTrim: 0.18, loopEndTrim: 0.04),
        "Gentle Recharge": BreathingMediaPair(videoName: "gentlerecharge_video", audioName: "gentlerecharge_audio", loopStartTrim: 0.18, loopEndTrim: 0.04),
        "Nausea Relief": BreathingMediaPair(videoName: "nausearelief_video", audioName: "nausearelief_audio", loopStartTrim: 0.18, loopEndTrim: 0.06),
        "Deep Rest": BreathingMediaPair(videoName: "deeprest_video", audioName: "deeprest_audio", loopStartTrim: 0.18, loopEndTrim: 0.06),
        "Morning Appreciation": BreathingMediaPair(videoName: "morningappreciation_video", audioName: "morningappreciation_audio", loopStartTrim: 0.18, loopEndTrim: 0.06),
        "Healing Reflections": BreathingMediaPair(videoName: "healingreflection_video", audioName: "healingreflection_audio", loopStartTrim: 0.18, loopEndTrim: 0.06),
        
    ]

    static func media(for sessionTitle: String) -> BreathingMediaPair? {
        mediaBySessionTitle[sessionTitle]
    }
}
