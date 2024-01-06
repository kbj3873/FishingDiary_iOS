//
//  TrackMapRepository.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/18.
//

import Foundation

protocol TrackMapRepository {
    func createPointDate() -> FileCreateResult
    func createPointData() -> FileCreateResult
    func savePoints(locations: [LocationData])
}
