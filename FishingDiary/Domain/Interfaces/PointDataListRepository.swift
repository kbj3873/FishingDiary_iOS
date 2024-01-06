//
//  PointDataListRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/11.
//

import Foundation

protocol PointDataListRepository {
    func fetchPointDataList(pointDate: PointDate, completion: (Result<[PointData], FileStorageError>) -> Void)
}
