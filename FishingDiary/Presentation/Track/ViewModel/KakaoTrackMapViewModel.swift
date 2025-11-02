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
    var mapLine: MapLineInfo{ get }
    var currentSpeed: String { get }
    var currentLatitude: String { get }
    var currentLongitude: String { get }
}

typealias KakaoTrackMapViewModelProtocol = KakaoTrackMapViewModelInput & KakaoTrackMapViewModelOutput

final class KakaoTrackMapViewModel: ObservableObject {
    private let trackMapUseCase: TrackMapUseCase
    
    @Published var mapLine = MapLineInfo(CLLocation(), CLLocation())
    @Published var currentSpeed = "0.00"
    @Published var currentLatitude = "0.000000"
    @Published var currentLongitude = "0.000000"
    @Published private(set) var isTracking = false  // 추적 상태
    
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
    
    func cleanup() {
        stopTracking()
    }
    
    func bind() {
        locationManager.curMapLine.sink(receiveValue: { [weak self] mapLine in
            guard let self = self else { return }
            
            self.mapLineItem.value = mapLine
            
            self.mapLine = mapLine
            
            // UI 업데이트
            let location = mapLine.currentLocation
            self.currentLatitude = String(format: "%.6f", location.coordinate.latitude)
            self.currentLongitude = String(format: "%.6f", location.coordinate.longitude)
            
            let speed = location.speed * 3.6 // km/h
            self.currentSpeed = String(format: "%.2f", speed)
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
        
        startTracking()
    }
    
    func viewWillDisappear() {
        stopTracking()
    }
    
    private func startTracking() {
        guard !isTracking else { return }
        
        locationManager.startTracking()
        isTracking = true
        
        print("위치 추적 시작")
    }
    
    private func stopTracking() {
        guard isTracking else { return }
        
        locationManager.stopTracking()
        isTracking = false
        
        print("위치 추적 중지")
    }
}
