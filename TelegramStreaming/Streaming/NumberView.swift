//
//  NumberView.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

extension UIFont {
    static func systemRoundedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        guard
            #available(iOS 13.0, *),
            let descriptor = systemFont.fontDescriptor.withDesign(.rounded)
        else { return systemFont }
        return UIFont(descriptor: descriptor, size: size)
    }
}

final class NumberView: UIView {

    var font: UIFont = .systemRoundedFont(ofSize: 44, weight: .semibold) {
        didSet {
            label.font = font
        }
    }

    var value: Int? {
        didSet {
            if oldValue != value {
                move(from: oldValue, to: value)
            }
        }
    }

    private lazy var label = UILabel {
        $0.textColor = .black
        $0.font = font
    }

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    private var gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 40 / 255, green: 90 / 255, blue: 240 / 255, alpha: 1).cgColor,
            UIColor(red: 250 / 255, green: 80 / 255, blue: 150 / 255, alpha: 1).cgColor,
        ]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension NumberView {

    override var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}

private extension NumberView {

    func setup() {
        layer.addSublayer(gradient)

        label.translatesAutoresizingMaskIntoConstraints = false
    }

    func move(from: Int?, to: Int?) {
        if let value = to {
            let text = formatter.string(from: value as NSNumber)
            UIView.transition(
                with: label,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: { [self] in
                    label.text = text
                },
                completion: nil
            )
        } else {
            label.text = nil
        }
        label.frame = CGRect(origin: .zero, size: label.intrinsicContentSize)
        mask = label
    }
}

extension UILabel {

    func set(text: String, animated: Bool) {
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                animations: { [self] in
                    alpha = 0
                },
                completion: { [self] _ in
                    self.text = text
                    let from = CATransform3DScale(CATransform3DIdentity, 0.2, 0.2, 1)
                    let to = CATransform3DIdentity

                    layer.transform = from
                    let transformAanimation = CABasicAnimation(keyPath: "transform")
                    transformAanimation.duration = 0.5
                    transformAanimation.fromValue = NSValue(caTransform3D: from)
                    transformAanimation.toValue = NSValue(caTransform3D: to)
                    transformAanimation.fillMode = .forwards
                    transformAanimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    layer.transform = to
                    layer.add(transformAanimation, forKey: "transform")

                    UIView.animate(withDuration: 0.1) { [self] in
                        alpha = 1
                    }
                }
            )

        } else {
            self.text = text
        }
    }
}
