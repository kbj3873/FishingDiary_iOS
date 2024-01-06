//
//  PointDataUseCase.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/11.
//

import Foundation

protocol PointDataUseCaseProtocol {
    func excute(pointDate: PointDate, completion: (Result<[PointData], FileStorageError>) -> Void)
}

final class PointDataUseCase: PointDataUseCaseProtocol {
    let pointDataListRepository: PointDataListRepository
    
    init(pointDataListRepository: PointDataListRepository) {
        self.pointDataListRepository = pointDataListRepository
    }
    
    func excute(pointDate: PointDate, completion: (Result<[PointData], FileStorageError>) -> Void) {
        pointDataListRepository.fetchPointDataList(pointDate: pointDate, completion: completion)
    }
}
