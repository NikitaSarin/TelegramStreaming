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

        enum PreviewPlacement {
            case topLeading
            case topTrailing
            case bottomLeading
            case bottomTrailing
        }

        var onAppear: VoidClosure?
        var onDisappear: VoidClosure?

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
        private let numberView = GradientNumberView()
        private let wathingLabel = UILabel {
            $0.text = "watching"
            $0.font = .systemRoundedFont(ofSize: 16, weight: .bold)
            $0.textColor = .white
        }
        private lazy var panel = ButtonPanel(delegate: viewModel)

        private lazy var previewPanGesture: UIPanGestureRecognizer = {
            let gesture = UIPanGestureRecognizer(target: self,
                                                 action: #selector(didPanPreview(gesture:)))
            gesture.delegate = self
            return gesture
        }()

        private lazy var pageSheetPanGesture: UIPanGestureRecognizer = {
            let gesture = UIPanGestureRecognizer(target: self,
                                                 action: #selector(didPanPageSheet(gesture:)))
            gesture.delegate = self
            return gesture
        }()

        private lazy var contentHeight = videoViewSize.height + 294

        private lazy var containerBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: Appearence.cornerRadius
        )
        private lazy var containerTopConstraint = containerView.topAnchor.constraint(
            equalTo: view.bottomAnchor
        )

        var mode: Mode = .pageSheet {
            didSet {
                updateLayout(from: oldValue)
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

// MARK: - Override

extension Streaming.ViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        viewModel.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onAppear?()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDisappear?()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        switch mode {
        case .pageSheet:
            let x = videoViewOffset
            let y = navigationBar.convert(navigationBar.frame.origin, to: view).y + navigationBar.frame.height + 16
            videoView.frame.origin = CGPoint(x: x, y: y)
        case .fullScreen:
            videoView.frame.origin = .zero
        case .miniPreview: break
        }
        videoView.frame.size = videoViewSize
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            Streaming.window?.resignKey()
            Streaming.window = nil
            completion?()
        }
    }
}

// MARK: - Interface

extension Streaming.ViewController {

    var videoViewSize: CGSize {
        switch mode {
        case .pageSheet:
            let width = UIScreen.main.bounds.width - videoViewOffset * 2
            let height = width / (16 / 9)
            return CGSize(width: width, height: height)
        case .miniPreview:
            let width, height: CGFloat
            if videoView.isLandscape {
                width = (view.bounds.width - videoViewOffset * 2) * 0.6
                height = width / videoView.aspectRatio
            } else {
                height = (view.bounds.width - videoViewOffset * 2) * 0.6
                width = height * videoView.aspectRatio
            }
            return CGSize(width: width, height: height)
        case .fullScreen:
            return view.bounds.size
        }
    }

    var moreButton: UIView {
        navigationBar.moreButton
    }

    func updateTitle() {
        navigationBar.title.set(text: viewModel.title)
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
        numberView.set(value: watchersCount, animated: true)
    }
}


// MARK: - UIGestureRecognizerDelegate

extension Streaming.ViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case previewPanGesture:
            return mode == .miniPreview
        case pageSheetPanGesture:
            return mode == .pageSheet
        default:
            return true
        }
    }
}

// MARK: - StreamingWindowDelegate

extension Streaming.ViewController: StreamingWindowDelegate {

    func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = view.hitTest(point, with: event)
        if mode == .miniPreview, result == view {
            return nil
        } else {
            return result
        }
    }
}

// MARK: - Layout

private extension Streaming.ViewController {

    enum Appearence {
        static let previewOffset: CGFloat = 8
        static let cornerRadius: CGFloat = 12
    }

    var videoViewOffset: CGFloat {
        switch mode {
        case .pageSheet:
            return 12
        case .miniPreview:
            return 8
        case .fullScreen:
            return 0
        }
    }

    func setup() {
        setupContainer()
        setupContent()

        videoView.setBlur(visible: true)
        updateLayout(from: mode)
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
            contentView.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
    }

    func setupContent() {
        videoView.addGestureRecognizer(previewPanGesture)
        containerView.addGestureRecognizer(pageSheetPanGesture)

        [navigationBar, numberView, wathingLabel, panel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            navigationBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: 14),
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

    func updateLayout(from: Mode) {
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
        videoView.isUserInteractionEnabled = !isPageSheet

        UIView.animate(
            withDuration: transitionDuration(from: from, to: mode),
            delay: 0,
            usingSpringWithDamping: 0.73,
            initialSpringVelocity: 0.05
        ) { [self] in
            if mode == .miniPreview {
                let size = videoViewSize
                let offset: CGFloat = 8
                let x = view.bounds.width - size.width - offset
                let y = view.safeAreaInsets.top + offset
                videoView.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            }
            videoView.setCloseButtonLarge(mode == .fullScreen)
            videoView.closeButton.alpha = isPageSheet ? 0 : 1
            videoView.layer.cornerRadius = radius
            let needRotate = mode == .fullScreen && videoView.isLandscape
            videoView.transform = needRotate ? .identity.rotated(by: .pi / 2) : .identity
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }

    func transitionDuration(from: Mode, to: Mode) -> Double {
        switch (from, to) {
        case (.fullScreen, .pageSheet):
            return 0.85
        default:
            return 0.6
        }
    }
}

// MARK: - Page Sheet

private extension Streaming.ViewController {

    @objc func didPanPageSheet(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: view)
            let from = containerBottomConstraint.constant
            let to = from + translation.y
            containerBottomConstraint.constant = max(to, Appearence.cornerRadius)
            gesture.setTranslation(.zero, in: view)
        case .ended, .failed, .cancelled:
            let needDismiss = containerBottomConstraint.constant > contentHeight * 0.3
            if needDismiss {
                dismiss(animated: true)
            } else {
                containerBottomConstraint.constant = Appearence.cornerRadius
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: .curveEaseInOut
                ) { [self] in
                    view.layoutIfNeeded()
                }
            }
        default: break
        }
    }
}

// MARK: - Preview

private extension Streaming.ViewController {

    @objc func didPanPreview(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: view)
            let from = videoView.frame.origin
            videoView.frame.origin = CGPoint(x: from.x + translation.x, y: from.y + translation.y)
            gesture.setTranslation(.zero, in: view)
        case .ended, .failed, .cancelled:
            let next = calculateNextPreviewPlacement()
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut
            ) { [self] in
                videoView.frame.origin = previewOrigin(for: next)
            }
        default: break
        }
    }

    func calculateNextPreviewPlacement() -> PreviewPlacement {
        let onTopSide = videoView.frame.midY < view.bounds.height / 2
        let onLeadingSide = videoView.frame.midX < view.bounds.width / 2
        if onTopSide {
            return onLeadingSide ? .topLeading : .topTrailing
        } else {
            return onLeadingSide ? .bottomLeading : .bottomTrailing
        }
    }

    func previewOrigin(for placement: PreviewPlacement) -> CGPoint {
        let offset = Appearence.previewOffset
        let size = videoViewSize
        let x, y: CGFloat
        switch placement {
        case .topLeading:
            x = offset
            y = view.safeAreaInsets.top + offset
        case .topTrailing:
            x = view.bounds.width - size.width - offset
            y = view.safeAreaInsets.top + offset
        case .bottomTrailing:
            x = view.bounds.width - size.width - offset
            y = view.bounds.height - size.height - offset - view.safeAreaInsets.bottom
        case .bottomLeading:
            x = offset
            y = view.bounds.height - size.height - offset - view.safeAreaInsets.bottom
        }
        return CGPoint(x: x, y: y)
    }
}
