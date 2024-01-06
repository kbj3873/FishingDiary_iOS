//
//  AppFlowCoordinator.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/06.
//

import Foundation

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

final class AppFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    
    var navigationController: UINavigationController
    
    var appDIContainer = AppDIContainer.shared
    
    init(navigationController: UINavigationController,
         childCoordinators: [Coordinator]? = nil) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators ?? [Coordinator]()
    }
    
    func start() {
        let pointSceneDIContainer = PointSceneDIContainer()
        let flow = pointSceneDIContainer.makePointFlowCoordinator(navigationController: navigationController)
        flow.start()
        
        childCoordinators = [flow]
        appDIContainer.register(flow)
    }
}
