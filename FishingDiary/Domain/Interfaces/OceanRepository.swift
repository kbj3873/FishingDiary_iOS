//
//  OceanRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

protocol OceanRepository {
    func fetchRisaList(query: RisaListQuery, completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable?
    func fetchStationCode(query: RisaCodeQuery, completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable?
    func fetchRisaCoo(query: RisaCooQuery, completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable?
    func fetchTemperature(query: OceanQuery, completion: @escaping (Result<OceanResponse, Error>) -> Void) -> Cancellable?
}
