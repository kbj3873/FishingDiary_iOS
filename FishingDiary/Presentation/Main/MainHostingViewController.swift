//
//  MainHostingViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/15/25.
//

import UIKit
import SwiftUI

class MainHostingViewController: UIViewController {
    private var viewModel: MainViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = MainView(viewModel: self.viewModel)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    // MARK: life cycle
    static func create(with viewModel: MainViewModel) -> MainHostingViewController {
        let view = MainHostingViewController()
        view.viewModel = viewModel
        return view
    }
}
