//
//  Streaming.ViewAssembly.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit
import AVFoundation

extension Streaming {

    struct Provider: StreamingProvider  {

        let aspectRatio: CGFloat

        var displayLayer: AVSampleBufferDisplayLayer? {
            nil
        }

        func provideVideoLayer(completion: @escaping (CALayer?) -> Void) {
            let layer = CALayer()
            layer.contents = UIImage(named: "football")?.cgImage
            completion(layer)
        }

        func snapshotLastFrame() -> UIImage? {
            nil
        }
    }
}
