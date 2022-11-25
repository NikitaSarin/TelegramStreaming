//
//  Streaming.ButtonPanel.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 25.11.2022.
//

import UIKit

extension UIStackView {

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

    func setup() {
        axis = .horizontal
        distribution = .equalCentering
        spacing = 60

        let redColor = UIColor(red: 80 / 255,
                               green: 41 / 255,
                               blue: 50 / 255,
                               alpha: 1)
        let blueColor = UIColor(red: 42 / 255,
                                green: 44 / 255,
                                blue: 91 / 255,
                                alpha: 1)

        addArrangedSubviews(
            CircleButton(
                title: "share",
                background: blueColor,
                imageName: ""
            ) { [weak self] in
                self?.delegate?.shareButtonTapped()
            },
            CircleButton(
                title: "expand",
                background: blueColor,
                imageName: ""
            ) { [weak self] in
                self?.delegate?.expandButtonTapped()
            },
            CircleButton(
                title: "leave",
                background: redColor,
                imageName: ""
            ) { [weak self] in
                self?.delegate?.leaveButtonTapped()
            }
        )
    }

}
