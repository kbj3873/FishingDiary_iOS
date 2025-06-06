//
//  AppFlowCoordinator.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/06.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

final class AppFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    
    var navigationController: UINavigationController
    
    var appDIContainer = AppDIContainer.shared
    private let dataServiceDIContainer: DataServiceDIContainer
    // MARK: - Persistent Storage
    lazy var fileStorage: FileDataStorage = FileDataStorage()
    
    init(navigationController: UINavigationController,
         dataServiceDIContainer: DataServiceDIContainer,
         childCoordinators: [Coordinator]? = nil) {
        self.navigationController = navigationController
        self.dataServiceDIContainer = dataServiceDIContainer
        self.childCoordinators = childCoordinators ?? [Coordinator]()
    }
    
    func start() {
        let pointSceneDIContainer = dataServiceDIContainer.makeOceanSceneDIContainer()
        let flow = pointSceneDIContainer.makePointFlowCoordinator(navigationController: navigationController)
        flow.start()
        
        childCoordinators = [flow]
        appDIContainer.register(flow)
    }
}
