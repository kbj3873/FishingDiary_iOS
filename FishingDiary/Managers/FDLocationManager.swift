//
//  FDLocationManager.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit
import Combine
import CoreLocation

enum LocationError: Error {
    case trackingError
}

class FDLocationManager: NSObject {
    // MARK: - Variables
    static let shared = FDLocationManager()
    
    var sequenceNum: Int = 0
    
    let locationManager = CLLocationManager()
    var latitude = ""
    var longitude = ""
    // > combine
    var curMapLine = CurrentValueSubject<(MapLineInfo), Never>(MapLineInfo(CLLocation(latitude: 0.0, longitude: 0.0), CLLocation(latitude: 0.0, longitude: 0.0)))
    
    var locationList: [LocationInfo] = []
    
    var saveComplete: (([LocationData]) -> Void)?
    
    override init() {
        super.init()
        initLocation()
    }
    
    func initLocation() {
        latitude = ""
        longitude = ""
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func startTracking() {
        sequenceNum = 0
        latitude = ""
        longitude = ""
        //completionHandler = completion
        locationPermission() { success in
            if success {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        
        sequenceNum = 0
        
        if locationList.count > 0 {
            var locations = [LocationData]()
            for data in self.locationList {
                locations.append(data.locationData)
            }
            
            if let completion = saveComplete {
                completion(locations)
            }
            
            locationList = []
        }
    }
    
    func addLocation(location: CLLocation) {
        let latitude = String(format: "%.6f", location.coordinate.latitude)
        let longitude = String(format: "%.6f", location.coordinate.longitude)
        let kmh = String(format: "%.2f", location.speed * 3.6)
        let knot = String(format: "%.2f", location.speed * 1.944)
        
        sequenceNum += 1
        
        let locationData = LocationData(
            time: Date.todayString(),
            latitude: latitude,
            longitude: longitude,
            kmh: kmh,
            knot: knot,
            sequence: sequenceNum
        )
        
        let locationInfo = LocationInfo (
            locationData: locationData,
            locationInfo: location
        )
        
        locationList.append(locationInfo)
        
        print("location data : \(locationData)")
        let count = locationList.count
        if count >= FDAppManager.saveForPoints {
            let saveList = locationList[0...(count-2)]  // 배열의 마지막 정보만 남겨두고 앞의 개수만큼 저장
            var locations = [LocationData]()
            for data in saveList {
                locations.append(data.locationData)
            }
            
            if let completion = saveComplete {
                completion(locations)
            }
            
            if let location: LocationInfo = locationList.last {
                locationList = [location]
            }
        }
    }
    
    func locationPermission(access: Bool = true, completion: ((Bool) -> ())? = nil) {
        SCPrivacy.checkLocation(access: access) { status in
            switch status {
            case .use:
                self.locationManager.startUpdatingLocation()
                completion?(true)
                return
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                completion?(false)
            default:
                print("status is not use !!!")
                completion?(false)
                return
            }
            
        } moveSetting: { settingCallback in
            UIApplication.topViewController()?.showAlert(title: "권한안내", msg: "디바이스 설정 > 개인 정보 보호 > 위치 서비스 를 켜주세요.", "확인") { confirm in
            }
        }
    }
}

// MARK: - Delegate: CLLocationManagerDelegate
extension FDLocationManager: CLLocationManagerDelegate {
    /// 위치권한 상태 Delegate 함수(iOS 14 이상)
    /// - Parameter manager: CLLocationManager
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            // 허용
            print("허용")
            locationManager.startUpdatingLocation()
            
        case .restricted, .denied:
            // 사용할 수 없음, 거부
            print("사용할 수 없음, 거부")
        case .notDetermined:
            // 결정전
            print("notDetermined !!!")
        @unknown default:
            break
        }
    }
    
    /// 위치권한 상태 Delegate 함수(iOS 14 미만)
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - status: CLAuthorizationStatus
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // 허용
            print("허용")
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            // 사용할 수 없음, 거부
            print("사용할 수 없음, 거부")
        case .notDetermined:
            // 결정전
            print("notDetermined !!!")
        @unknown default:
            break
        }
    }
    
    /// 위치(위도,경도) 정보 함수
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - locations: 위도, 경도 정보
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first(where: { $0.horizontalAccuracy >= 0}) else {
            return
        }
        
        guard let previousLocation = locationList.last?.locationInfo else {
            self.addLocation(location: currentLocation)
            return
        }
        
        self.addLocation(location: currentLocation)
        
        // > combine
        let mapLine = MapLineInfo(previousLocation, currentLocation)
        self.curMapLine.send(mapLine)
    }
    
    /// 위치정보 에러 함수
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - error: Error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location update fail: \(error.localizedDescription)")
    }
}
