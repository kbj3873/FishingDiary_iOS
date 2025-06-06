//
//  KakaoTrackMapViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/02/16.
//

import Foundation
import Combine
import CoreLocation
import KakaoMapsSDK

protocol KakaoTrackMapViewModelInput {
    func viewDidLoad()
    func viewWillDisappear()
}

protocol KakaoTrackMapViewModelOutput {
    var mapLineItem: CurrentValueSubject<MapLineInfo, Never> { get }
}

typealias KakaoTrackMapViewModelProtocol = KakaoTrackMapViewModelInput & KakaoTrackMapViewModelOutput

final class KakaoTrackMapViewModel {
    private let trackMapUseCase: TrackMapUseCase
    var mapLineItem = CurrentValueSubject<MapLineInfo, Never>(MapLineInfo(CLLocation(), CLLocation()))
    var cancelBag = Set<AnyCancellable>()
    
    private let locationManager = FDLocationManager.shared
    
    private var saveComplete: (([LocationData]) -> Void)?
    
    init(trackMapUseCase: TrackMapUseCase) {
        self.trackMapUseCase = trackMapUseCase
        
        saveComplete = { [weak self] locations in
            guard let self = self else { return }
            
            self.trackMapUseCase.savePoints(locations: locations)
        }
        locationManager.saveComplete = saveComplete
        bind()
    }
    
    func bind() {
        locationManager.curMapLine.sink(receiveValue: { [weak self] mapLine in
            guard let self = self else { return }
            
            self.mapLineItem.value = mapLine
        }).store(in: &cancelBag)
    }
    
    func savePoints(locations: [LocationData]) {
        trackMapUseCase.savePoints(locations: locations)
    }
    
    func addLocation(location: CLLocation) {
        locationManager.addLocation(location: location)
    }
    
    func getLocationList() -> [LocationInfo] {
        return locationManager.locationList
    }
}

extension KakaoTrackMapViewModel: KakaoTrackMapViewModelProtocol {
    func viewDidLoad() {
        let dateResult = trackMapUseCase.createPointDate()
        let dataResult = trackMapUseCase.createPointData()
        
        if dateResult == FileCreateResult.success(true) &&
            dataResult == FileCreateResult.success(true) {
            print("make track data directory success")
        }
        
        locationManager.startTracking()
    }
    
    func viewWillDisappear() {
        locationManager.stopTracking()
    }
}
