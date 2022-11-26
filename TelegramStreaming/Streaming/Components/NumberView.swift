//
//  NumberView.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

final class GradientNumberView: UIView {

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


    var value: Int? {
        get { sizeNumberView.value }
        set {
            sizeNumberView.value = newValue
            maskNumberView.value = newValue
        }
    }

    private let sizeNumberView = NumberView()
    private let maskNumberView = NumberView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        sizeNumberView.alpha = 0
        sizeNumberView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sizeNumberView)

        NSLayoutConstraint.activate([
            sizeNumberView.topAnchor.constraint(equalTo: topAnchor),
            sizeNumberView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sizeNumberView.centerXAnchor.constraint(equalTo: centerXAnchor),
            sizeNumberView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        layer.addSublayer(gradient)

        mask = maskNumberView
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()

        maskNumberView.frame = bounds
        gradient.frame = bounds
    }
}

final class NumberView: UIStackView {

    var font: UIFont = .systemRoundedFont(ofSize: 44, weight: .semibold) {
        didSet {
            labels.forEach { $0.font = font }
        }
    }

    var value: Int? {
        didSet {
            if oldValue != value {
                move(from: oldValue, to: value)
            }
        }
    }

    private var labels = [AnimatedLabel]()

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension NumberView {

    func setup() {
        axis = .horizontal
        distribution = .equalSpacing
        alignment = .bottom
        spacing = 0
    }

    func move(from: Int?, to: Int?) {
        if let value = to {
            let text = formatter.string(from: value as NSNumber) ?? ""
            let diff = text.count - labels.count
            if diff > 0 {
                (0..<diff).forEach { _ in
                    let label = AnimatedLabel {
                        $0.font = font
                        $0.layoutMargins = .zero
                    }
                    addArrangedSubview(label)
                    labels.append(label)
                }
            } else if diff < 0 {
                labels[labels.count-abs(diff)..<labels.count].forEach { $0.removeFromSuperview() }
                labels = labels.dropLast(abs(diff))
            }
            var delay = 0.0
            for (label, symbol) in zip(labels, text).reversed() {
                if label.text != String(symbol) {
                    label.set(text: String(symbol), delay: delay)
                    delay += 0.1
                }
            }
        } else {
            labels.forEach { $0.removeFromSuperview() }
            labels.removeAll()
        }

        UIView.animate(withDuration: 0.2) { [self] in
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}

private final class AnimatedLabel: UILabel {

    let duration: Double = 0.4

    func set(text: String, delay: CGFloat = 0) {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [self] in
                set(text: text)
            }
            return
        }

        let inLabel = UILabel()
        inLabel.text = text
        inLabel.font = font
        inLabel.textColor = textColor
        inLabel.alpha = 0

        inLabel.translatesAutoresizingMaskIntoConstraints = false
        inLabel.frame = bounds
        addSubview(inLabel)

        let outLabel = UILabel()
        outLabel.text = self.text
        outLabel.font = font
        outLabel.textColor = textColor

        outLabel.translatesAutoresizingMaskIntoConstraints = false
        outLabel.frame = bounds
        addSubview(outLabel)

        let inTransform: CATransform3D = .identity
            .translate(0, bounds.height / 2, 0)
            .scale(0.001, 0.001, 1)
        let inAnimation = CABasicAnimation(keyPath: "transform")
        inAnimation.duration = duration
        inAnimation.fromValue = NSValue(caTransform3D: inTransform)
        inAnimation.toValue = NSValue(caTransform3D: .identity)
        inAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        inAnimation.isRemovedOnCompletion = false
        inLabel.layer.add(inAnimation, forKey: nil)

        let outTransform: CATransform3D = .identity
            .translate(0, -bounds.height / 2, 0)
            .scale(0.001, 0.001, 1)
        let outAnimation = CABasicAnimation(keyPath: "transform")
        outAnimation.duration = duration
        outAnimation.fromValue = NSValue(caTransform3D: .identity)
        outAnimation.toValue = NSValue(caTransform3D: outTransform)
        outAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        outAnimation.isRemovedOnCompletion = false
        outLabel.layer.add(outAnimation, forKey: nil)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            animations: { [self] in
                self.text = text
                self.textColor = .clear
                inLabel.alpha = 1
                outLabel.alpha = 0
            },
            completion: { [self] _ in
                inLabel.removeFromSuperview()
                outLabel.removeFromSuperview()
                textColor = outLabel.textColor
            }
        )
    }
}

extension CATransform3D {

    static var identity: CATransform3D { CATransform3DIdentity }

    func scale(_ sx: CGFloat, _ sy: CGFloat, _ sz: CGFloat) -> CATransform3D {
        CATransform3DScale(self, sx, sy, sz)
    }

    func translate(_ tx: CGFloat, _ ty: CGFloat, _ tz: CGFloat) -> CATransform3D {
        CATransform3DTranslate(self, tx, ty, tz)
    }
}

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
