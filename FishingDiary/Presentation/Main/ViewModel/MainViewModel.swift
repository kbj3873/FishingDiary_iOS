//
//  MainViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/08.
//

import Foundation
import Combine

struct MainViewModelActions {
    let showOceanSelectedView: () -> Void
    let showTrackMapView: () -> Void
    let showPointList: () -> Void
    let showTemperature: () -> Void
}

protocol MainViewModelInput {
    func didSelectOceanSelctedView()
    func didSelectTemperature()
    func didSelectTrackMapView()
    func didSelectPointList()
}

protocol MainViewModelOutput {
    var items: CurrentValueSubject<TempuratureListItemViewModel, Never> { get }
}

final class MainViewModel {
    
    private let actions: MainViewModelActions?
    
    private let appConfiguration: AppConfiguration
    private let oceanUseCase: OceanUseCase
    private var oceanLoadTask: Cancellable? {
        willSet {
            oceanLoadTask?.cancel()
        }
    }
    private let mainQueue: DispatchQueueType
    
    let items = CurrentValueSubject<TempuratureListItemViewModel, Never>(TempuratureListItemViewModel(oceanStations: []))
    
    init(actions: MainViewModelActions? = nil,
         appConfiguration: AppConfiguration,
         oceanUseCase: OceanUseCase,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.actions = actions
        self.appConfiguration = appConfiguration
        self.oceanUseCase = oceanUseCase
        self.mainQueue = mainQueue
    }
}

extension MainViewModel: MainViewModelInput {
    
    func didSelectOceanSelctedView() {
        actions?.showOceanSelectedView()
    }
    
    func didSelectTemperature() {
        actions?.showTemperature()
    }
    
    func didSelectTrackMapView() {
        actions?.showTrackMapView()
    }
    
    func didSelectPointList() {
        actions?.showPointList()
    }
}

extension MainViewModel {
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
                    
                    let visibleModel = self.makeModels(item)
                    
                    self.items.value = self.loadSavedSeaTempuratureList(visibleModel)
                    
                case .failure(let error):
                    print(error)
                }
            }
        })
        
    }
    /*
    private func loadRisaCode(risaCodeQuery: RisaCodeQuery) {
        
        oceanLoadTask = oceanUseCase.excuteStationCode(requestValue: .init(query: risaCodeQuery),
                                                       completion: { [weak self] results in
            guard let self = self else { return }
            
            self.mainQueue.async {
                switch results {
                case .success(let risaCode):
                    guard let body = risaCode.body, let item = body.item as? [RisaStation] else {
                        print("no body data")
                        return
                    }
                    
                    for station in item {
                        print("g:\(station.gruNam) cd: \(station.staCde) name: \(station.staNamKor) obs: \(station.obsLay) temp: \(station.wtrTmp)")
                    }
                    
                    self.items.value = self.makeModels(item)
                    
                case .failure(let error):
                    print(error)
                }
            }
        })
        
    }
    
    private func loadRisaCoo(risaCooQuery: RisaCooQuery) {
        oceanLoadTask = oceanUseCase.excuteRisaCoo(requestValue: .init(query: risaCooQuery),
                                                   completion: { [weak self] results in
            self?.mainQueue.async {
                switch results {
                case .success(let risaCode):
                    guard let body = risaCode.body, let item = body.item as? [RisaCoo] else {
                        print("no body data")
                        return
                    }
                    
                    for coo in item {
                        print("g:\(coo.gruNam) cd: \(coo.staCde) name: \(coo.staNamKor) data: \(coo.obsDate) tmp: \(coo.wtrTmp)")
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
     */
    private func makeModels(_ items: [RisaList]) -> TempuratureListItemViewModel {
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
        
        // 저층수온 있는 데이터
        /*let tempList = oceanStationList.filter {
            Float($0.surTempurature) ?? 0 > 0 &&
            Float($0.midTempurature) ?? 0 > 0 &&
            Float($0.botTempurature) ?? 0 > 0
        }
        // 중층수온 있는 데이터
        let tempList = oceanStationList.filter {
            Float($0.surTempurature) ?? 0 > 0 &&
            Float($0.midTempurature) ?? 0 > 0
        }*/
        
        /*let botTemplist = tempList.filter { $0.botTempurature.count > 0 }
        let sortedList = botTemplist.sorted(by: { Float($0.surTempurature) ?? 0 < Float($1.surTempurature) ?? 0 })*/
        //let midTemplist = tempList.filter { $0.midTempurature.count > 0 }
        let sortedList = oceanStationList.sorted(by: { Float($0.surTempurature) ?? 0 < Float($1.surTempurature) ?? 0 })
        oceanStationList = sortedList
        
        /*
        for station in oceanStationList {
            print("\(station.stationName) \(station.stationCode) sur: \(station.surTempurature) mid: \(station.midTempurature) bot: \(station.botTempurature)")
        }
        */
        
        return TempuratureListItemViewModel(oceanStations: oceanStationList)
    }
    
    private func loadSavedSeaTempuratureList(_ model: TempuratureListItemViewModel) -> TempuratureListItemViewModel {
        let oceanStationList = FDUserDefaults.getFromList(key: UserDefaultKey.regionalSeaTempuratureList, type: OceanStationModel.self)
        
        var visibleStationList = model.oceanStations.filter { ocean in
            oceanStationList.contains { favoriteOcean in
                ocean.stationCode == favoriteOcean.stationCode
            }
        }
        
        let titleModel = OceanStationModel(stationCode: "",
                                           stationName: "측정해역",
                                           surTempurature: "표층",
                                           midTempurature: "중층",
                                           botTempurature: "저층")
        visibleStationList.insert(titleModel, at: 0)
        
        return TempuratureListItemViewModel(oceanStations: visibleStationList)
    }
}

extension MainViewModel {
    func viewDidLoad(){
        self.fetchRisaList()
    }
    
    func fetchRisaList() {
        self.loadRisaList(risaListQuery: .init(key: appConfiguration.apiKeyRisa, id: "risaList", gruNam: "E"))
    }
    
//    func fetchStationList() {
//        self.loadRisaCode(risaCodeQuery: .init(key: appConfiguration.apiKeyRisa, id: "risaList", gruNam: "E", useYn: "Y"))
//    }
}
