//
//  Streaming.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 26.11.2022.
//

import UIKit
import AVFoundation

public enum Streaming {

    static var window: UIWindow?

    static func present(ratio: CGFloat) {
        let viewModel = Streaming.ViewModel()
        let provider = Streaming.Provider(aspectRatio: ratio)
        let viewController = Streaming.ViewController(viewModel: viewModel, provider: provider)

        viewModel.view = viewController

        let window = Streaming.Window()
        window.backgroundColor = .clear
        window.windowLevel = .alert
        window.delegate = viewController

        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(viewController, animated: true)

        Streaming.window = window
    }
}

protocol StreamingViewModel: StreamingButtonPanelDelegate,
                             StreamingNavigationBarDelegate,
                             StreamingVideoViewDelegate {
    var title: String { get }

    func start()

    func stop()
}


protocol StreamingProviderDelegate: AnyObject {

    func videoDidBecomeActive()

    func videoDidSuspended()
}

protocol StreamingProvider {

    var aspectRatio: CGFloat { get }

    var displayLayer: AVSampleBufferDisplayLayer? { get }

    func provideVideoLayer(completion: @escaping (CALayer?) -> Void)

    func setOnReceiveFrame(handler: @escaping (CIImage) -> Void)

    func snapshotLastFrame() -> UIImage?
}
