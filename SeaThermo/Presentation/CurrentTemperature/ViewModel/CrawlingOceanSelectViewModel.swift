//
//  CrawlingOceanSelectViewModel.swift
//  SeaThermo
//

import Foundation

@MainActor
final class CrawlingOceanSelectViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var oceanStations: [CombinedCurrentTemperature] = []
    @Published var showMaxAlert: Bool = false

    // MARK: - Private Properties

    var onDataUpdated: (() -> Void)?
    private var isDataChanged: Bool = false
    private let maxFavorites = 7

    // MARK: - Public Methods

    func viewDidLoad() {
        loadRegions()
    }

    func viewDidDisappear() {
        if isDataChanged {
            onDataUpdated?()
            isDataChanged = false
        }
    }

    func saveCheckList(_ selected: Bool, model: CombinedCurrentTemperature) {
        var savedRegions = FDUserDefaults.getFromList(key: UserDefaultKey.crawlingFavoriteRegions, type: Region.self)

        if selected {
            guard savedRegions.count < maxFavorites else {
                showMaxAlert = true
                return
            }
            let alreadyExists = savedRegions.contains { $0.regionCode == model.stationCode }
            if !alreadyExists {
                let allRegions = FDUserDefaults.getFromList(key: UserDefaultKey.allRegionList, type: Region.self)
                if let region = allRegions.first(where: { $0.regionCode == model.stationCode }) {
                    savedRegions.append(region)
                }
            }
        } else {
            savedRegions.removeAll { $0.regionCode == model.stationCode }
        }

        FDUserDefaults.setToList(savedRegions, key: UserDefaultKey.crawlingFavoriteRegions)

        // UI 상태 즉시 반영
        var list = self.oceanStations
        for (index, item) in list.enumerated() where item.stationCode == model.stationCode {
            var updated = item
            updated.isChecked = selected
            list[index] = updated
        }
        self.oceanStations = list
        isDataChanged = true
    }

    // MARK: - Private Methods

    private func loadRegions() {
        let allRegions = FDUserDefaults.getFromList(key: UserDefaultKey.allRegionList, type: Region.self)
        let favorites = FDUserDefaults.getFromList(key: UserDefaultKey.crawlingFavoriteRegions, type: Region.self)
        let favoriteCodes = Set(favorites.map { $0.regionCode })

        self.oceanStations = allRegions
            .map { region in
                CombinedCurrentTemperature(
                    stationCode: region.regionCode,
                    stationName: region.regionName,
                    surTempurature: "",
                    midTempurature: "",
                    botTempurature: "",
                    seaName: region.regionGroup,
                    isChecked: favoriteCodes.contains(region.regionCode)
                )
            }
            .sorted { $0.stationName < $1.stationName }
    }
}
