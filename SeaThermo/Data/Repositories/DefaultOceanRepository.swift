//
//  DefaultOceanRepository.swift
//  SeaThermo
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
        
        // 1. 신규 API 스펙에 맞는 RequestDTO 변환
        let requestDTO = query.toOceanInfoRequestDTO()
        let task = RepositoryTask()
        
        // 2. 신규 JSON 엔드포인트 생성
        let endpoint = APIEndpoints.searchRisaInfoList(with: requestDTO) as Endpoint<OceanInfoResponseDTO>
        
        // 3. 기존 XML 대신 JSON 전용 apiDataTransferService 사용
        task.networkTask = self.apiDataTransferService.request(with: endpoint,
                                                             on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                print("OceanInfo API task success")
                // DTO -> Domain Entity 반환
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
