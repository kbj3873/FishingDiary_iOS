//
//  AppFlowCoordinator.swift
//  SeaThermo
//
//  Created by Y0000591 on 2023/12/06.
//

import Foundation
import UIKit
import SwiftUI

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    func start()
    func startSwiftUI()
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
    
    func startSwiftUI() {
        let pointSceneDIContainer = dataServiceDIContainer.makeOceanSceneDIContainer()
        appDIContainer.register(pointSceneDIContainer)
        
        // 스플래시 화면을 먼저 표시
        let splashViewModel = pointSceneDIContainer.makeSplashViewModel()
        let splashView = SplashView(viewModel: splashViewModel) { [weak self] in
            guard let self else { return }
            // 스플래시 완료 → 메인 화면으로 전환
            self.showMainScreen(pointSceneDIContainer: pointSceneDIContainer)
        }
        
        let splashVC = UIHostingController(rootView: splashView)
        splashVC.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([splashVC], animated: false)
    }
    
    private func showMainScreen(pointSceneDIContainer: PointSceneDIContainer) {
        let flow = pointSceneDIContainer.makePointFlowCoordinator(navigationController: navigationController)
        flow.startSwiftUI()
        childCoordinators = [flow]
    }
}

