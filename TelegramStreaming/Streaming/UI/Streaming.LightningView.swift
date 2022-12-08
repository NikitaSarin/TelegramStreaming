//
//  Streaming.LightningView.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 04.12.2022.
//

import UIKit

extension Streaming {

    final class LightningView: UIView {

        var blurRadius: Int = 45 {
            didSet {
                if let image = lastImage, blurRadius != oldValue {
                    DispatchQueue.global(qos: .userInteractive).async {
                        self.process(frame: image)
                    }
                }
            }
        }
        var blurAlpha: CGFloat = 0.5 {
            didSet {
                imageView.alpha = blurAlpha
            }
        }

        private var lastImage: CIImage?

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
        lastImage = frame
        let image = applyBlur(to: frame, radius: blurRadius)
        DispatchQueue.main.async {
            self.imageView.image = image
            if self.imageView.alpha == 0 {
                UIView.animate(withDuration: 0.5) { [self] in
                    self.imageView.alpha = blurAlpha
                }
            }
        }
    }

    func applyBlur(to inputImage: CIImage, radius: Int) -> UIImage? {
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
