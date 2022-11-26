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

        enum Mode {
            case pageSheet
            case fullScreen
            case miniPreview
        }

        private let containerView = UIView {
            $0.layer.cornerRadius = Appearence.cornerRadius
            $0.backgroundColor = UIColor(red: 28 / 255,
                                         green: 28 / 255,
                                         blue: 30 / 255,
                                         alpha: 1)
        }
        private let contentView = UIView()

        private lazy var navigationBar = NavigationBar(delegate: viewModel)
        private let videoView: Streaming.VideoView
        private let numberView = NumberView()
        private let wathingLabel = UILabel {
            $0.text = "watching"
            $0.font = .systemRoundedFont(ofSize: 16, weight: .bold)
            $0.textColor = .white
        }
        private lazy var panel = ButtonPanel(delegate: viewModel)

        private lazy var containerBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: Appearence.cornerRadius
        )
        private lazy var containerTopConstraint = containerView.topAnchor.constraint(
            equalTo: view.bottomAnchor
        )

        var mode: Mode = .pageSheet {
            didSet {
                updateLayout()
            }
        }

        init(viewModel: StreamingViewModel, provider: StreamingProvider) {
            self.viewModel = viewModel
            self.videoView = Streaming.VideoView(provider: provider, delegate: viewModel)
            super.init(nibName: nil, bundle: nil)

            modalPresentationStyle = .overCurrentContext
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        switch mode {
        case .pageSheet:
            let offset: CGFloat = 12
            let width = view.bounds.width - offset * 2
            let height = width / (16 / 9)
            let x = offset
            let y = navigationBar.convert(navigationBar.frame.origin, to: view).y + navigationBar.frame.height + 12
            videoView.frame = CGRect(x: x, y: y, width: width, height: height)
        case .fullScreen:
            videoView.frame = view.bounds
        case .miniPreview:
            let offset: CGFloat = 8
            let width = (view.bounds.width - offset * 2) * 0.6
            let height = width / (16 / 9)
            let x = view.bounds.width - width - offset
            let y = view.safeAreaInsets.top + offset
            videoView.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

extension Streaming.ViewController {

    func setMoreButton(visible: Bool) {
        navigationBar.moreButton.isHidden = !visible
    }

    func set(title: String) {
        navigationBar.title.set(text: title)
    }

    func set(live: Bool) {
        if live {
            videoView.loadVideoIfNeeded()
        }
        navigationBar.title.set(live: live)
        videoView.setBlur(visible: !live)
    }

    func set(preview: UIImage) {
        videoView.set(preview: preview)
    }

    func set(watchersCount: Int) {
        numberView.value = watchersCount
    }
}

private extension Streaming.ViewController {

    enum Appearence {
        static let cornerRadius: CGFloat = 12
        static let coontainerHeight: CGFloat = 500
    }

    func setup() {
        setupContainer()
        setupContent()

        videoView.setBlur(visible: true)
        updateLayout()
    }

    func setupContainer() {
        [containerView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(containerView)
        view.addSubview(videoView)
        containerView.addSubview(contentView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerBottomConstraint,

            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                             constant: Appearence.cornerRadius),
            contentView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -Appearence.cornerRadius),
            contentView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }

    func setupContent() {
        [navigationBar, numberView, wathingLabel, panel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            navigationBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

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

    func updateLayout() {
        let radius: CGFloat
        switch mode {
        case .pageSheet:
            radius = 10
        case .miniPreview:
            radius = 8
        case .fullScreen:
            radius = 0
        }

        let isPageSheet = mode == .pageSheet
        containerTopConstraint.isActive = !isPageSheet
        containerBottomConstraint.isActive = isPageSheet

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.05
        ) { [self] in
            videoView.setCloseButtonLarge(mode == .fullScreen)
            videoView.closeButton.alpha = isPageSheet ? 0 : 1
            videoView.layer.cornerRadius = radius
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
}
