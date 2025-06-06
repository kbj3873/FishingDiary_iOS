//
//  NetworkDIContainer.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/08.
//

import Foundation

final class DataServiceDIContainer {
    lazy var appConfiguration = AppConfiguration()
    // MARK: - Persistent Storage
    lazy var fileStorage: FileDataStorage = FileDataStorage()
    
    // MARK: - network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: appConfiguration.apiBaseURL)!,
            headers: [
                "Accept-Language":"ko-KR,ko;q=0.9",
                "Content-Type":"application/json;utf-8"
            ]
        )
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var apiXmlTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: appConfiguration.apiBaseURL)!,
            headers: [
                "Accept-Language":"ko-KR,ko;q=0.9",
                "Content-Type":"application/x-www-form-urlencoded"
            ]
        )
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    // MARK: - DIContainers of scenes
    func makeOceanSceneDIContainer() -> PointSceneDIContainer {
        let dependencies = PointSceneDIContainer.Dependencies(apiDataTransferService: apiDataTransferService,
                                                              apiXmlTransferService: apiXmlTransferService,
                                                              appConfiguration: appConfiguration)
        return PointSceneDIContainer(dependencies: dependencies, fileStorage: fileStorage)
    }
}
