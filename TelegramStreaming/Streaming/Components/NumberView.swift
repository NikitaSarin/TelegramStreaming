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

    private let stackView = UIStackView {
        $0.axis = .horizontal
        $0.distribution = .equalCentering
        $0.spacing = 0
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
        stackView.bounds.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}

private extension NumberView {

    func setup() {
        layer.addSublayer(gradient)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)

        updateMask()
    }

    func move(from: Int?, to: Int?) {
        if let value = to {
            let text = formatter.string(from: value as NSNumber)
            UIView.animate(withDuration: 0.7) { [self] in
                label.alpha = 0
                label.text = text
                label.alpha = 1
            }
        } else {
            label.text = nil
        }
        updateMask()
    }

    func updateMask() {
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
        stackView.frame = CGRect(origin: .zero, size: stackView.bounds.size)

        invalidateIntrinsicContentSize()
        mask = stackView
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
