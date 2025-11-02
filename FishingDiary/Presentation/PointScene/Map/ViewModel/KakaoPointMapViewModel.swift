//
//  KakaoPointMapViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/01/25.
//

import Foundation
import Combine
import KakaoMapsSDK

protocol KakaoPointMapViewModelInput {
    func loadPointData()
}

// > 포인트 시작위치, 지도 노출 범위, 포인트 라인

protocol KakaoPointMapViewModelOutput {
    var points: CurrentValueSubject<[MapPoint], Never> { get }
    var mapPinItems: CurrentValueSubject<[KakaoMapPin], Never> { get }
    var polylineItems: CurrentValueSubject<[MapPolyline], Never> { get }
    
    var mapPoints: [MapPoint] { get }
    var mapPins: [KakaoMapPin] { get }
    var polylines: [MapPolyline] { get }
}

typealias KakaoPointMapViewModelProtocol = KakaoPointMapViewModelInput & KakaoPointMapViewModelOutput

final class KakaoPointMapViewModel: ObservableObject {
    private let pointData: PointData
    private let pointMapUseCase: PointMapUseCase
    
    var points = CurrentValueSubject<[MapPoint], Never>([])
    var mapPinItems = CurrentValueSubject<[KakaoMapPin], Never>([])
    var polylineItems = CurrentValueSubject<[MapPolyline], Never>([])
    
    @Published var mapPoints = [MapPoint]()
    @Published var mapPins = [KakaoMapPin]()
    @Published var polylines = [MapPolyline]()
    @Published private(set) var isLoaded = false
    
    init(pointData: PointData, pointMapUseCase: PointMapUseCase) {
        self.pointData = pointData
        self.pointMapUseCase = pointMapUseCase
    }
    
    private func loadLocations(pointData: PointData) {
        guard !isLoaded else { return }
        
        pointMapUseCase.excute(pointData: pointData, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let locations):
                self.setRegionValue(locations: locations)
                self.setPolyLinesValue(locations: locations)
                self.setStartMapPinsValue(locations: locations)
                self.isLoaded = true
            case .failure(let error):
                self.handleError(error: error)
            }
        })
    }
    
    private func handleError(error: FileStorageError) {
        print("point date error - \(error.description)")
    }
    
    // 메모리 정리
    func cleanup() {
        mapPoints.removeAll()
        mapPins.removeAll()
        polylines.removeAll()
    }
}

extension KakaoPointMapViewModel: KakaoPointMapViewModelProtocol {
    func loadPointData() {
        loadLocations(pointData: pointData)
    }
}

extension KakaoPointMapViewModel {
    private func setRegionValue(locations: [LocationData]) {
        var points = [MapPoint]()
        for location in locations {
            if let lat = Double(location.latitude), let lon = Double(location.longitude) {
                
                let point = MapPoint(longitude: lon, latitude: lat)
                points.append(point)
            }
        }
        
        self.points.value = points
        mapPoints = points
    }
    
    private func setPolyLinesValue(locations: [LocationData]) {
        var polyLines = [MapPolyline]()
        
        var area = [MapPoint]()
        for location in locations {
            if let lat = Double(location.latitude), let lon = Double(location.longitude) {
                let point = MapPoint(longitude: lon, latitude: lat)
                area.append(point)
                
                if area.count > 1 {
                    var polyline: MapPolyline!
                    if let kmh = Float(location.kmh), let knot = Float(location.knot) {
                        let styleIndex: UInt = (kmh < FDAppManager.pointVelocity) ? 0:1
                        polyline = MapPolyline(line: area, styleIndex: styleIndex)
                        polyline.kmh = kmh
                        polyline.knot = knot
                        polyline.title = (kmh < FDAppManager.pointVelocity) ? "point":"move"
                        //print("area count: \(area.count)")
                        //print("make polyline line kmh: \(poliline.kmh) knot: \(poliline.knot) color: \((poliline.color == UIColor.red ? "red":"blue"))")    // > testcode
                    }
                    else {
                        print("not velocity")
                    }
                    polyLines.append(polyline)
                    
                    area.removeFirst()
                }
                /*
                 if let kmh = Float(location.kmh), kmh < FDAppManager.pointVelocity, let img = UIImage(named: "point") {
                 //print("make annotation location seq: \(location.sequence)")
                 let annotation = MapPin(title: "\(location.kmh) km/h", subtitle: "\(location.knot) knot", coordinate: point, locationData: location, image: img, dmsType: .D)
                 self.mapView.addAnnotation(annotation)
                 }
                 */
            }
        }
        
        polylineItems.value = polyLines
        self.polylines = polyLines
    }
    
    private func setStartMapPinsValue(locations: [LocationData]) {
        var mapPins = [KakaoMapPin]()
        
        for (index, location) in locations.enumerated() {
            
            guard let lat = Double(location.latitude),
                    let lon = Double(location.longitude)else {
                return
            }
            
            if index > 0 {
                let preLocation = locations[index-1]
                
                if let preKnot = preLocation.knot.toDouble(), let knot = location.knot.toDouble() {
                    if knot < 2 && preKnot >= 2 {
                        let pointLocation = LocationData(time: location.time,
                                                         latitude: location.latitude,
                                                         longitude: location.longitude,
                                                         kmh: location.kmh, knot: location.knot,
                                                         sequence: index)
                        
                        let point = MapPoint(longitude: lon, latitude: lat)
                        let mapPin = KakaoMapPin(title: "\(pointLocation.kmh) km/h", subtitle: "\(pointLocation.knot) knot", mapPoint: point, locationData: pointLocation, dmsType: .D)
                        mapPins.append(mapPin)

                        
                        if let lat = pointLocation.latitude.toDouble(),
                            let lon = pointLocation.longitude.toDouble() {
                            print("\(pointLocation.sequence). lat: \(String.DtoDM(with: lat)) / lon: \(String.DtoDM(with: lon))")
                        }
                    }
                }
            }
        }
        
        mapPinItems.value = mapPins
        self.mapPins = mapPins
    }
}
