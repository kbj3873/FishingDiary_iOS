//
//  PointSceneDIContainer.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/11/30.
//

import Foundation
import UIKit

final class PointSceneDIContainer {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let apiXmlTransferService: DataTransferService
        let appConfiguration: AppConfiguration
    }
    
    private let dependencies: Dependencies
    private let fileStorage: FileDataStorage
    
    init(dependencies: Dependencies, fileStorage: FileDataStorage) {
        self.dependencies = dependencies
        self.fileStorage = fileStorage
    }
    
    func makePointFlowCoordinator(navigationController: UINavigationController) -> PointFlowCoordinator {
        PointFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

// MARK: make scene
extension PointSceneDIContainer: PointFlowCoordinatorDependencies {
    func makeMainViewController(actions: MainViewModelActions) -> MainViewController {
        MainViewController.create(with: makeMainViewModel(actions: actions))
    }
    
    func makeOceanSelectViewController() -> OceanSelectViewController {
        OceanSelectViewController.create(with: makeOceanSelectViewModel())
    }
    
    func makeTemperatureViewController() -> SeaWaterTemperatureViewController {
        SeaWaterTemperatureViewController.create(with: makeTemperatureViewModel())
    }
    
    func makeTrackMapViewController() -> TrackMapViewController {
        TrackMapViewController.create(with: makeTrackMapViewModel())
    }
    
    func makeKakaoTrackMapViewController() -> KakaoTrackMapViewController {
        KakaoTrackMapViewController.create(with: makeKakaoTrackMapViewModel())
    }
    
    func makePointDateListViewController(actions: PointDateListViewModelActions) -> PointDateListViewController {
        PointDateListViewController.create(with:
                                            makePointDateListViewModel(actions: actions))
    }
    
    func makePointDataListViewController(pointDate: PointDate, actions: PointDataListViewModelActions) -> PointDataListViewController {
        PointDataListViewController.create(with:
                                            makePointDataListViewModel(pointDate: pointDate, actions: actions))
    }
    
    func makePointMapViewController(pointData: PointData) -> PointMapViewController {
        PointMapViewController.create(with: makePointMapViewModel(pointData: pointData))
    }
    
    func makeKakaoPointMapViewController(pointData: PointData) -> KakaoPointMapViewController {
        KakaoPointMapViewController.create(with: makeKakaoPointMapViewModel(pointData: pointData))
    }
}

// MARK: make view model
extension PointSceneDIContainer {
    func makeMainViewModel(actions: MainViewModelActions) -> MainViewModel {
        MainViewModel(actions: actions,
                      appConfiguration: dependencies.appConfiguration,
                      oceanUseCase: makeOceanUseCase())
    }
    
    func makeOceanSelectViewModel() -> OceanSelectViewModel {
        OceanSelectViewModel(appConfiguration: dependencies.appConfiguration,
                             oceanUseCase: makeOceanUseCase())
    }
    
    func makeTemperatureViewModel() -> SeaWaterTemperatureViewModel {
        SeaWaterTemperatureViewModel(oceanUseCase: makeOceanUseCase(),
                                     appConfiguration: dependencies.appConfiguration)
    }
    
    func makeTrackMapViewModel() -> TrackMapViewModel {
        TrackMapViewModel(trackMapUseCase: makeTrackMapUseCase())
    }
    
    func makeKakaoTrackMapViewModel() -> KakaoTrackMapViewModel {
        KakaoTrackMapViewModel(trackMapUseCase: makeTrackMapUseCase())
    }
    
    func makePointDateListViewModel(actions: PointDateListViewModelActions) -> PointDateListViewModel {
        PointDateListViewModel(pointDateUseCase: makePointDateListUseCase(),
                               actions: actions)
    }
    
    func makePointDataListViewModel(pointDate: PointDate, actions: PointDataListViewModelActions) -> PointDataListViewModel {
        PointDataListViewModel(pointDate: pointDate,
                               pointDataUseCase: makePointDataListUseCase(),
                               pointDataListViewModelActions: actions)
    }
    
    func makePointMapViewModel(pointData: PointData) -> PointMapViewModel {
        PointMapViewModel(pointData: pointData,
                          pointMapUseCase: makePointMapUseCase())
    }
    
    func makeKakaoPointMapViewModel(pointData: PointData) -> KakaoPointMapViewModel {
        KakaoPointMapViewModel(pointData: pointData,
                               pointMapUseCase: makePointMapUseCase())
    }
}

// MARK: make use case
extension PointSceneDIContainer {
    
    func makeOceanUseCase() -> OceanUseCase {
        OceanUseCase(oceanRepository: makeOceanRepository())
    }
    
    func makeTrackMapUseCase() -> TrackMapUseCase {
        TrackMapUseCase(trackMapRepository: makeTrackMapRepository())
    }
    
    func makePointDateListUseCase() -> PointDateUseCase {
        PointDateUseCase(pointDatesRepository: makePointDateListRepository())
    }
    
    func makePointDataListUseCase() -> PointDataUseCase {
        PointDataUseCase(pointDataListRepository: makePointDataListRepository())
    }
    
    func makePointMapUseCase() -> PointMapUseCase {
        PointMapUseCase(pointMapRepository: makePointMapRepository())
    }
}

// MARK: make data repository
extension PointSceneDIContainer {
    func makeOceanRepository() -> OceanRepository {
        DefaultOceanRepository(apiDataTransferService: dependencies.apiDataTransferService,
                               apiXmlTransferService: dependencies.apiXmlTransferService)
    }
    
    func makeTrackMapRepository() -> TrackMapRepository {
        DefaultTrackMapRepository(fileStorage: fileStorage)
    }
    
    func makePointDateListRepository() -> PointDateListRepository {
        DefaultPointDateListRepository(fileDataStorage: fileStorage)
    }
    
    func makePointDataListRepository() -> PointDataListRepository {
        DefaultPointDataListRepository(fileStorage: fileStorage)
    }
    
    func makePointMapRepository() -> PointMapRepository {
        DefaultPointMapRepository(fileStorage: fileStorage)
    }
}
