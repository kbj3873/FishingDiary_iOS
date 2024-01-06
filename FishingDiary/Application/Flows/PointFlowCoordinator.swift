//
//  PointFlowCoordinator.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/11/30.
//

import Foundation

protocol PointFlowCoordinatorDependencies {
    func makeMainViewController(actions: MainViewModelActions) -> MainViewController
    func makeTrackMapViewController() -> TrackMapViewController
    func makePointDateListViewController(actions: PointDateListViewModelActions) -> PointDateListViewController
    func makePointDataListViewController(pointDate: PointDate, actions: PointDataListViewModelActions) -> PointDataListViewController
    func makePointMapViewController(pointData: PointData) -> PointMapViewController
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
        let actions = MainViewModelActions(showTrackMapView: showTrackMap,
                                           showPointList: showPointDateList)
        let vc = dependencies.makeMainViewController(actions: actions)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func showTrackMap() {
        let vc = dependencies.makeTrackMapViewController()
        navigationController?.pushViewController(vc, animated: true)
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
        let vc = dependencies.makePointMapViewController(pointData: pointData)
        navigationController?.pushViewController(vc, animated: true)
    }
}
