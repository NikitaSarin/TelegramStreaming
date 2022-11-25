//
//  Streaming.NavigationBar.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

protocol StreamingNavigationBarDelegate: AnyObject {

    var shouldShowMoreButton: Bool { get }

    var shouldShowPipButton: Bool { get }

    func pipButtonTapped()

    func moreButtonTapped()
}

extension Streaming {

    final class NavigationBar: UIStackView {

        private lazy var moreButton = UIButton {
            $0.layer.cornerRadius = Appearence.buttonEdge / 2
            $0.backgroundColor = Appearence.buttonBackground
            $0.setImage(UIImage(named: ""), for: .normal)
            $0.isHidden = delegate?.shouldShowMoreButton != true
        }

        private let title: Title

        private lazy var pipButton = UIButton {
            $0.layer.cornerRadius = Appearence.buttonEdge / 2
            $0.backgroundColor = Appearence.buttonBackground
            $0.setImage(UIImage(named: ""), for: .normal)
            $0.isHidden = delegate?.shouldShowPipButton != true
        }

        private weak var delegate: StreamingNavigationBarDelegate?

        init(
            title: String,
            delegate: StreamingNavigationBarDelegate
        ) {
            self.title = Title(text: title)
            self.delegate = delegate
            super.init(frame: .zero)

            setup()
        }

        required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.NavigationBar {

    func set(live: Bool) {
        title.set(live: live)
    }
}


private extension Streaming.NavigationBar {

    enum Appearence {
        static let buttonEdge: CGFloat = 28
        static let buttonBackground = UIColor(red: 32 / 255,
                                              green: 32 / 255,
                                              blue: 34 / 255,
                                              alpha: 1)
    }

    func setup() {
        axis = .horizontal
        distribution = .equalCentering

        addArrangedSubviews(moreButton, title, pipButton)

        NSLayoutConstraint.activate([
            moreButton.heightAnchor.constraint(equalToConstant: Appearence.buttonEdge),
            moreButton.widthAnchor.constraint(equalTo: moreButton.heightAnchor),

            pipButton.heightAnchor.constraint(equalToConstant: Appearence.buttonEdge),
            pipButton.widthAnchor.constraint(equalTo: pipButton.heightAnchor),
        ])
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

        init(text: String) {
            super.init(frame: .zero)

            titleLabel.text = text
            setup()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.NavigationBar.Title {

    func set(live: Bool) {
        guard
            isLive != live
        else { return }

        isLive = live
        liveLabelContainer.backgroundColor = live ? Appearence.liveColor : Appearence.pendingColor

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
