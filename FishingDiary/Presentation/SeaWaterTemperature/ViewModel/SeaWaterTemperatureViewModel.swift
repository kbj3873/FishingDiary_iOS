//
//  SeaWaterTemperatureViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/06.
//

import Foundation
import Combine


protocol SeaWaterTemperatureViewModelInput {
    func viewDidLoad()
}

protocol SeaWaterTemperatureViewModelOutput {
    var tempItems: CurrentValueSubject<[SeaWaterTempuratureSet], Never> { get }
}

typealias SeaWaterTemperatureViewModelProtocol = SeaWaterTemperatureViewModelInput & SeaWaterTemperatureViewModelOutput

final class SeaWaterTemperatureViewModel: ObservableObject {
    private let appConfiguration: AppConfiguration
    private let oceanUseCase: OceanUseCase
    
    private var oceanLoadTask: Cancellable? {
        willSet {
            oceanLoadTask?.cancel()
        }
    }
    private let mainQueue: DispatchQueueType
    
    @Published var tempuratureItems: [SeaWaterTempuratureSet] = []
    @Published var isLoading: Bool = false
    
    // 선택 상태
    @Published var selectedSea: Sea = .none
    @Published var selectedObserv: (any Observ)? = nil
    
    let tempItems = CurrentValueSubject<[SeaWaterTempuratureSet], Never>([])
    
    // MARK: - Init
    
    init(oceanUseCase: OceanUseCase,
         appConfiguration: AppConfiguration,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.oceanUseCase = oceanUseCase
        self.appConfiguration = appConfiguration
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private
    
    private func load(oceanQuery: OceanQuery) {
        
        oceanLoadTask = oceanUseCase.excute(
            requestValue: .init(query: oceanQuery),
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let oceanResponse):
                        self?.setItemsValue(oceanList: oceanResponse.list)
                        printIfDebug("break")
                    case .failure(let error):
                        print(error)
                    }
                }
            })
    }
    
    private func setItemsValue(oceanList: [Ocean]) {
        var items = [SeaWaterTempuratureSet]()
        for ocean in oceanList {
            let tempSet = SeaWaterTempuratureSet(surTemp: getCGValue(ocean.wtrTempS),
                                                 midTemp: getCGValue(ocean.wtrTempM),
                                                 botTemp: getCGValue(ocean.wtrTempB),
                                                 surDep: ocean.surDep,
                                                 midDep: ocean.midDep,
                                                 botDep: ocean.botDep,
                                                 dateTime: ocean.dateT)
            items.append(tempSet)
        }
        
        items = items.sorted(by: { $0.dateTime < $1.dateTime }) // > 시간차순 정렬
        items = self.addDummyData(items)
        items = self.addTodayDummyData(items)
        
        self.tempItems.value = items
        self.tempuratureItems = items
    }
    
    // > 중간에 누락된 날짜 및 더미 데이터 추가..
    private func addDummyData(_ originItems: [SeaWaterTempuratureSet]) -> [SeaWaterTempuratureSet] {
        if originItems.count == 0 { return originItems }
        
        var items = originItems
        var i = 0
        while i != (items.count - 1) {
            let temp = items[i]
            let date = String(temp.dateTime).toDate()!
            //printIfDebug(String(temp.dateTime))
            
            let nextDate = String(items[i + 1].dateTime).toDate()!
            // > 30분 차이가 나는지 비교
            let diff = Int(nextDate.timeIntervalSince(date)) / 60
            if diff != 30 {
                let addedDate = date.addingTimeInterval(30 * 60)
                let item = getDummyTempData(addedDate.tempDateString(), value: -90)
                items.insert(item, at: i + 1)
            }
            
            i += 1
        }
        
        return items
    }
    
    // > 당일 저녁 00:00까지 더미 데이터 추가.. 그래프 날짜와 간격을 맞추기 위함
    private func addTodayDummyData(_ originItems: [SeaWaterTempuratureSet]) -> [SeaWaterTempuratureSet] {
        if originItems.count == 0 { return originItems }
        
        var items = originItems
        while true {
            let startDate = String(items.last!.dateTime).toDate()
            let addedDate = startDate?.addingTimeInterval(30 * 60)
            let dateTime = addedDate!.tempDateString()
            let item = getDummyTempData(dateTime, value: -99)
            
            if Int(dateTime)! % 10000 == 0 {
                break
            }
            
            items.append(item)
        }
        
        return items
    }
    
    
    private func getCGValue(_ temp: Float) -> CGFloat {
        let digit: CGFloat = pow(10, 1)                 // > 소수점 2번째 반올림
        return round(CGFloat(temp) * digit) / digit     // > Float -> CGFloat
    }
    
    private func getDummyTempData(_ dateTime: String, value: Float) -> SeaWaterTempuratureSet {
        return SeaWaterTempuratureSet(surTemp: CGFloat(value),
                              midTemp: CGFloat(value),
                              botTemp: CGFloat(value),
                              surDep: value,
                              midDep: value,
                              botDep: value,
                              dateTime: Int(dateTime)!)
    }
}

extension SeaWaterTemperatureViewModel {
    func viewDidLoad() { }
    
    func fetchTempuratureData(gruNam: String, staCde: String) {
        self.load(oceanQuery:
                .init(
                    id      : "risaInfo",
                    gruNam  : gruNam,
                    useYn   : "Y",
                    staCde  : staCde,
                    dataCnt : "",
                    ord     : "1",
                    ordType : "A",
                    obsFrom : Date.startTempDateString(),
                    obsTo   : Date.endTempDateString()
                )
        )
    }
}

