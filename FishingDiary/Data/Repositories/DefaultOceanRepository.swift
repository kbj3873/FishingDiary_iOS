//
//  DefaultOceanRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

final class DefaultOceanRepository {
    private let apiDataTransferService: DataTransferService
    private let apiXmlTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    
    init(
        apiDataTransferService: DataTransferService,
        apiXmlTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.apiDataTransferService = apiDataTransferService
        self.apiXmlTransferService = apiXmlTransferService
        self.backgroundQueue = backgroundQueue
    }
}

extension DefaultOceanRepository: OceanRepository {
    
    func fetchRisaList(
        query: RisaListQuery,
        completion: @escaping (Result<RisaResponse, Error>) -> Void
    ) -> Cancellable? {
        
        let requestDTO = RisaListRequestDTO(query: query)
        let task = RepositoryTask()
        
        let endpoint = APIEndpoints.getRisaJson(with: requestDTO) as Endpoint<RisaListResponseDTO>
        task.networkTask = self.apiDataTransferService.request(with: endpoint,
                                                             on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    func fetchStationCode(
        query: RisaCodeQuery,
        completion: @escaping (Result<RisaResponse, Error>) -> Void
    ) -> Cancellable? {
        
        let requestDTO = RisaCodeRequestDTO(query: query)
        let task = RepositoryTask()
        
        let endpoint = APIEndpoints.getRisaJson(with: requestDTO) as Endpoint<RisaCodeResponseDTO>
        task.networkTask = self.apiDataTransferService.request(with: endpoint,
                                                             on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    func fetchRisaCoo(
        query: RisaCooQuery,
        completion: @escaping (Result<RisaResponse, Error>) -> Void
    ) -> Cancellable? {
        
        let requestDTO = RisaCooRequestDTO(query: query)
        let task = RepositoryTask()
        
        let endpoint = APIEndpoints.getRisaJson(with: requestDTO) as Endpoint<CooListResponseDTO>
        task.networkTask = self.apiDataTransferService.request(with: endpoint,
                                                             on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    
    func fetchTemperature(
        query: OceanQuery,
        completion: @escaping (Result<OceanResponse, Error>) -> Void
    ) -> Cancellable? {
        
        let requestDTO = OceanRequestDTO(id: query.id, gruNam: query.gruNam, useYn: query.useYn, staCde: query.staCde, dataCnt: query.dataCnt, ord: query.ord, ordType: query.ordType, obsFrom: query.obsFrom, obsTo: query.obsTo)
        let task = RepositoryTask()
        
        let endpoint = APIEndpoints.getRisaXml(with: requestDTO) as Endpoint<OceanResponseDTO>
        task.networkTask = self.apiXmlTransferService.requestHtml(with: endpoint,
                                                             on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                print("task success")
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
