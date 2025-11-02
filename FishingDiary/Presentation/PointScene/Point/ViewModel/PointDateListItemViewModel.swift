//
//  PointDateListItemViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/08.
//

import Foundation

struct PointDateListItemViewModel: Hashable {
    let date: String
    let datePath: URL
}

extension PointDateListItemViewModel {
    init (pointDate: PointDate, datePath: URL) {
        self.date = pointDate.date ?? ""
        self.datePath = datePath
    }
}
