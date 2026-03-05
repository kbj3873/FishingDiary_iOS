//
//  PointFlowCoordinator.swift
//  SeaThermo
//
//  Created by Y0000591 on 2023/11/30.
//

import Foundation
import UIKit

protocol PointFlowCoordinatorDependencies {
    func makeMainHostingViewController() -> MainHostingViewController
}

final class PointFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    
    private weak var navigationController: UINavigationController?
    private var dependencies: PointFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         childCoordinators: [Coordinator]? = nil,
         dependencies: PointFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators ?? [Coordinator]()
        self.dependencies = dependencies
    }
    
    func startSwiftUI() {
        let vc = dependencies.makeMainHostingViewController()
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.pushViewController(vc, animated: false)
    }
}
