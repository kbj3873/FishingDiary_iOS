//
//  ApplicationDIContainer.swift
//  SeaThermo
//
//  Created by Y0000591 on 2023/11/30.
//

import Foundation
import UIKit
import Combine

final class ApplicationDIContainer: ObservableObject {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - network
    lazy var apiDataTransferService: NetworkService = {
        return DefaultNetworkService(baseURL: appConfiguration.apiNifsURL)
    }()
    
    // 온바다 자체 서버용 JSON API 서비스 (앱/디바이스 정보 헤더 포함)
    lazy var seaThermoTransferService: NetworkService = {
        return DefaultNetworkService(baseURL: appConfiguration.apiOnbadaURL)
    }()
    
    init() { }
}

// MARK: make view model
extension ApplicationDIContainer {
    @MainActor func makeCurrentTemperatureViewModel() -> CurrentTemperatureViewModel {
        CurrentTemperatureViewModel(appConfiguration: appConfiguration,
                                    oceanUseCase: makeOceanUseCase())
    }

    @MainActor func makeCrawlingCurrentTemperatureViewModel() -> CrawlingCurrentTemperatureViewModel {
        CrawlingCurrentTemperatureViewModel(oceanUseCase: makeOceanUseCase())
    }
    
    @MainActor func makeOceanSelectViewModel() -> OceanSelectViewModel {
        OceanSelectViewModel(appConfiguration: appConfiguration,
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

// MARK: - make use case
extension ApplicationDIContainer {
    
    func makeOceanUseCase() -> OceanUseCase {
        DefaultOceanUseCase(oceanRepository: makeOceanRepository())
    }
    
    func makeSplashUseCase() -> SplashUseCase {
        DefaultSplashUseCase(repository: makeSplashRepository())
    }
    
    func makeFishingRecordUseCase() -> FishingRecordUseCase {
        DefaultFishingRecordUseCase(repository: makeFishingRecordRepository())
    }
}

// MARK: - make data repository
extension ApplicationDIContainer {
    func makeOceanRepository() -> OceanRepository {
        DefaultOceanRepository(apiNetworkService: apiDataTransferService)
    }
    
    func makeSplashRepository() -> SplashRepository {
        DefaultSplashRepository(apiNetworkService: seaThermoTransferService)
    }
    
    func makeFishingRecordRepository() -> FishingRecordRepository {
        DefaultFishingRecordRepository()
    }
}
