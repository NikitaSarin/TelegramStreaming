//
//  Streaming.ViewAssembly.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit
import AVFoundation

extension Streaming {

    final class Provider: StreamingProvider  {

        let colors: [UIColor] = [
            .red, .green, .blue, .yellow, .white
        ]

        var value = 0
        private var layer = CALayer()
        private var timer: Timer?

        let aspectRatio: CGFloat

        init(aspectRatio: CGFloat) {
            self.aspectRatio = aspectRatio
        }

        var displayLayer: AVSampleBufferDisplayLayer? {
            nil
        }

        func provideVideoLayer(completion: @escaping (CALayer?) -> Void) {
            let layer = CALayer()
            layer.contents = UIImage(named: "football")!.cgImage
            completion(layer)
            //            timer = Timer.scheduledTimer(
            //                withTimeInterval: 1,
            //                repeats: true
            //            ) { [self] _ in
            //                value = (value + 1) % colors.count
            //                layer.backgroundColor = colors[value].cgColor
            //            }
//            timer.fire()
        }

        func setOnReceiveFrame(handler: @escaping (CIImage) -> Void) {
            let image = UIImage(named: "football")!
            handler(CIImage(image: image)!)
        }

        func snapshotLastFrame() -> UIImage? {
            nil
        }
    }
}
