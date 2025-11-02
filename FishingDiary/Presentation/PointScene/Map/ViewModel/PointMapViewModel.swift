//
//  PointMapViewModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/14.
//

import Foundation
import Combine
import MapKit

protocol PointMapViewModelInput {
    func viewDidLoad()
}

protocol PointMapViewModelOutput {
    var region: MKCoordinateRegion { get }
    var mapPins: [MapPin] { get }
    var polyLines: [MKPolyline] { get }
    
    var regionItem: CurrentValueSubject<MKCoordinateRegion, Never> { get }
    var mapPinItems: CurrentValueSubject<[MapPin], Never> { get }
    var polyLineItems: CurrentValueSubject<[MKPolyline], Never> { get }
}

typealias PointMapViewModelProtocol = PointMapViewModelInput & PointMapViewModelOutput

final class PointMapViewModel: ObservableObject {
    private let pointData: PointData
    private let pointMapUseCase: PointMapUseCase
    
    @Published var region = MKCoordinateRegion()
    @Published var mapPins = [MapPin]()
    @Published var polyLines = [MKPolyline]()
    @Published private(set) var isLoaded = false
    
    var regionItem = CurrentValueSubject<MKCoordinateRegion, Never>(MKCoordinateRegion())
    var mapPinItems = CurrentValueSubject<[MapPin], Never>([])
    var polyLineItems = CurrentValueSubject<[MKPolyline], Never>([])
    
    init(pointData: PointData, pointMapUseCase: PointMapUseCase) {
        self.pointData = pointData
        self.pointMapUseCase = pointMapUseCase
    }
    
    deinit {
        print("PointMapViewModel deinit")
    }
    
    private func loadLocations(pointData: PointData) {
        guard !isLoaded else { return }
        
        pointMapUseCase.excute(pointData: pointData, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let locations):
                self.setPolyLinesValue(locations: locations)
                self.setRegionValue(locations: locations)
                self.setAnnotationsValue(locations: locations)
                self.isLoaded = true
            case .failure(let error):
                self.handleError(error: error)
            }
        })
    }
    
    private func handleError(error: FileStorageError) {
        print("point date error - \(error.description)")
    }
}

extension PointMapViewModel: PointMapViewModelProtocol {
    
    func viewDidLoad() {
        loadLocations(pointData: pointData)
    }
}

// MARK: convert map data
extension PointMapViewModel {
    private func setRegionValue(locations: [LocationData]) {
        var latitudeList = [Double]()
        var longitudeList = [Double]()
        for location in locations {
            if let lat = Double(location.latitude), let lon = Double(location.longitude) {
                latitudeList.append(lat)
                longitudeList.append(lon)
            }
        }
        
        let minLatitude = latitudeList.min()!
        let maxLatitude = latitudeList.max()!
        let minLongitude = longitudeList.min()!
        let maxLongitude = longitudeList.max()!
        let centerlocation = CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude) * 0.5,
                                                    longitude: (maxLongitude + minLongitude) * 0.5)
        
        let minLocation = CLLocationCoordinate2D(latitude: minLatitude, longitude: minLongitude)
        let maxLocation = CLLocationCoordinate2D(latitude: maxLatitude, longitude: maxLongitude)
        
        let distance = CLLocation(latitude: minLocation.latitude, longitude: minLocation.longitude)
            .distance(from: CLLocation(latitude: maxLocation.latitude, longitude: maxLocation.longitude))
        let region = MKCoordinateRegion(center: centerlocation, latitudinalMeters: 2 * distance, longitudinalMeters: 2 * distance)
        
        regionItem.value = region
        self.region = region
    }
    
    private func setAnnotationsValue(locations: [LocationData]) {
        var mapPins = [MapPin]()
        
        for (index, location) in locations.enumerated() {
            
            guard let lat = Double(location.latitude),
                    let lon = Double(location.longitude),
                    let img = UIImage(named: "point") else {
                return
            }
            
            if index > 0 {
                let preLocation = locations[index-1]
                
                if let preKnot = preLocation.knot.toDouble(), let knot = location.knot.toDouble() {
                    if knot < 2 && preKnot >= 2 {
                        
                        let point = CLLocationCoordinate2D(
                            latitude: lat,
                            longitude: lon
                        )
                        
                        let pointLocation = LocationData(time: location.time,
                                                         latitude: location.latitude,
                                                         longitude: location.longitude,
                                                         kmh: location.kmh, knot: location.knot,
                                                         sequence: index)
                        
                        let annotation = MapPin(title: "\(pointLocation.kmh) km/h", subtitle: "\(pointLocation.knot) knot", coordinate: point, locationData: pointLocation, image: img, dmsType: .D)
                        mapPins.append(annotation)

                        
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
    
    private func setPolyLinesValue(locations: [LocationData]) {
        var polyLines = [MKPolyline]()
        
        var area = [CLLocationCoordinate2D]()
        for location in locations {
            if let lat = Double(location.latitude), let lon = Double(location.longitude) {
                let point = CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lon
                )
                area.append(point)
                
                if area.count > 1 {
                    let polyline = MKPolyline(coordinates: &area, count: area.count)
                    if let kmh = Float(location.kmh), let knot = Float(location.knot) {
                        polyline.kmh = kmh
                        polyline.knot = knot
                        polyline.color = (kmh < FDAppManager.pointVelocity) ? UIColor.red:UIColor.blue
                        polyline.title = (kmh < FDAppManager.pointVelocity) ? "point":"move"
                        //print("area count: \(area.count)")
                        //print("make polyline line kmh: \(polyline.kmh) knot: \(polyline.knot) color: \((polyline.color == UIColor.red ? "red":"blue"))")    // > testcode
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
        
        polyLineItems.value = polyLines
        self.polyLines = polyLines
    }
}
