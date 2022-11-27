//
//  Streaming.VideoView.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 24.11.2022.
//

import UIKit

protocol StreamingVideoViewDelegate: AnyObject {

    func closeButtonTapped()
}

extension Streaming {

    final class VideoView: UIView {

        private var videoContent: UIView?

        private(set) lazy var closeButton = UIButton {
            $0.setImage(UIImage(bundleImageName: "Call/CallCancelButton"), for: .normal)
            $0.alpha = 0
            $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }

        private let gradientLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            let colors: [UIColor] = [
                .white.withAlphaComponent(0),
                .white.withAlphaComponent(0.7),
                .white.withAlphaComponent(0)
            ]
            layer.backgroundColor = UIColor.clear.cgColor
            layer.colors = colors.map { $0.cgColor }
            layer.locations = [0, 0.5, 1]
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint(x: 1, y: 0.5)
            layer.opacity = 0
            return layer
        }()

        private lazy var closeWidthConstraint = closeButton.widthAnchor.constraint(equalToConstant: 30)
        private lazy var closeTrailingConstraint = closeButton.trailingAnchor.constraint(
            equalTo: safeAreaLayoutGuide.trailingAnchor
        )
        private lazy var closeTopConstraint = closeButton.topAnchor.constraint(
            equalTo: topAnchor, constant: 50
        )

        private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        private let imageView = UIImageView {
            $0.alpha = 0
            $0.contentMode = .scaleAspectFill
        }

        private let provider: StreamingProvider
        private weak var delegate: StreamingVideoViewDelegate?

        init(
            provider: StreamingProvider,
            delegate: StreamingVideoViewDelegate
        ) {
            self.provider = provider
            self.delegate = delegate
            super.init(frame: .zero)

            setup()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.VideoView {

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = blurView.bounds

        if let video = videoContent {
            let height, width: CGFloat
            if isLandscape {
                width = bounds.width
                height = width / provider.aspectRatio
            } else {
                height = bounds.height
                width = height * provider.aspectRatio
            }
            let x = (bounds.width - width) / 2
            let y = (bounds.height - height) / 2

            video.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

extension Streaming.VideoView {

    var isLandscape: Bool {
        provider.aspectRatio > 1
    }

    var aspectRatio: CGFloat {
        provider.aspectRatio
    }

    func setCloseButtonLarge(_ isLarge: Bool) {
        let offset: CGFloat = isLarge ? 14 : 10
        closeButton.imageEdgeInsets = UIEdgeInsets(top: offset, left: offset, bottom: offset, right: offset)

        if isLarge {
            closeTopConstraint.constant = isLandscape ? 8 : 50
            closeTrailingConstraint.constant = isLandscape ? -50 : -8
        } else {
            closeTopConstraint.constant = 0
            closeTrailingConstraint.constant = -2
        }

        closeWidthConstraint.constant = isLarge ? 44 : 30
    }

    func setBlur(visible: Bool) {
        if !visible, videoContent == nil {
            return
        }
        UIView.animate(withDuration: 0.2) { [self] in
            blurView.alpha = visible ? 1 : 0
        }
    }

    func set(preview: UIImage) {
        imageView.image = preview
        if videoContent == nil {
            UIView.animate(withDuration: 0.2) { [self] in
                imageView.alpha = 1
            }
        }
    }

    func loadVideoIfNeeded() {
        guard
            videoContent == nil
        else { return }
        provider.provideVideo { [weak self] video in
            guard let video = video else { return }
            self?.set(video: video)
        }
    }
}

private extension Streaming.VideoView {

    func setup() {
        backgroundColor = .black
        clipsToBounds = true

        func add(_ subview: UIView) {
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: leadingAnchor),
                subview.centerXAnchor.constraint(equalTo: centerXAnchor),
                subview.topAnchor.constraint(equalTo: topAnchor),
                subview.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
        add(imageView)
        blurView.layer.insertSublayer(gradientLayer, at: 0)
        add(blurView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeTopConstraint,
            closeTrailingConstraint,
            closeWidthConstraint,
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            setupAnimation()
        }
    }

    func setupAnimation() {
        gradientLayer.opacity = 1
        let width = UIScreen.main.bounds.width
        let from = CATransform3DTranslate(CATransform3DIdentity, -width, 0, 0)
        let to = CATransform3DTranslate(CATransform3DIdentity, width * 3, 0, 0)
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 1.2
        animation.fromValue = NSValue(caTransform3D: from)
        animation.toValue = NSValue(caTransform3D: to)
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "blink")
    }

    func set(video: UIView) {
        videoContent = video

        video.clipsToBounds = true
        video.translatesAutoresizingMaskIntoConstraints = false
        video.alpha = 0
        insertSubview(video, at: 0)
        setNeedsLayout()

        UIView.animate(withDuration: 0.2) { [self] in
            imageView.alpha = 0
            video.alpha = 1
        }
        UIView.animate(withDuration: 0.3, delay: 0.1) { [self] in
            blurView.alpha = 0
        }
    }

    @objc func closeButtonTapped() {
        delegate?.closeButtonTapped()
    }
}
