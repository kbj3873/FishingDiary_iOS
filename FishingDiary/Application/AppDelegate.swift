//
//  AppDelegate.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let dataServiceDIContainer = DataServiceDIContainer()
    var appFlowCoordinator: AppFlowCoordinator?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FDAppManager.shared.appInitialize()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        
        window?.rootViewController = navigationController
        
        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController, dataServiceDIContainer: dataServiceDIContainer)
        appFlowCoordinator?.start()
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

