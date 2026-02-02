//
//  CurrentTemperatureViewModel.swift
//  FishingDiary
//
//  Created for Figma Feature Implementation
//

import Foundation
import Combine

final class CurrentTemperatureViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var oceanStations: [OceanStationModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOceanSelectPresented: Bool = false

    // MARK: - Dependencies

    private let oceanUseCase: OceanUseCase
    private let appConfiguration: AppConfiguration
    private let mainQueue: DispatchQueueType

    // MARK: - Private Properties

    private var allStationsCache: [OceanStationModel] = [] // 전체 관측소 데이터 캐시
    
    private var loadTask: Cancellable? {
        willSet { loadTask?.cancel() }
    }
    
    // MARK: - Init
    
    init(appConfiguration: AppConfiguration,
         oceanUseCase: OceanUseCase,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.appConfiguration = appConfiguration
        self.oceanUseCase = oceanUseCase
        self.mainQueue = mainQueue
    }

    // MARK: - Public Methods

    func onAppear() {
        // 네트워크 요청 전에 캐시된 데이터로 즉시 목록 갱신 (반응성 향상)
        refreshFilteredList()
        fetchStationList()
    }
    
    func createOceanSelectView() -> OceanSelectView {
        let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()
        let viewModel = pointSceneDIContainer.makeOceanSelectViewModel()
        
        // 데이터 변경 시 호출될 콜백 설정
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            // 메인 스레드 보장
            DispatchQueue.main.async {
                // 저장된 설정이 변경되었으므로 캐시 기반 즉시 갱신 + API 재호출
                self.refreshFilteredList()
                self.fetchStationList()
            }
        }
        
        return OceanSelectView(viewModel: viewModel)
    }

    func fetchStationList() {
        isLoading = true
        
        let query = RisaListQuery(key: appConfiguration.apiKeyRisa, id: "risaList", gruNam: "E")
        
        loadTask = oceanUseCase.excuteRisaList(
            requestValue: .init(query: query),
            completion: { [weak self] result in
                guard let self = self else { return }
                
                self.mainQueue.async {
                    self.isLoading = false
                    
                    switch result {
                    case .success(let response):
                        self.handleSuccess(response)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        )
    }

    // MARK: - Private Methods
    
    /// 캐시된 전체 데이터(allStationsCache)와 현재 저장된 즐겨찾기 목록(UserDefaults)을 비교하여
    /// 화면에 표시할 oceanStations 리스트를 즉시 갱신합니다.
    private func refreshFilteredList() {
        guard !allStationsCache.isEmpty else { return }
        
        // 필터링만 다시 수행
        let savedStations = filterSavedStations(from: allStationsCache)
        self.oceanStations = savedStations
    }

    private func handleSuccess(_ response: RisaResponse) {
        guard let body = response.body, let items = body.item as? [RisaList] else {
            return
        }
        
        let allStations = makeModels(items)
        
        // 전체 데이터 캐시 업데이트
        self.allStationsCache = allStations
        
        // 필터링 및 UI 갱신
        let savedStations = filterSavedStations(from: allStations)
        self.oceanStations = savedStations
    }
    
    private func makeModels(_ items: [RisaList]) -> [OceanStationModel] {
        var oceanStationList = [OceanStationModel]()
        
        // 중복 제거된 코드 추출
        // 모델 초기화 (순서 유지하며 중복 제거)
        var seenCodes = Set<String>()
        for item in items {
            let code = item.staCde
            if !seenCodes.contains(code) {
                seenCodes.insert(code)
                oceanStationList.append(OceanStationModel(
                    stationCode: code,
                    stationName: "", // 이후 루프에서 업데이트됨
                    surTempurature: "",
                    midTempurature: "",
                    botTempurature: ""
                ))
            }
        }
        
        // 데이터 매핑
        for (index, model) in oceanStationList.enumerated() {
            for item in items where item.staCde == model.stationCode {
                var updatedModel = oceanStationList[index]
                
                switch item.obsLay {
                case "1": updatedModel.surTempurature = item.wtrTmp
                case "2": updatedModel.midTempurature = item.wtrTmp
                case "3": updatedModel.botTempurature = item.wtrTmp
                default: break
                }
                
                updatedModel.stationName = item.staNamKor
                oceanStationList[index] = updatedModel
            }
        }
        
        return oceanStationList
    }
    
    private func filterSavedStations(from stations: [OceanStationModel]) -> [OceanStationModel] {
        let savedList = FDUserDefaults.getFromList(key: UserDefaultKey.regionalSeaTempuratureList, type: OceanStationModel.self)
        
        return stations.filter { station in
            savedList.contains { saved in
                station.stationCode == saved.stationCode
            }
        }
    }
}
