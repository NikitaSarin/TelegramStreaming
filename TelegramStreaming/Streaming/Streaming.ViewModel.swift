//
//  Streaming.ViewModel.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

protocol StreamingViewModel: StreamingButtonPanelDelegate, StreamingNavigationBarDelegate {

    var title: String { get }

    func start()
}

extension Streaming {

    final class ViewModel {
        weak var view: Streaming.ViewController?

        private var timer: Timer?
    }
}

extension Streaming.ViewModel: StreamingViewModel {

    var title: String { "Telesport" }

    func start() {
        timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(updateWatchers),
            userInfo: nil,
            repeats: true
        )
        view?.set(watchersCount: 84249)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            view?.set(preview: UIImage(named: "football")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            view?.set(live: true)
        }
    }

    var shouldShowPipButton: Bool {
        true
    }

    func pipButtonTapped() {
        //
    }

    func moreButtonTapped() {
        //
    }

    func shareButtonTapped() {
        //
    }

    func expandButtonTapped() {
        //
    }

    func leaveButtonTapped() {
        //
    }
}

private extension Streaming.ViewModel {

    @objc func updateWatchers() {
        let count = Int.random(in: (84000..<85000))
        view?.set(watchersCount: count)
        view?.set(live: count % 2 == 0)
    }
}
