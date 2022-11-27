//
//  ViewController.swift
//  TelegramStreaming
//
//  Created by Nikita Sarin on 24.11.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray

        let portraitButton = UIButton()
        portraitButton.setTitle("Portrait", for: .normal)
        portraitButton.addTarget(self, action: #selector(openPortrait), for: .touchUpInside)

        let landscapeButton = UIButton()
        landscapeButton.setTitle("Landscape", for: .normal)
        landscapeButton.addTarget(self, action: #selector(openLandscape), for: .touchUpInside)

        [portraitButton, landscapeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            portraitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portraitButton.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 100),

            landscapeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            landscapeButton.topAnchor.constraint(equalTo: portraitButton.bottomAnchor, constant: 10)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openLandscape()
    }
    
    @objc func openPortrait() {
        Streaming.present(ratio: 9 / 16)
    }

    @objc func openLandscape() {
        Streaming.present(ratio: 16 / 9)
    }
}

extension UIImage {
    convenience init?(bundleImageName: String) {
        let name = bundleImageName.split(separator: "/").last ?? ""
        self.init(named: String(name))
    }
}
