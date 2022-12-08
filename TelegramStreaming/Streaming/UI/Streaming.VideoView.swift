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

        let lightningView: Streaming.LightningView
        private var videoContent: CALayer?

        private(set) lazy var closeButton = UIButton {
            $0.setImage(UIImage(bundleImageName: "Call/CallCancelButton"), for: .normal)
            $0.alpha = 0
            $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }
        private let blinkLayer = BlinkLayer()

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
            $0.clipsToBounds = true
        }

        private let provider: StreamingProvider
        private weak var delegate: StreamingVideoViewDelegate?

        private let backgroundLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = Appearence.backgroundColor
            layer.masksToBounds = true
            return layer
        }()

        init(
            provider: StreamingProvider,
            delegate: StreamingVideoViewDelegate
        ) {
            self.provider = provider
            self.delegate = delegate
            self.lightningView = Streaming.LightningView(provider: provider)
            super.init(frame: .zero)

            setup()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.VideoView {

    override func layoutSubviews() {
        super.layoutSubviews()

        blinkLayer.frame = blurView.bounds
    }
}

extension Streaming.VideoView {

    func set(cornerRadius: CGFloat, duration: CGFloat) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        layer.cornerRadius = cornerRadius
        backgroundLayer.cornerRadius = cornerRadius
        videoContent?.cornerRadius = cornerRadius
        blinkLayer.set(cornerRadius: cornerRadius)
        imageView.layer.cornerRadius = cornerRadius
        blurView.layer.cornerRadius = cornerRadius
        CATransaction.commit()
    }

    func set(size: CGSize, needRotate: Bool, duration: CGFloat) {
        let layerSize = needRotate ? CGSize(width: size.height, height: size.width) : size
        let rect = calculateVideoFrame(in: layerSize)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.backgroundColor = UIColor.clear.cgColor
        CATransaction.commit()

        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        backgroundLayer.frame = CGRect(origin: .zero, size: layerSize)
        videoContent?.frame = rect
        if !isLandscape {
            backgroundLayer.backgroundColor = Appearence.backgroundColor
        }
        CATransaction.commit()
        if isLandscape {
            CATransaction.setCompletionBlock { [self] in
                backgroundLayer.backgroundColor = Appearence.backgroundColor
            }
        }
    }

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
        lightningView.loadVideoIfNeeded()
        guard
            videoContent == nil
        else { return }
        provider.provideVideoLayer { [weak self] video in
            guard let video = video else { return }
            self?.set(video: video)
        }
    }
}

private extension Streaming.VideoView {

    enum Appearence {
        static let backgroundColor: CGColor = UIColor.black.cgColor
    }

    var screenRatio: CGFloat {
        let bounds =  UIScreen.main.bounds
        return bounds.width / bounds.height
    }

    func setup() {
        blurView.clipsToBounds = true

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

        lightningView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lightningView)
        layer.addSublayer(backgroundLayer)
        add(imageView)
        blurView.layer.addSublayer(blinkLayer)
        add(blurView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeTopConstraint,
            closeTrailingConstraint,
            closeWidthConstraint,
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),

            lightningView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lightningView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lightningView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.2),
            lightningView.heightAnchor.constraint(equalTo: heightAnchor,  multiplier: 1.32)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            blinkLayer.setupAnimation()
        }
    }

    func set(video: CALayer) {
        videoContent = video

        video.masksToBounds = true
        video.opacity = 0
        video.cornerRadius = layer.cornerRadius
        layer.insertSublayer(video, at: 2)
        let rect = calculateVideoFrame(in: bounds.size)
        video.frame = rect

        UIView.animate(withDuration: 0.2) { [self] in
            imageView.alpha = 0
            video.opacity = 1
        }
        UIView.animate(withDuration: 0.3, delay: 0.1) { [self] in
            blurView.alpha = 0
        }
    }

    func calculateVideoFrame(in parentSize: CGSize) -> CGRect {
        let height, width: CGFloat
        if isLandscape, aspectRatio > screenRatio {
            width = parentSize.width
            height = width / provider.aspectRatio
        } else {
            height = parentSize.height
            width = height * provider.aspectRatio
        }
        let x = (parentSize.width - width) / 2
        let y = (parentSize.height - height) / 2

        let rect =  CGRect(x: x, y: y, width: width, height: height)
        return rect
    }

    @objc func closeButtonTapped() {
        delegate?.closeButtonTapped()
    }
}

private final class BlinkLayer: CALayer {

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

    private let maskLayer: CAShapeLayer = {
        let border = CAShapeLayer()
        border.fillColor = UIColor(white: 0, alpha: 0.3).cgColor
        border.strokeColor = UIColor(white: 0, alpha: 0.5).cgColor
        border.lineWidth = 4
        return border
    }()

    override init() {
        super.init()
        setup()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSublayers() {
        super.layoutSublayers()
        gradientLayer.frame = bounds
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        mask = maskLayer
        addSublayer(gradientLayer)
    }

    func set(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        setNeedsLayout()
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

    @objc func applicationDidBecomeActive() {
        setupAnimation()
    }
}
