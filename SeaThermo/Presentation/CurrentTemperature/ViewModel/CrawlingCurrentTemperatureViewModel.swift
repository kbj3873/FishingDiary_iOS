//
//  CrawlingCurrentTemperatureViewModel.swift
//  SeaThermo
//

import Foundation

@MainActor
final class CrawlingCurrentTemperatureViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var oceanStations: [CombinedCurrentTemperature] = []
    @Published var isLoading: Bool = false
    @Published var isOceanSelectPresented: Bool = false

    // MARK: - Dependencies

    private let oceanUseCase: OceanUseCase

    // MARK: - Private Properties

    private var loadTask: Task<Void, Never>? {
        willSet { loadTask?.cancel() }
    }

    // MARK: - Init

    init(oceanUseCase: OceanUseCase) {
        self.oceanUseCase = oceanUseCase
    }

    // MARK: - Public Methods

    func onAppear() {
        fetchStationList()
    }

    func createOceanSelectView() -> CrawlingOceanSelectView {
        let selectViewModel = CrawlingOceanSelectViewModel()
        selectViewModel.onDataUpdated = { [weak self] in
            Task { @MainActor [weak self] in
                self?.fetchStationList()
            }
        }
        return CrawlingOceanSelectView(viewModel: selectViewModel)
    }

    func fetchStationList() {
        let favoriteRegions = FDUserDefaults.getFromList(key: UserDefaultKey.crawlingFavoriteRegions, type: Region.self)

        guard !favoriteRegions.isEmpty else {
            self.oceanStations = []
            return
        }

        isLoading = true
        let useCase = oceanUseCase

        loadTask = Task {
            let obsFrom = Date.endTempDateString()
            let obsTo = Date.endTempDateString()
            var results: [CombinedCurrentTemperature] = []

            await withTaskGroup(of: CombinedCurrentTemperature.self) { group in
                for region in favoriteRegions {
                    group.addTask {
                        let gruNam = Self.toGruNam(region.regionGroup)
                        let query = SeaAnalysisQuery(
                            id: "risaInfo",
                            gruNam: gruNam,
                            useYn: "Y",
                            staCde: region.regionCode,
                            dataCnt: "1",   // 최신 1개만 요청 (ordType=D와 함께 사용)
                            ord: "1",
                            ordType: "D",   // 최신순 내림차순
                            obsFrom: obsFrom,
                            obsTo: obsTo
                        )
                        do {
                            let weeklyTemps = try await useCase.fetchTemperature(query)
                            return Self.mapToCombined(region: region, weeklyTemps: weeklyTemps)
                        } catch {
                            print("크롤링 오류 [\(region.regionName)]: \(error)")
                            return CombinedCurrentTemperature(
                                stationCode: region.regionCode,
                                stationName: region.regionName,
                                surTempurature: "",
                                midTempurature: "",
                                botTempurature: "",
                                seaName: region.regionGroup
                            )
                        }
                    }
                }

                for await station in group {
                    results.append(station)
                }
            }

            // 즐겨찾기 등록 순서 보존
            let ordered = favoriteRegions.compactMap { region in
                results.first { $0.stationCode == region.regionCode }
            }
            self.oceanStations = ordered
            self.isLoading = false
        }
    }

    // MARK: - Private Static Helpers

    /// region_group(한글) → NIFS API gruNam 코드 변환
    private nonisolated static func toGruNam(_ regionGroup: String) -> String {
        switch regionGroup {
        case "동해": return "E"
        case "서해": return "W"
        case "남해": return "S"
        case "제주": return "J"
        default:    return regionGroup
        }
    }

    /// WeeklyTemperature 목록(ordType=D, rowCountPage=1)에서 수층별 유효값을 매핑
    /// 서버에서 이미 최신순 정렬된 상태로 오므로 .first(where:)로 바로 추출
    private nonisolated static func mapToCombined(region: Region, weeklyTemps: [WeeklyTemperature]) -> CombinedCurrentTemperature {
        let firstValidSurface = weeklyTemps.first(where: { $0.wtrTempS > 0 })
        let firstValidMiddle  = weeklyTemps.first(where: { $0.wtrTempM > 0 })
        let firstValidBottom  = weeklyTemps.first(where: { $0.wtrTempB > 0 })

        return CombinedCurrentTemperature(
            stationCode:    region.regionCode,
            stationName:    region.regionName,
            surTempurature: firstValidSurface.map { String(format: "%.1f", $0.wtrTempS) } ?? "",
            midTempurature: firstValidMiddle.map  { String(format: "%.1f", $0.wtrTempM) } ?? "",
            botTempurature: firstValidBottom.map  { String(format: "%.1f", $0.wtrTempB) } ?? "",
            seaName:        region.regionGroup
        )
    }
}
