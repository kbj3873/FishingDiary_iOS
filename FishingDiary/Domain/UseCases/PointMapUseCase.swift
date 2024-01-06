//
//  PointMapUseCase.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/14.
//

import Foundation

protocol PointMapUseCaseProtocol {
    func excute(pointData: PointData, completion: (Result<[LocationData], FileStorageError>) -> Void)
}

final class PointMapUseCase: PointMapUseCaseProtocol {
    private let pointMapRepository: PointMapRepository
    
    init(pointMapRepository: PointMapRepository) {
        self.pointMapRepository = pointMapRepository
    }
    
    func excute(pointData: PointData, completion: (Result<[LocationData], FileStorageError>) -> Void) {
        pointMapRepository.fetchLocations(pointData: pointData, completion: completion)
    }
}


