//
//  Streaming.LightningView.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 04.12.2022.
//

import UIKit

extension Streaming {

    final class LightningView: UIView {

        private let blurView: UIView = {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            return view
        }()

        private let maskLayer = MaskLayer()

        private let provider: StreamingProvider

        private var videoContent: CALayer?

        init(provider: StreamingProvider) {
            self.provider = provider
            super.init(frame: .zero)

            setup()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.LightningView {

    override func layoutSubviews() {
        super.layoutSubviews()
        videoContent?.frame = bounds
        maskLayer.frame = bounds
    }
}

extension Streaming.LightningView {

    func loadVideoIfNeeded() {
        guard
            videoContent == nil
        else { return }

        provider.provideLightningVideoLayer { [weak self] in
            guard
                let self = self,
                let layer = $0
            else { return }
            layer.opacity = 0
            self.videoContent = layer
            self.layer.insertSublayer(layer, at: 0)
            layer.frame = self.bounds

            let to: Float = 1.0
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.0
            animation.toValue = to
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(animation, forKey: nil)
            layer.opacity = to
        }
    }

    func setVideoVisible(_ visible: Bool) {
        UIView.animate(withDuration: visible ? 1.0 : 0.3) { [self] in
            alpha = visible ? 1 : 0
        }
    }
}

private extension Streaming.LightningView {

    func setup() {
        clipsToBounds = true
        layer.mask = maskLayer

        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private final class MaskLayer: CALayer {

    private let verticalGradient: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(white: 0, alpha: 0).cgColor,
            UIColor(white: 0, alpha: 0.7).cgColor,
            UIColor(white: 0, alpha: 0).cgColor
        ]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private let maskGradient: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(white: 0, alpha: 0).cgColor,
            UIColor(white: 0, alpha: 1).cgColor,
            UIColor(white: 0, alpha: 1).cgColor,
            UIColor(white: 0, alpha: 0).cgColor
        ]
        layer.locations = [0, 0.2, 0.8, 1]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
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
        verticalGradient.frame = bounds
        maskGradient.frame = bounds
    }

    func setup() {
        addSublayer(verticalGradient)
        verticalGradient.mask = maskGradient
    }
}
