//
//  PointMapRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/14.
//

import Foundation

protocol PointMapRepository {
    func fetchLocations(pointData: PointData, completion: (Result<[LocationData], FileStorageError>) -> Void)
}
