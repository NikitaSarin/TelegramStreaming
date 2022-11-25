//
//  Streaming.ViewAssembly.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

protocol StreamingViewAssembling {

    func makeVideoView() -> UIView?
}

extension Streaming {

    final class ViewAssembly {

    }
}

extension Streaming.ViewAssembly: StreamingViewAssembling {
    func makeVideoView() -> UIView? {
        UIImageView {
            $0.image = UIImage(named: "football")
            $0.contentMode = .scaleAspectFill
        }
    }
}
