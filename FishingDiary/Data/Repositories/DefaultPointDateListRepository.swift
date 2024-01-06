//
//  DefaultPointDateListRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/07.
//

import Foundation

final class DefaultPointDateListRepository {
    
    private var fileDataStorage: FileDataStorage
    
    init(fileDataStorage: FileDataStorage) {
        self.fileDataStorage = fileDataStorage
    }
}

extension DefaultPointDateListRepository: PointDateListRepository {
    func fetchPointDateList(completion: (Result<[PointDate], FileStorageError>) -> Void) {
        return fileDataStorage.fetchPointDateList(completion: completion)
    }
}
