//
//  Streaming.ViewController.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 24.11.2022.
//

import UIKit

extension Streaming {

    final class ViewController: UIViewController {

        private let viewModel: StreamingViewModel
        private let viewAssembly: StreamingViewAssembling

        private let containerView = UIView {
            $0.layer.cornerRadius = Appearence.cornerRadius
            $0.backgroundColor = UIColor(red: 28 / 255,
                                         green: 28 / 255,
                                         blue: 30 / 255,
                                         alpha: 1)
        }
        private let contentView = UIView()

        private lazy var navigationBar = NavigationBar(title: viewModel.title,
                                                       delegate: viewModel)
        private let videoView = Streaming.VideoView()
        private let numberView = NumberView()
        private let wathingLabel = UILabel {
            $0.text = "watching"
            $0.font = .systemRoundedFont(ofSize: 16, weight: .bold)
            $0.textColor = .white
        }
        private lazy var panel = ButtonPanel(delegate: viewModel)

        init(
            viewModel: StreamingViewModel,
            viewAssembly: StreamingViewAssembling
        ) {
            self.viewModel = viewModel
            self.viewAssembly = viewAssembly
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        viewModel.start()
    }
}

extension Streaming.ViewController {

    func setMoreButton(visible: Bool) {
        navigationBar.setMoreButton(visible: visible)
    }

    func set(preview: UIImage) {
        videoView.set(preview: preview)
    }

    func set(live: Bool) {
        navigationBar.set(live: live)
        videoView.setBlur(visible: !live)
        if live, !videoView.hasVideo, let view = viewAssembly.makeVideoView() {
            videoView.set(video: view)
        }
    }

    func set(watchersCount: Int) {
        numberView.value = watchersCount
    }
}

private extension Streaming.ViewController {

    enum Appearence {
        static let cornerRadius: CGFloat = 12
    }

    func setup() {
        setupContainer()
        setupContent()

        videoView.setBlur(visible: true)
    }

    func setupContainer() {
        [containerView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(containerView)
        containerView.addSubview(contentView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                  constant: Appearence.cornerRadius),

            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                             constant: Appearence.cornerRadius),
            contentView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -Appearence.cornerRadius),
        ])
    }

    func setupContent() {
        [navigationBar, videoView, numberView, wathingLabel, panel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            navigationBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            videoView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 12),
            videoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            videoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            videoView.widthAnchor.constraint(equalTo: videoView.heightAnchor,
                                              multiplier: 16 / 9),

            numberView.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 36),
            numberView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor,
                                                constant: 12),
            numberView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            wathingLabel.topAnchor.constraint(equalTo: numberView.bottomAnchor),
            wathingLabel.heightAnchor.constraint(equalToConstant: 20),
            wathingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            panel.topAnchor.constraint(equalTo: wathingLabel.topAnchor, constant: 56),
            panel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            panel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            panel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -38),
        ])
    }
}
