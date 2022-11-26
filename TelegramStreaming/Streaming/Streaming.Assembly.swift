//
//  Streaming.Assembly.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 26.11.2022.
//

import UIKit

extension Streaming {
    public enum Assembly {}
}

public extension Streaming.Assembly {

    static func make() -> UIViewController {
        let viewModel = Streaming.ViewModel()
        let provider = Streaming.Provider()
        let viewController = Streaming.ViewController(viewModel: viewModel, provider: provider)

        viewModel.view = viewController

        return viewController
    }
}
