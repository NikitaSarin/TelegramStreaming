//
//  Streaming.VideoView.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 24.11.2022.
//

import UIKit

enum Streaming {

    final class VideoView: UIView {

        var hasVideo: Bool { videoContent != nil }

        private var videoContent: UIView?

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

        private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        private let imageView = UIImageView {
            $0.alpha = 0
            $0.contentMode = .scaleAspectFill
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.VideoView {

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = blurView.bounds
    }
}

extension Streaming.VideoView {

    func setBlur(visible: Bool) {
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

    func set(video: UIView) {
        if let old = videoContent {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                animations: {
                    old.alpha = 0
                }, completion: { _ in
                    old.removeFromSuperview()
                }
            )
        }
        video.translatesAutoresizingMaskIntoConstraints = false
        video.alpha = 0
        insertSubview(video, at: 0)
        NSLayoutConstraint.activate([
            video.leadingAnchor.constraint(equalTo: leadingAnchor),
            video.centerXAnchor.constraint(equalTo: centerXAnchor),
            video.topAnchor.constraint(equalTo: topAnchor),
            video.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        UIView.animate(withDuration: 0.2) { [self] in
            imageView.alpha = 0
            video.alpha = 1
        }
    }
}

private extension Streaming.VideoView {

    func setup() {
        backgroundColor = .black
        clipsToBounds = true
        layer.cornerRadius = 10

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
}
