//
//  OceanRepository.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

protocol OceanRepository {
    func fetchRisaList(_ query: CurrentTemperatureQuery) async throws -> [CurrentTemperature]
    func fetchTemperature(_ query: SeaAnalysisQuery) async throws -> [WeeklyTemperature]
}
