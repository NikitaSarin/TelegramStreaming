//
//  Streaming.NavigationBar.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

protocol StreamingNavigationBarDelegate: AnyObject {

    func pipButtonTapped()

    func moreButtonTapped()
}

extension Streaming {

    final class NavigationBar: UIView {

        private(set) lazy var moreButton = UIButton {
            $0.layer.cornerRadius = Appearence.buttonEdge / 2
            $0.backgroundColor = Appearence.buttonBackground
            let image = UIImage(bundleImageName: "Peer Info/ButtonMore")?
                .withRenderingMode(.alwaysTemplate)
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.isHidden = true
            $0.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        }

        let title = Title()

        private(set) lazy var pipButton = UIButton {
            $0.layer.cornerRadius = Appearence.buttonEdge / 2
            $0.backgroundColor = Appearence.buttonBackground
            let image = UIImage(bundleImageName: "Media Gallery/PictureInPictureButton")?
                .withRenderingMode(.alwaysTemplate)
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            $0.addTarget(self, action: #selector(pipButtonTapped), for: .touchUpInside)
        }

        private weak var delegate: StreamingNavigationBarDelegate?

        init(delegate: StreamingNavigationBarDelegate) {
            self.delegate = delegate
            super.init(frame: .zero)

            setup()
        }

        required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

private extension Streaming.NavigationBar {

    enum Appearence {
        static let buttonEdge: CGFloat = 28
        static let buttonBackground = UIColor(red: 50 / 255,
                                              green: 50 / 255,
                                              blue: 53 / 255,
                                              alpha: 1)
    }

    func setup() {
        [moreButton, title, pipButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            moreButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            moreButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            moreButton.heightAnchor.constraint(equalToConstant: Appearence.buttonEdge),
            moreButton.widthAnchor.constraint(equalTo: moreButton.heightAnchor),

            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            title.topAnchor.constraint(equalTo: topAnchor),

            pipButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            pipButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            pipButton.heightAnchor.constraint(equalToConstant: Appearence.buttonEdge),
            pipButton.widthAnchor.constraint(equalTo: pipButton.heightAnchor),
        ])
    }
}

private extension Streaming.NavigationBar {

    @objc func moreButtonTapped() {
        delegate?.moreButtonTapped()
    }

    @objc func pipButtonTapped() {
        delegate?.pipButtonTapped()
    }
}

extension Streaming.NavigationBar {

    final class Title: UIView {

        private let titleLabel = UILabel {
            $0.font = .systemRoundedFont(ofSize: 18, weight: .semibold)
            $0.textColor = .white
        }

        private let liveLabelContainer = UIView {
            $0.backgroundColor = Appearence.pendingColor
            $0.layer.cornerRadius = Appearence.liveHeight / 2
            $0.clipsToBounds = true
        }

        private let liveLabel = UILabel {
            $0.text = "LIVE"
            $0.font = .systemRoundedFont(ofSize: 11, weight: .bold)
            $0.textColor = .white
        }

        private var isLive = false

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.NavigationBar.Title {

    func set(text: String) {
        titleLabel.text = text
    }

    func set(live: Bool) {
        guard
            isLive != live
        else { return }

        isLive = live
        liveLabelContainer.backgroundColor = live ? Appearence.liveColor : Appearence.pendingColor

        if live {
            liveLabel.layer.removeAllAnimations()
            liveLabelContainer.layer.removeAllAnimations()

            let transform = CATransform3DScale(CATransform3DIdentity, 1.14, 1.14, 1)
            let animation = CABasicAnimation(keyPath: "transform")
            animation.duration = 0.14
            animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            animation.toValue = NSValue(caTransform3D: transform)
            animation.autoreverses = true
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            liveLabel.layer.add(animation, forKey: "transform")
            liveLabelContainer.layer.add(animation, forKey: "transform")
        }
    }
}

private extension Streaming.NavigationBar.Title {

    enum Appearence {
        static let liveColor = UIColor(red: 226 / 255, green: 51 / 255, blue: 92 / 255, alpha: 1)
        static let pendingColor =  UIColor(red: 97 / 255, green: 97 / 255, blue: 97 / 255, alpha: 1)
        static let liveHeight: CGFloat = 21
    }

    func setup() {
        [titleLabel, liveLabelContainer, liveLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        addSubview(titleLabel)
        addSubview(liveLabelContainer)
        liveLabelContainer.addSubview(liveLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            liveLabelContainer.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            liveLabelContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            liveLabelContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            liveLabelContainer.heightAnchor.constraint(equalToConstant: Appearence.liveHeight),
            liveLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            liveLabel.leadingAnchor.constraint(equalTo: liveLabelContainer.leadingAnchor, constant: 6),
            liveLabel.topAnchor.constraint(equalTo: liveLabelContainer.topAnchor),
            liveLabel.centerXAnchor.constraint(equalTo: liveLabelContainer.centerXAnchor),
            liveLabel.centerYAnchor.constraint(equalTo: liveLabelContainer.centerYAnchor),
        ])
    }
}
