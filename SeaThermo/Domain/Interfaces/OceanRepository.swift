//
//  OceanRepository.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

protocol OceanRepository {
    func fetchRisaList(query: RisaListQuery) async throws -> RisaResponse
    func fetchStationCode(query: RisaCodeQuery) async throws -> RisaResponse
    func fetchRisaCoo(query: RisaCooQuery) async throws -> RisaResponse
    func fetchTemperature(query: OceanQuery) async throws -> OceanResponse
}
