//
//  Streaming.LightningView.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 04.12.2022.
//

import UIKit

extension Streaming {

    final class LightningView: UIView {

        var radius: CGFloat = 45

        private let provider: StreamingProvider
        private let context: CIContext = {
            if let device = MTLCreateSystemDefaultDevice() {
                return CIContext(mtlDevice: device)
            } else {
                return CIContext()
            }
        }()

        private let imageView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleToFill
            view.alpha = 0
            return view
        }()

        init(provider: StreamingProvider) {
            self.provider = provider
            super.init(frame: .zero)

            setup()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

extension Streaming.LightningView {

    func loadVideoIfNeeded() {
        provider.setOnReceiveFrame { [weak self] frame in
            DispatchQueue.global(qos: .userInitiated).async {
                self?.process(frame: frame)
            }
        }
    }

    func setVideoVisible(_ visible: Bool) {
        UIView.animate(withDuration: visible ? 1.0 : 0.3) { [self] in
            alpha = visible ? 1 : 0
        }
    }
}

private extension Streaming.LightningView {

    func process(frame: CIImage) {
        let image = applyBlur(to: frame, radius: radius)
        DispatchQueue.main.async {
            self.imageView.image = image
            if self.imageView.alpha == 0 {
                UIView.animate(withDuration: 0.5) { [self] in
                    self.imageView.alpha = 0.5
                }
            }
        }
    }

    func applyBlur(to inputImage: CIImage, radius: CGFloat) -> UIImage? {
        guard
            let filter = CIFilter(name: "CIGaussianBlur")
        else { return nil }

        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: "inputRadius")

        guard
            let output = filter.outputImage,
            let final = context.createCGImage(output, from: output.extent)
        else { return nil }

        return UIImage(cgImage: final)
    }

    func setup() {
        clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
