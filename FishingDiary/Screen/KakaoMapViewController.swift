//
//  KakaoMapViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit
import SnapKit

struct Point {
    var latitude: String
    var longtitude: String
    var time: String
    var velocity: String
    var fishingArea: Bool
}

class KakaoMapViewController: UIViewController {
    
    private let locMgr = FDLocationManager.shared
    
    private let mapView = MTMapView()
    private var latitude: String = ""
    private var longitude: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locMgr.locationPermission()
        locMgr.startTracking()

        self.initMapView()
        
    }
    
    private func initMapView() {
        mapView.delegate = self
        mapView.baseMapType = .standard
        mapView.showCurrentLocationMarker = true
        mapView.currentLocationTrackingMode = .onWithoutHeading
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Delegate
extension KakaoMapViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonLeftSideOf poiItem: MTMapPOIItem!) {
//        let info = stores[poiItem.tag]
//        showStoreInfo(info)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
//        let info = stores[poiItem.tag]
//        showStoreInfo(info)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonRightSideOf poiItem: MTMapPOIItem!) {
//        let info = stores[poiItem.tag]
//        showStoreInfo(info)
    }
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        guard mapView.showCurrentLocationMarker else {
            return
        }
        let lat = "\(mapCenterPoint.mapPointGeo().latitude)"
        let long = "\(mapCenterPoint.mapPointGeo().longitude)"
        
        print("mapView cur lat: \(lat)  long: \(long)")
    }
}

// MARK: - Extension UIViewController for show KakaoMapViewController
extension UIViewController {
    func showKakaoMapView() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KakaoMapViewController") as? KakaoMapViewController {
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }
    
}
