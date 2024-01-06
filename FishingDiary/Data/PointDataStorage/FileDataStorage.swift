//
//  FileDataStorage.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/07.
//

import Foundation

protocol FileDataStorageProtocol {
    func createPointDate() -> FileCreateResult
    func createPointData() -> FileCreateResult
    func savePoints(locations: [LocationData])
    func fetchPointDateList(completion: (Result<[PointDate], FileStorageError>) -> Void)
    func fetchPointDataList(pointDate: PointDate, completion: (Result<[PointData], FileStorageError>) -> Void)
    func fetchLocations(pointData: PointData, completion: (Result<[LocationData], FileStorageError>) -> Void)
}

final class FileDataStorage {
    
    private let fileManager = FDFileManager.shared
    
    init() { }
}

extension FileDataStorage: FileDataStorageProtocol {
    func createPointDate() -> FileCreateResult{
        fileManager.createPointDate()
    }
    
    func createPointData() -> FileCreateResult{
        fileManager.createPointData()
    }
    
    func savePoints(locations: [LocationData]) {
        fileManager.savePoints(locations: locations)
    }
    
    func fetchPointDateList(completion: (Result<[PointDate], FileStorageError>) -> Void) {
        fileManager.fetchPointDateList(completion: completion)
    }
    
    func fetchPointDataList(pointDate: PointDate, completion: (Result<[PointData], FileStorageError>) -> Void) {
        fileManager.fetchPointDataList(pointDate: pointDate, completion: completion)
    }
    
    func fetchLocations(pointData: PointData, completion: (Result<[LocationData], FileStorageError>) -> Void) {
        fileManager.fetchLocations(pointData: pointData, completion: completion)
    }
}
