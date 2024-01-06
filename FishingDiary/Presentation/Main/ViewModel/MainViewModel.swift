//
//  MainViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/08.
//

import Foundation

struct MainViewModelActions {
    let showTrackMapView: () -> Void
    let showPointList: () -> Void
}

protocol MainViewModelInput {
    func didSelectTrackMapView()
    func didSelectPointList()
}

final class MainViewModel {
    
    private let actions: MainViewModelActions?
    
    init(actions: MainViewModelActions? = nil) {
        self.actions = actions
    }
}

extension MainViewModel: MainViewModelInput {
    func didSelectTrackMapView() {
        actions?.showTrackMapView()
    }
    
    func didSelectPointList() {
        actions?.showPointList()
    }
}
