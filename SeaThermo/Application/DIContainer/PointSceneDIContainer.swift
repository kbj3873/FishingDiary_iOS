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
        let seaThermoTransferService: DataTransferService
        let appConfiguration: AppConfiguration
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
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
    
    @MainActor func makeSeaAnalysisViewModel() -> SeaAnalysisViewModel {
        SeaAnalysisViewModel(oceanUseCase: makeOceanUseCase())
    }
    
    @MainActor func makeSeaAnalysisDetailViewModel(station: ObservatoryInfo) -> SeaAnalysisDetailViewModel {
        SeaAnalysisDetailViewModel(oceanUseCase: makeOceanUseCase(), station: station)
    }
    
    func makeSettingViewModel() -> SettingViewModel {
        SettingViewModel(appManager: .shared)
    }
    
    @MainActor func makeFishingRecordViewModel() -> FishingRecordViewModel {
        FishingRecordViewModel(useCase: makeFishingRecordUseCase())
    }
    
    @MainActor func makeSplashViewModel() -> SplashViewModel {
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
    
    func makeFishingRecordUseCase() -> FishingRecordUseCase {
        DefaultFishingRecordUseCase(repository: makeFishingRecordRepository())
    }
}

// MARK: make data repository
extension PointSceneDIContainer {
    func makeOceanRepository() -> OceanRepository {
        DefaultOceanRepository(apiDataTransferService: dependencies.apiDataTransferService)
    }
    
    func makeSplashRepository() -> SplashRepository {
        DefaultSplashRepository(dataTransferService: dependencies.seaThermoTransferService)
    }
    
    func makeFishingRecordRepository() -> FishingRecordRepository {
        DefaultFishingRecordRepository()
    }
}
