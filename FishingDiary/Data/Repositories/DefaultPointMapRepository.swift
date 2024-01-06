//
//  DefaultPointMapRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/14.
//

import Foundation

final class DefaultPointMapRepository {
    private var fileStorage: FileDataStorage
    
    init(fileStorage: FileDataStorage) {
        self.fileStorage = fileStorage
    }
}

extension DefaultPointMapRepository: PointMapRepository {
    func fetchLocations(pointData: PointData, completion: (Result<[LocationData], FileStorageError>) -> Void) {
        fileStorage.fetchLocations(pointData: pointData, completion: completion)
    }
}
