//
//  PointSceneDIContainer.swift
//  SeaThermo
//
//  Created by Y0000591 on 2023/11/30.
//

import Foundation
import UIKit
import Combine

final class PointSceneDIContainer: ObservableObject {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let apiXmlTransferService: DataTransferService
        let seaThermoTransferService: DataTransferService
        let appConfiguration: AppConfiguration
    }
    
    private let dependencies: Dependencies
    private let fileStorage: FileDataStorage
    
    init(dependencies: Dependencies, fileStorage: FileDataStorage) {
        self.dependencies = dependencies
        self.fileStorage = fileStorage
    }
}

// MARK: make view model
extension PointSceneDIContainer {
    @MainActor func makeCurrentTemperatureViewModel() -> CurrentTemperatureViewModel {
        CurrentTemperatureViewModel(appConfiguration: dependencies.appConfiguration,
                                    oceanUseCase: makeOceanUseCase())
    }
    
    @MainActor func makeOceanSelectViewModel() -> OceanSelectViewModel {
        OceanSelectViewModel(appConfiguration: dependencies.appConfiguration,
                             oceanUseCase: makeOceanUseCase())
    }
    
    func makeSeaAnalysisViewModel() -> SeaAnalysisViewModel {
        SeaAnalysisViewModel(oceanUseCase: makeOceanUseCase())
    }
    
    func makeSeaAnalysisDetailViewModel(station: ObservatoryInfo) -> SeaAnalysisDetailViewModel {
        SeaAnalysisDetailViewModel(oceanUseCase: makeOceanUseCase(), station: station)
    }
    
    func makeSettingViewModel() -> SettingViewModel {
        SettingViewModel(appManager: .shared)
    }
    
    func makeFishingRecordViewModel() -> FishingRecordViewModel {
        FishingRecordViewModel(useCase: makeFishingRecordUseCase())
    }
    
    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel(splashUseCase: makeSplashUseCase())
    }
}

// MARK: make use case
extension PointSceneDIContainer {
    
    func makeOceanUseCase() -> OceanUseCase {
        OceanUseCase(oceanRepository: makeOceanRepository())
    }
    
    func makeSplashUseCase() -> SplashUseCase {
        SplashUseCase(repository: makeSplashRepository())
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
    
    func makeFishingRecordUseCase() -> FishingRecordUseCase {
        DefaultFishingRecordUseCase(repository: makeFishingRecordRepository())
    }
}

// MARK: make data repository
extension PointSceneDIContainer {
    func makeOceanRepository() -> OceanRepository {
        DefaultOceanRepository(apiDataTransferService: dependencies.apiDataTransferService,
                               apiXmlTransferService: dependencies.apiXmlTransferService)
    }
    
    func makeSplashRepository() -> SplashRepository {
        DefaultSplashRepository(dataTransferService: dependencies.seaThermoTransferService)
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
    
    func makeFishingRecordRepository() -> FishingRecordRepository {
        DefaultFishingRecordRepository()
    }
}
