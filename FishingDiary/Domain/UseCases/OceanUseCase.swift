//
//  OceanUseCase.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

protocol OceanUseCaseProtocol {
    func excute(
        requestValue: OceanRequestValue,
        completion: @escaping (Result<OceanResponse, Error>) -> Void
    ) -> Cancellable?
}

final class OceanUseCase: OceanUseCaseProtocol {
    private let oceanRepository: OceanRepository
    
    init(oceanRepository: OceanRepository) {
        self.oceanRepository = oceanRepository
    }
    
    func excuteRisaList(
        requestValue: RisaListRequestValue,
        completion: @escaping (Result<RisaResponse, Error>) -> Void
    ) -> Cancellable? {
        
        return oceanRepository.fetchRisaList(
            query: requestValue.query,
            completion: { result in
                completion(result)
            }
        )
    }
    
    func excuteStationCode(
        requestValue: RisaCodeRequestValue,
        completion: @escaping (Result<RisaResponse, Error>) -> Void
    ) -> Cancellable? {
        
        return oceanRepository.fetchStationCode(
            query: requestValue.query,
            completion: { result in
                completion(result)
            }
        )
    }
    
    func excuteRisaCoo(
        requestValue: RisaCooRequestValue,
        completion: @escaping (Result<RisaResponse, Error>) -> Void
    ) -> Cancellable? {
        
        return oceanRepository.fetchRisaCoo(
            query: requestValue.query,
            completion: { result in
                completion(result)
            }
        )
    }
    
    func excute(
        requestValue: OceanRequestValue,
        completion: @escaping (Result<OceanResponse, Error>) -> Void
    ) -> Cancellable? {
        
        return oceanRepository.fetchTemperature(
            query: requestValue.query,
            completion: { result in
                completion(result)
        })
    }
}

struct RisaListRequestValue {
    let query: RisaListQuery
}

struct RisaCodeRequestValue {
    let query: RisaCodeQuery
}

struct RisaCooRequestValue {
    let query: RisaCooQuery
}

struct OceanRequestValue {
    let query: OceanQuery
}
