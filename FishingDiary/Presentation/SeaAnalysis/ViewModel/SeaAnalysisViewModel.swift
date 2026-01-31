//
//  SeaAnalysisViewModel.swift
//  FishingDiary
//
//  Created by Claude on 1/31/26.
//

import Foundation

struct SeaRegionInfo: Identifiable {
    let id: String
    let sea: Sea
    let title: String
    let subtitle: String
    let imageName: String
    let stationCount: Int
}

final class SeaAnalysisViewModel: ObservableObject {
    @Published var seaRegions: [SeaRegionInfo] = []

    init() {
        loadSeaRegions()
    }

    private func loadSeaRegions() {
        seaRegions = [
            SeaRegionInfo(
                id: Sea.west.id,
                sea: .west,
                title: "서해",
                subtitle: "황해 연안 지역",
                imageName: "sea_west",
                stationCount: WestObserv.allCases.count - 1 // none 제외
            ),
            SeaRegionInfo(
                id: Sea.east.id,
                sea: .east,
                title: "동해",
                subtitle: "동해안 지역",
                imageName: "sea_east",
                stationCount: EastObserv.allCases.count - 1 // none 제외
            ),
            SeaRegionInfo(
                id: Sea.south.id,
                sea: .south,
                title: "남해",
                subtitle: "남해안 지역",
                imageName: "sea_south",
                stationCount: SouthObserv.allCases.count - 1 // none 제외
            )
        ]
    }
}
