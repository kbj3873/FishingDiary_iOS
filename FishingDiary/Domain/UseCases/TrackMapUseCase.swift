//
//  TrackMapUseCase.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/18.
//

import Foundation

protocol TrackMapUseCaseProtocol {
    func createPointDate() -> FileCreateResult
    func createPointData() -> FileCreateResult
    func savePoints(locations: [LocationData])
}

final class TrackMapUseCase: TrackMapUseCaseProtocol {
    private let trackMapRepository: TrackMapRepository
    
    init(trackMapRepository: TrackMapRepository) {
        self.trackMapRepository = trackMapRepository
    }
    
    func createPointDate() -> FileCreateResult{
        trackMapRepository.createPointDate()
    }
    
    func createPointData() -> FileCreateResult{
        trackMapRepository.createPointData()
    }
    
    func savePoints(locations: [LocationData]) {
        trackMapRepository.savePoints(locations: locations)
    }
}
