//
//  VideoPlayerContainerView.swift
//  BreastCancerApp
//
//  Created by Shloka on 16/12/25.
//
import UIKit
import AVFoundation

final class VideoPlayerContainerView: UIView {

    var playerLayer: AVPlayerLayer? {
        didSet {
            if let oldLayer = oldValue {
                oldLayer.removeFromSuperlayer()
            }
            if let newLayer = playerLayer {
                layer.addSublayer(newLayer)
                setNeedsLayout()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}

