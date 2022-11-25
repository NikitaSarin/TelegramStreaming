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
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func openPageSheet() {
        let viewModel = Streaming.ViewModel()
        let viewAssembly = Streaming.ViewAssembly()
        let viewController = Streaming.ViewController(viewModel: viewModel,
                                                      viewAssembly: viewAssembly)

        viewModel.view = viewController

        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true)
    }
    
}
