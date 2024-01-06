//
//  PointDateListRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/07.
//

import Foundation

protocol PointDateListRepository {
    func fetchPointDateList(completion: (Result<[PointDate], FileStorageError>) -> Void)
}
