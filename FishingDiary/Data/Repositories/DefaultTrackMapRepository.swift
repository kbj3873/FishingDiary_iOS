//
//  DefaultTrackMapRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/18.
//

import Foundation

final class DefaultTrackMapRepository {
    private var fileStorage: FileDataStorage
    
    init(fileStorage: FileDataStorage) {
        self.fileStorage = fileStorage
    }
}

extension DefaultTrackMapRepository: TrackMapRepository {
    func createPointDate() -> FileCreateResult{
        fileStorage.createPointDate()
    }
    
    func createPointData() -> FileCreateResult{
        fileStorage.createPointData()
    }
    
    func savePoints(locations: [LocationData]) {
        fileStorage.savePoints(locations: locations)
    }
}
