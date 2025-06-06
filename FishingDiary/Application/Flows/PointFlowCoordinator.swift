//
//  PointFlowCoordinator.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/11/30.
//

import Foundation
import UIKit

protocol PointFlowCoordinatorDependencies {
    func makeMainViewController(actions: MainViewModelActions) -> MainViewController
    func makeOceanSelectViewController() -> OceanSelectViewController
    func makeTemperatureViewController() -> SeaWaterTemperatureViewController
    func makeTrackMapViewController() -> TrackMapViewController
    func makeKakaoTrackMapViewController() -> KakaoTrackMapViewController
    func makePointDateListViewController(actions: PointDateListViewModelActions) -> PointDateListViewController
    func makePointDataListViewController(pointDate: PointDate, actions: PointDataListViewModelActions) -> PointDataListViewController
    func makePointMapViewController(pointData: PointData) -> PointMapViewController
    func makeKakaoPointMapViewController(pointData: PointData) -> KakaoPointMapViewController
}

final class PointFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    
    private weak var navigationController: UINavigationController?
    private var dependencies: PointFlowCoordinatorDependencies
    
    //private weak var mainVC: MainViewController?
    
    init(navigationController: UINavigationController,
         childCoordinators: [Coordinator]? = nil,
         dependencies: PointFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators ?? [Coordinator]()
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = MainViewModelActions(showOceanSelectedView: showOceanSeleted,
                                           showTrackMapView: showTrackMap,
                                           showPointList: showPointDateList,
                                           showTemperature: showTemperature)
        let vc = dependencies.makeMainViewController(actions: actions)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func showOceanSeleted() {
        let vc = dependencies.makeOceanSelectViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showTemperature() {
        let vc = dependencies.makeTemperatureViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showTrackMap() {
        if FDAppManager.shared.mapTp == .KakaoMap {
            let vc = dependencies.makeKakaoTrackMapViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        
        else {
            let vc = dependencies.makeTrackMapViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showPointDateList() {
        let actions = PointDateListViewModelActions(showPointDataList: showPointDataList)
        let vc = dependencies.makePointDateListViewController(actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showPointDataList(pointDate: PointDate) {
        let actions = PointDataListViewModelActions(showPointMap: showPointMap)
        let vc = dependencies.makePointDataListViewController(pointDate: pointDate, actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showPointMap(pointData: PointData) {
        if FDAppManager.shared.mapTp == .KakaoMap {
            let vc = dependencies.makeKakaoPointMapViewController(pointData: pointData)
            navigationController?.pushViewController(vc, animated: true)
        }

        else {
            let vc = dependencies.makePointMapViewController(pointData: pointData)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showKakaoPointMap(pointData: PointData) {
        let vc = dependencies.makeKakaoPointMapViewController(pointData: pointData)
        navigationController?.pushViewController(vc, animated: true)
    }
}
