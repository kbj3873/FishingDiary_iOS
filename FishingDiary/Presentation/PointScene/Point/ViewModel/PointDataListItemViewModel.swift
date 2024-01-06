//
//  PointDataListItemViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/14.
//

import Foundation

struct PointDataListItemViewModel {
    var dataPath: URL
    var dataName: String
}

extension PointDataListItemViewModel {
    init(data: PointData) {
        self.dataPath = data.dataPath!
        self.dataName = data.dataName!
    }
}
