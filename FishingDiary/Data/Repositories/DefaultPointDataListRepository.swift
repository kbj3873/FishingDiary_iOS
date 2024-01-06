//
//  DefaultPointDataListRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/11.
//

import Foundation

final class DefaultPointDataListRepository {
    private var fileStorage: FileDataStorage
    
    init(fileStorage: FileDataStorage) {
        self.fileStorage = fileStorage
    }
}

extension DefaultPointDataListRepository: PointDataListRepository {
    func fetchPointDataList(pointDate: PointDate, completion: (Result<[PointData], FileStorageError>) -> Void) {
        fileStorage.fetchPointDataList(pointDate: pointDate, completion: completion)
    }
}
