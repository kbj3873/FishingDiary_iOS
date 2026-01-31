//
//  SeaRegionListViewModel.swift
//  FishingDiary
//
//  Created by Claude on 1/31/26.
//

import Foundation

// MARK: - ObservatoryInfo Model

struct ObservatoryInfo: Identifiable, Hashable {
    let id: String      // API 코드 (cd)
    let name: String    // 표시명 (title)
    let sea: Sea        // 소속 해역

    init(from observ: Observ, sea: Sea) {
        self.id = observ.cd
        self.name = observ.title
        self.sea = sea
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
        observatories = getObservatories(for: sea)
    }

    private func getObservatories(for sea: Sea) -> [ObservatoryInfo] {
        switch sea {
        case .west:
            return WestObserv.allCases
                .filter { $0 != .none }
                .map { ObservatoryInfo(from: $0, sea: sea) }
        case .east:
            return EastObserv.allCases
                .filter { $0 != .none }
                .map { ObservatoryInfo(from: $0, sea: sea) }
        case .south:
            return SouthObserv.allCases
                .filter { $0 != .none }
                .map { ObservatoryInfo(from: $0, sea: sea) }
        case .none:
            return []
        }
    }
}
