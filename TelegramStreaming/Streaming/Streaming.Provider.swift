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
        private lazy var timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [self] _ in
            value = (value + 1) % colors.count
            layer.backgroundColor = colors[value].cgColor
        }

        let aspectRatio: CGFloat

        init(aspectRatio: CGFloat) {
            self.aspectRatio = aspectRatio
        }

        var displayLayer: AVSampleBufferDisplayLayer? {
            nil
        }

        func provideVideoLayer(completion: @escaping (CALayer?) -> Void) {
            completion(layer)
            timer.fire()
        }

        func provideLightningVideoLayer(completion: @escaping (CALayer?) -> Void) {
            provideVideoLayer(completion: completion)
        }

        func snapshotLastFrame() -> UIImage? {
            nil
        }
    }
}
