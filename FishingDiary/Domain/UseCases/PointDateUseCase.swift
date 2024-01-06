//
//  PointDateUseCase.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/07.
//

import Foundation

protocol PointDateUseCaseProtocol {
    func excute(completion: (Result<[PointDate], FileStorageError>) -> Void)
}

final class PointDateUseCase: PointDateUseCaseProtocol {
    private let pointDateListRepository: PointDateListRepository
    
    init(pointDatesRepository: PointDateListRepository) {
        self.pointDateListRepository = pointDatesRepository
    }
    
    func excute(completion: (Result<[PointDate], FileStorageError>) -> Void) {
        return pointDateListRepository.fetchPointDateList(completion: completion)
    }
    
}
