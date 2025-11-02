//
//  OceanSelectViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/28/25.
//

import Foundation
import Combine

protocol OceanSelectViewModelOutput {
    var items: CurrentValueSubject<[OceanStationModel], Never> { get }
}

final class OceanSelectViewModel: ObservableObject {
    private let appConfiguration: AppConfiguration
    private let oceanUseCase: OceanUseCase
    private var oceanLoadTask: Cancellable? {
        willSet {
            oceanLoadTask?.cancel()
        }
    }
    private let mainQueue: DispatchQueueType
    
    let items = CurrentValueSubject<[OceanStationModel], Never>([])
    @Published var oceanStations = [OceanStationModel]()
    
    init(appConfiguration: AppConfiguration,
         oceanUseCase: OceanUseCase,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.appConfiguration = appConfiguration
        self.oceanUseCase = oceanUseCase
        self.mainQueue = mainQueue
    }
}

extension OceanSelectViewModel {
    // MARK: - private
    private func loadRisaList(risaListQuery: RisaListQuery) {
        
        oceanLoadTask = oceanUseCase.excuteRisaList(requestValue: .init(query: risaListQuery),
                                                       completion: { [weak self] results in
            guard let self = self else { return }
            
            self.mainQueue.async {
                switch results {
                case .success(let risaList):
                    guard let body = risaList.body, let item = body.item as? [RisaList] else {
                        print("no risa items")
                        return
                    }
                    
                    for station in item {
                        print("g:\(station.gruNam) cd: \(station.staCde) name: \(station.staNamKor) obs: \(station.obsLay) temp: \(station.wtrTmp)")
                    }
                    
                    self.items.value = self.makeModels(item)
                    self.oceanStations = self.makeModels(item)
                    
                case .failure(let error):
                    print(error)
                }
            }
        })
        
    }
    
    private func makeModels(_ items: [RisaList]) -> [OceanStationModel] {
        var oceanStationList = [OceanStationModel]()
        
        // > 중복 제외한 code만 추출
        var array = [String]()
        for item in items {
            array.append(item.staCde)
        }
        let removedArray = Set(array)
        
        for code in removedArray {
            let model = OceanStationModel(stationCode: code,
                                          stationName: "",
                                          surTempurature: "",
                                          midTempurature: "",
                                          botTempurature: "")
            oceanStationList.append(model)
        }
        
        for (index, model) in oceanStationList.enumerated() {
            for item in items {
                if model.stationCode == item.staCde {
                    var chModel = oceanStationList[index]
                    if item.obsLay == "1" {
                        chModel.surTempurature = item.wtrTmp
                    } else if item.obsLay == "2" {
                        chModel.midTempurature = item.wtrTmp
                    } else if item.obsLay == "3" {
                        chModel.botTempurature = item.wtrTmp
                    }
                    chModel.stationName = item.staNamKor
                    oceanStationList[index] = chModel
                }
            }
        }
        
        /// 이전에 선택했던 지역 체크
        let selectedOceanList = FDUserDefaults.getFromList(key: UserDefaultKey.regionalSeaTempuratureList, type: OceanStationModel.self)
        
        if selectedOceanList.count > 0 {
            for (index, model) in oceanStationList.enumerated() {
                for selectedOcean in selectedOceanList {
                    if model.stationCode == selectedOcean.stationCode {
                        var chModel = oceanStationList[index]
                        chModel.isChecked = true
                        
                        oceanStationList[index] = chModel
                    }
                }
            }
        }
        
        oceanStationList = oceanStationList.sorted { $0.stationName < $1.stationName }
        
        return oceanStationList
    }
    
    func saveCheckList(_ selected: Bool, model: OceanStationModel) {
        var savedOceanList = FDUserDefaults.getFromList(key: UserDefaultKey.regionalSeaTempuratureList, type: OceanStationModel.self)
        
        if selected {
            let exist = savedOceanList.filter {
                $0.stationCode == model.stationCode
            }
            
            if exist.count == 0 {
                savedOceanList.append(model)
            }
        }
        
        else {
            let exist = savedOceanList.filter {
                $0.stationCode == model.stationCode
            }
            
            if exist.count > 0 {
                savedOceanList = savedOceanList.filter{$0.stationCode != model.stationCode}
            }
        }
        
        FDUserDefaults.setToList(savedOceanList, key: UserDefaultKey.regionalSeaTempuratureList)
        
        var oceanStationList = self.items.value
        for (index, item) in oceanStationList.enumerated() {
            if item.stationCode == model.stationCode {
                var chModel = item
                chModel.isChecked = selected
                oceanStationList[index] = chModel
            }
        }
        
        self.items.value = oceanStationList
        self.oceanStations = oceanStationList
    }
}

extension OceanSelectViewModel {
    func viewDidLoad(){
        self.fetchRisaList()
    }
    
    func fetchRisaList() {
        self.loadRisaList(risaListQuery: .init(key: appConfiguration.apiKeyRisa, id: "risaList", gruNam: "E"))
    }
}
