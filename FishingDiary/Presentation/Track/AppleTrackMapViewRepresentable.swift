//
//  AppleTrackMapViewRepresentable.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/29/25.
//

import UIKit
import MapKit
import SwiftUI

struct AppleTrackMapViewRepresentable: UIViewRepresentable {
    @Binding var mapLineInfo: MapLineInfo
    @Binding var shouldCleanup: Bool
    let getLocationList: () -> [LocationInfo]   // 속도 확인용
    
    @Binding var coordinator: Coordinator?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.mapType = .standard
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        DispatchQueue.main.async {
            coordinator = context.coordinator
        }
        context.coordinator.mapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("updateUIView: shouldCleanup = \(shouldCleanup ? "true":"false")")
        if shouldCleanup {
            context.coordinator.cleanup()
            return
        }
        
        // 새로운 경로선 추가
        let currentMapLine = mapLineInfo
        if currentMapLine.previousLocation.coordinate.latitude != 0 &&
            currentMapLine.currentLocation.coordinate.latitude != 0 {
            context.coordinator.addPolyline(
                from: currentMapLine.previousLocation,
                to: currentMapLine.currentLocation
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: AppleTrackMapViewRepresentable
        weak var mapView: MKMapView?
        private var isCleanedUp = false
        private var hasSetInitialRegion = false // 초기 region 설정
        
        init(_ parent: AppleTrackMapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            // 첫 위치 업데이트 시 지도 확대
            if !hasSetInitialRegion, userLocation.coordinate.latitude != 0 {
                hasSetInitialRegion = true
                
                // 현재 위치 중심으로 region 설정 (확대)
                let region = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
                
                // region 설정 후 추적 모드 활성화
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    mapView.setUserTrackingMode(.follow, animated: true)
//                    print("사용자 추적 모드 활성화")
//                }
                
                print("초기 위치 : \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
            }
        }
        
        // polyline 추가
        func addPolyline(from: CLLocation, to: CLLocation) {
            guard let mapView = mapView else { return }
            
            var coordinates = [from.coordinate, to.coordinate]
            let polyline = MKPolyline(coordinates: &coordinates, count: 2)
            mapView.addOverlay(polyline)
        }
        
        // polyline 렌더링
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            
            let renderer = MKPolylineRenderer(overlay: polyline)
            
            // 속도에 따라 색상 변경
            if let lastLocation = parent.getLocationList().last {
                let speed = Float(lastLocation.locationInfo.speed * 3.6)
                renderer.strokeColor = (speed > FDAppManager.pointVelocity) ? .blue : .red
            } else {
                renderer.strokeColor = .blue
            }
            
            renderer.lineWidth = 2.0
            return renderer
        }
        
        func cleanup() {
            guard !isCleanedUp, let mapView = mapView else { return }
            
            print("AppleTrackMap 리소스 정리 시작")
            
            mapView.delegate = nil
            mapView.removeOverlays(mapView.overlays)
            mapView.showsUserLocation = false
            mapView.userTrackingMode = .none
            
            isCleanedUp = true
            print("AppleTrackMap 리소스 정리 완료")
        }
        
        deinit {
            cleanup()
            print("AppleTrackMapViewRepresentable.Coordinator deinit")
        }
    }
}
