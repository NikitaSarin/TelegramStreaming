//
//  Streaming.ViewAssembly.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit
import AVFoundation

extension Streaming {

    final class Provider { }
}

extension Streaming.Provider : StreamingProvider {

    var aspectRatio: CGFloat { 9 / 16 }

    var displayLayer: AVSampleBufferDisplayLayer? {
        nil
    }

    func provideVideo(completion: (UIView?) -> Void) {
        completion(
            UIImageView {
                $0.image = UIImage(named: "football")
                $0.contentMode = .scaleAspectFill
            }
        )
    }
}
