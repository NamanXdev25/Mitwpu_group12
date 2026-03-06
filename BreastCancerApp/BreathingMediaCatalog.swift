////
////  BreathingMediaCatalog.swift
////  BreastCancerApp
////
////  Created by Naman Bhansali on 06/03/26.
////
//
//// BreathingMediaCatalog.swift
//import Foundation
//
//struct BreathingMedia {
//    let videoName: String
//    let audioName: String
//}
//
//enum BreathingMediaCatalog {
//    // Put your 8 session titles exactly as they come in BreathingSession.title
//    private static let map: [String: BreathingMedia] = [
//        "Calmer Mind": BreathingMedia(videoName: "calmermind_video", audioName: "calmermind_audio"),
//
//        // Add remaining 7 here:
//        // "Morning Appreciation": BreathingMedia(videoName: "morning_appreciation_video", audioName: "morning_appreciation_audio"),
//        // "Inner Calm": BreathingMedia(videoName: "inner_calm_video", audioName: "inner_calm_audio"),
//    ]
//
//    static func media(for sessionTitle: String) -> BreathingMedia? {
//        map[sessionTitle]
//    }
//}

// BreathingMediaCatalog.swift
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
