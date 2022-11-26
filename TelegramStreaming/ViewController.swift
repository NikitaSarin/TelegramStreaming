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
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open", for: .normal)
        button.addTarget(self, action: #selector(openPageSheet), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        view.backgroundColor = .darkGray
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openPageSheet()
    }
    
    @objc func openPageSheet() {
        Streaming.present()
    }
}

extension UIImage {
    convenience init?(bundleImageName: String) {
        let name = bundleImageName.split(separator: "/").last ?? ""
        self.init(named: String(name))
    }
}
