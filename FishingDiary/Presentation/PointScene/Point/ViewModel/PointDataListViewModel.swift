//
//  PointDataListViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/11.
//

import Foundation
import Combine

struct PointDataListViewModelActions {
    let showPointMap: (PointData) -> Void
}

protocol PointDataListViewModelInput {
    func viewDidLoad()
    func didSelectPoint(at index: Int)
}

protocol PointDataListViewModelOutput {
    var items: CurrentValueSubject<[PointDataListItemViewModel], Never> { get }
}

typealias PointDataListViewModelProtocol = PointDataListViewModelInput & PointDataListViewModelOutput

final class PointDataListViewModel: ObservableObject {
    private let pointDataUseCase: PointDataUseCase
    private let actions: PointDataListViewModelActions?
    
    var pointDate: PointDate
    
    var items = CurrentValueSubject<[PointDataListItemViewModel], Never>([])
    var itemList = [PointData]()
    @Published var pointDataList = [PointDataListItemViewModel]()
    
    // Navigation 상태
    @Published var selectedPointData: PointData?
    @Published var isShowingPointMap = false
    // PointMapViewModel (한 번만 생성)
    @Published var pointMapViewModel: PointMapViewModel?
    @Published var kakaoPointMapViewModel: KakaoPointMapViewModel?
    
    init(pointDate: PointDate,
         pointDataUseCase: PointDataUseCase,
         pointDataListViewModelActions: PointDataListViewModelActions? = nil) {
        self.pointDate = pointDate
        self.pointDataUseCase = pointDataUseCase
        self.actions = pointDataListViewModelActions
    }
    
    private func loadPointDataList() {
        pointDataUseCase.excute(pointDate: pointDate, completion: { [weak self] result in
            switch result {
            case .success(let pointDataList):
                self?.setItemsValue(pointDataList: pointDataList)
            case .failure(let error):
                self?.handleError(error: error)
            }
        })
    }
    
    private func setItemsValue(pointDataList: [PointData]) {
        var viewModelItems = [PointDataListItemViewModel]()
        
        for pointData in pointDataList {
            let pointDataListItemViewModel = PointDataListItemViewModel(dataPath: pointData.dataPath!,
                                                                        dataName: pointData.dataName!)
            viewModelItems.append(pointDataListItemViewModel)
        }
        
        items.value = viewModelItems
        self.itemList = pointDataList
        self.pointDataList = viewModelItems
    }
    
    private func handleError(error: FileStorageError) {
        print("point data error - \(error.description)")
    }
}

extension PointDataListViewModel: PointDataListViewModelProtocol {
    func viewDidLoad() {
        loadPointDataList()
    }
    
    func didSelectPoint(at index: Int) {
        actions?.showPointMap(itemList[index])
    }
    
    func pushSelectPointMap(at index: Int) {
        let pointData = itemList[index]
        selectedPointData = pointData
        
        let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()
        
        // viewModel 생성
        pointMapViewModel = PointMapViewModel(
            pointData: pointData,
            pointMapUseCase: pointSceneDIContainer.makePointMapUseCase()
        )
        
        isShowingPointMap = true
    }
    
    func pushSelectKakaoPointMap(at index: Int) {
        let pointData = itemList[index]
        selectedPointData = pointData
        
        let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()
        
        // viewModel 생성
        kakaoPointMapViewModel = KakaoPointMapViewModel(
            pointData: pointData,
            pointMapUseCase: pointSceneDIContainer.makePointMapUseCase()
        )
        
        isShowingPointMap = true
    }
}

