//
//  MainHostingViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/15/25.
//

import UIKit
import SwiftUI

class MainHostingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = MainTabView()
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

    // MARK: - Factory
    static func create() -> MainHostingViewController {
        return MainHostingViewController()
    }

    // MARK: - Legacy support (deprecated)
    @available(*, deprecated, message: "Use create() instead")
    static func create(with viewModel: MainViewModel) -> MainHostingViewController {
        return MainHostingViewController()
    }
}
