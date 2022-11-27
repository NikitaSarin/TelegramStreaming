//
//  Streaming.ViewModel.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit


extension Streaming {

    final class ViewModel {
        weak var view: Streaming.ViewController?

        private var timer: Timer?
    }
}

extension Streaming.ViewModel: StreamingViewModel {

    var title: String { "Telesport" }

    func start() {
        view?.moreButton.isHidden = false
        view?.updateTitle()
        view?.set(watchersCount: 31)
        timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(updateWatchers),
            userInfo: nil,
            repeats: true
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            view?.set(preview: UIImage(named: "football")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            view?.set(live: true)
        }
    }

    func pipButtonTapped() {
        view?.mode = .miniPreview
    }

    func moreButtonTapped() {

    }

    func shareButtonTapped() {
        //
    }

    func expandButtonTapped() {
        view?.mode = .fullScreen
    }

    func leaveButtonTapped() {
        view?.dismiss(animated: true)
    }

    func closeButtonTapped() {
        view?.mode = .pageSheet
    }
}

private extension Streaming.ViewModel {

    @objc func updateWatchers() {
        let count = Int.random(in: (31..<35))
        view?.set(watchersCount: count)
        view?.set(live: count % 2 == 0)
    }
}
