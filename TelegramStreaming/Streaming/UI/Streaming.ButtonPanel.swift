//
//  Streaming.ButtonPanel.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

extension UIStackView {

    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach {
            addArrangedSubview($0)
        }
    }

    func addArrangedSubviews(_ subviews: UIView...) {
        subviews.forEach {
            addArrangedSubview($0)
        }
    }
}

protocol StreamingButtonPanelDelegate: AnyObject {
    func shareButtonTapped()
    func expandButtonTapped()
    func leaveButtonTapped()
}

extension Streaming {

    final class ButtonPanel: UIStackView {

        private weak var delegate: StreamingButtonPanelDelegate?

        init(delegate: StreamingButtonPanelDelegate) {
            self.delegate = delegate
            super.init(frame: .zero)

            setup()
        }

        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private extension Streaming.ButtonPanel {

    enum Appereance {
        static let shareColor = UIColor(red: 49 / 255,
                                        green: 42 / 255,
                                        blue: 78 / 255,
                                        alpha: 1)
        static let expandColor = UIColor(red: 66 / 255,
                                        green: 41 / 255,
                                        blue: 72 / 255,
                                        alpha: 1)
        static let leaveColor = UIColor(red: 91 / 255,
                                        green: 47 / 255,
                                        blue: 57 / 255,
                                        alpha: 1)
    }

    func setup() {
        axis = .horizontal
        distribution = .equalCentering
        spacing = 60

        addArrangedSubviews(
            CircleButton(
                title: "share",
                background: Appereance.shareColor,
                imageName: "Call/CallShareButton",
                imageInset: 0
            ) { [weak self] in
                self?.delegate?.shareButtonTapped()
            },
            CircleButton(
                title: "expand",
                background: Appereance.expandColor,
                imageName: "Call/CallExpandButton",
                imageInset: 0
            ) { [weak self] in
                self?.delegate?.expandButtonTapped()
            },
            CircleButton(
                title: "leave",
                background: Appereance.leaveColor,
                imageName: "Call/CallCancelButton",
                imageInset: 17
            ) { [weak self] in
                self?.delegate?.leaveButtonTapped()
            }
        )
    }

}
