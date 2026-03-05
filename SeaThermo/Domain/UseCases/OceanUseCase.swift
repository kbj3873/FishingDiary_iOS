//
//  OceanUseCase.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

protocol OceanUseCaseProtocol {
    func fetchRisaList(query: RisaListQuery) async throws -> RisaResponse
    func fetchStationCode(query: RisaCodeQuery) async throws -> RisaResponse
    func fetchRisaCoo(query: RisaCooQuery) async throws -> RisaResponse
    func fetchTemperature(query: OceanQuery) async throws -> OceanResponse
}

final class OceanUseCase: OceanUseCaseProtocol {
    private let oceanRepository: OceanRepository
    
    init(oceanRepository: OceanRepository) {
        self.oceanRepository = oceanRepository
    }
    
    func fetchRisaList(query: RisaListQuery) async throws -> RisaResponse {
        try await oceanRepository.fetchRisaList(query: query)
    }
    
    func fetchStationCode(query: RisaCodeQuery) async throws -> RisaResponse {
        try await oceanRepository.fetchStationCode(query: query)
    }
    
    func fetchRisaCoo(query: RisaCooQuery) async throws -> RisaResponse {
        try await oceanRepository.fetchRisaCoo(query: query)
    }
    
    func fetchTemperature(query: OceanQuery) async throws -> OceanResponse {
        try await oceanRepository.fetchTemperature(query: query)
    }
}
