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

final class PointDataListViewModel {
    private let pointDataUseCase: PointDataUseCase
    private let actions: PointDataListViewModelActions?
    
    var pointDate: PointDate
    
    var items = CurrentValueSubject<[PointDataListItemViewModel], Never>([])
    var pointDataList = [PointData]()
    
    init(pointDate: PointDate,
         pointDataUseCase: PointDataUseCase,
         pointDataListViewModelActions: PointDataListViewModelActions) {
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
        self.pointDataList = pointDataList
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
        actions?.showPointMap(pointDataList[index])
    }
}

