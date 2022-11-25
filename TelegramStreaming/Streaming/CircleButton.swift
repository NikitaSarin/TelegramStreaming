//
//  CircleButton.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

typealias VoidClosure = () -> Void

final class CircleButton: UIControl {

    private let imageView = UIImageView {
        $0.contentMode = .scaleAspectFit
    }

    private let imageContainer = UIView {
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 28
        $0.clipsToBounds = true
    }
    private let label = UILabel {
        $0.isUserInteractionEnabled = false
        $0.font = UIFont.systemRoundedFont(ofSize: 13, weight: .medium)
        $0.textColor = .white
    }

    private let imageInset: CGFloat
    private let action: VoidClosure?

    init(
        title: String,
        background: UIColor,
        imageName: String,
        imageInset: CGFloat = 8,
        action: VoidClosure?
    ) {
        self.imageInset = imageInset
        self.action = action
        super.init(frame: .zero)

        imageView.image = UIImage(bundleImageName: imageName)
        imageContainer.backgroundColor = background
        label.text = title

        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension CircleButton {

    func setup() {
        addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(didTouchUp), for: .touchUpInside)
        addTarget(self, action: #selector(didTouchUp), for: .touchUpOutside)
        addTarget(self, action: #selector(didTouchUp), for: .touchCancel)

        [imageContainer, imageView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        imageContainer.addSubview(imageView)
        addSubview(imageContainer)
        addSubview(label)

        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageContainer.widthAnchor.constraint(equalToConstant: 56),
            imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor),

            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor,
                                           constant: imageInset),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor,
                                               constant: imageInset),
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),

            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 14),
            label.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc func didTouchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [self] in
            transform = .identity
        }
    }

    @objc func didTouchUpInside() {
        action?()
    }

    @objc func didTouchDown() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [self] in
            transform = .identity.scaledBy(x: 0.9, y: 0.9)
        }
    }
}
