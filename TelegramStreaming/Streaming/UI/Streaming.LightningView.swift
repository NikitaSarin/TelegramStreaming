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
            self.videoContent = layer
            self.layer.insertSublayer(layer, at: 0)
            layer.frame = self.bounds

            UIView.animate(withDuration: 0.4) {
                self.alpha = 1
            }
        }
    }
}

private extension Streaming.LightningView {

    func setup() {
        alpha = 0
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

    private let verticalGradiemt: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 0, alpha: 0.6).cgColor,
            UIColor(white: 0, alpha: 0.6).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.35, 0.65, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private let radialGradiemt: CALayer = {
        let layer = CAGradientLayer()
        layer.type = .radial
        layer.colors = [
            UIColor(white: 0, alpha: 0.5).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0.5, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 1)
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
        verticalGradiemt.frame = bounds
        radialGradiemt.frame = bounds
    }

    func setup() {
        addSublayer(verticalGradiemt)
        addSublayer(radialGradiemt)
    }
}
