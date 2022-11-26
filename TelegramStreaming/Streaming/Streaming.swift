//
//  Streaming.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 26.11.2022.
//

import UIKit
import AVFoundation

public enum Streaming { }

protocol StreamingViewModel: StreamingButtonPanelDelegate,
                             StreamingNavigationBarDelegate,
                             StreamingVideoViewDelegate {
    func start()
}

protocol StreamingProvider {
    var displayLayer: AVSampleBufferDisplayLayer? { get }
    var videoView: UIView? { get }
}
