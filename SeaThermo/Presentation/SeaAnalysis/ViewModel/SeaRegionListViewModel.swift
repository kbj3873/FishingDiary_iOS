//
//  SeaRegionListViewModel.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import Foundation

// MARK: - ObservatoryInfo Model

struct ObservatoryInfo: Identifiable, Hashable {
    let id: String      // API staCde (regionCode)
    let name: String    // 표시명 (regionName)
    let sea: Sea        // 소속 해역 → sea.id로 NIFS API gruNam 제공

    init(from region: Region) {
        self.id = region.regionCode
        self.name = region.regionName
        self.sea = region.toSea()
    }
}

// MARK: - SeaRegionListViewModel

final class SeaRegionListViewModel: ObservableObject {
    @Published var observatories: [ObservatoryInfo] = []

    let sea: Sea
    let title: String
    let subtitle: String = "수온 데이터를 확인할 지역을 선택하세요"

    init(sea: Sea) {
        self.sea = sea
        self.title = "\(sea.rawValue) 지역"
        loadObservatories()
    }

    private func loadObservatories() {
        let allRegions = FDUserDefaults.getFromList(key: UserDefaultKey.allRegionList, type: Region.self)

        observatories = allRegions
            .filter { $0.toSea() == sea }
            .map { ObservatoryInfo(from: $0) }
            .sorted { $0.name < $1.name }
    }
}
