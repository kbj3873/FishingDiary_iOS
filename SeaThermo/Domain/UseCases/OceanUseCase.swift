//
//  OceanUseCase.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

protocol OceanUseCase {
    func fetchRisaList(_ query: CurrentTemperatureQuery) async throws -> [CurrentTemperature]
    func fetchTemperature(_ query: SeaAnalysisQuery) async throws -> [WeeklyTemperature]
}

final class DefaultOceanUseCase: OceanUseCase {
    private let oceanRepository: OceanRepository
    
    init(oceanRepository: OceanRepository) {
        self.oceanRepository = oceanRepository
    }
    
    func fetchRisaList(_ query: CurrentTemperatureQuery) async throws -> [CurrentTemperature] {
        try await oceanRepository.fetchRisaList(query)
    }
    
    func fetchTemperature(_ query: SeaAnalysisQuery) async throws -> [WeeklyTemperature] {
        try await oceanRepository.fetchTemperature(query)
    }
}
