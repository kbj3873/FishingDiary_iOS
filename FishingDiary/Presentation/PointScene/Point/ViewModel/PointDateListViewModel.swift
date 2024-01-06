//
//  PointDateListViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/06.
//

import Foundation
import Combine

struct PointDateListViewModelActions {
    let showPointDataList: (PointDate) -> Void
}

protocol PointDateListViewModelInput {
    func viewDidLoad()
    func didSelectItem(at index: Int)
}

protocol PointDateListViewModelOutput {
    var items: CurrentValueSubject<[PointDateListItemViewModel], Never> { get }
}

typealias PointDateListViewModelProtocol = PointDateListViewModelInput & PointDateListViewModelOutput

final class PointDateListViewModel {
    
    private let pointDateUseCase: PointDateUseCase
    private let actions: PointDateListViewModelActions?
    
    var items = CurrentValueSubject<[PointDateListItemViewModel], Never>([])
    
    init(pointDateUseCase: PointDateUseCase, actions: PointDateListViewModelActions? = nil) {
        self.pointDateUseCase = pointDateUseCase
        self.actions = actions
    }
    
    private func loadPointDates() {
        pointDateUseCase.excute(completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let pointDates):
                self.setItemsValue(pointDates: pointDates)
                
            case .failure(let error):
                self.handle(error: error)
            }})
    }
    
    private func setItemsValue(pointDates: [PointDate]) {
        var viewModelItems = [PointDateListItemViewModel]()
        for pointDate in pointDates {
            let pointDateListItemViewModel = PointDateListItemViewModel(date: pointDate.date!,
                                                                        datePath: pointDate.datePath!)
            viewModelItems.append(pointDateListItemViewModel)
        }
        
        items.value = viewModelItems
    }
                          
    private func handle(error: FileStorageError) {
        print("point date error - \(error.description)")
    }
}

extension PointDateListViewModel: PointDateListViewModelProtocol {
    func viewDidLoad() {
        loadPointDates()
    }
    
    func didSelectItem(at index: Int) {
        let item = items.value[index]
        let pointDate = PointDate(date: item.date,
                                  datePath: item.datePath)
        actions?.showPointDataList(pointDate)
    }
}
