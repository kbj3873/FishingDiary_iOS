//
//  RecordKakaoMapView.swift
//  SeaThermo
//
//  Created by Antigravity on 2026/02/10.
//

import SwiftUI
import CoreLocation
import KakaoMapsSDK

// MARK: - 카카오맵 외부 제어 액션
enum KakaoMapAction: Equatable {
    case zoomIn
    case zoomOut
    case moveToUserLocation
    case clearMap
}


struct RecordKakaoMapView: UIViewControllerRepresentable {
    
    @Binding var mapLineInfo: MapLineInfo
    @Binding var shouldCleanup: Bool
    @Binding var mapAction: KakaoMapAction?
    @Binding var markers: [FishingRecordViewModel.StateChangeMarker]
    @Binding var photoMarkers: [FishingRecordViewModel.PhotoMarker]
    @Binding var boundaryMarkers: [FishingRecordViewModel.BoundaryMarker]
    @Binding var fishingState: FDAppManager.FishingState
    @Binding var userLocation: CLLocation?
    
    var getLocationList: () -> [LocationInfo]
    
    // 정리(Cleanup)를 위한 코디네이터
    class Coordinator: NSObject {
        var parent: RecordKakaoMapView
        var controller: RecordKakaoMapViewController?
        
        init(_ parent: RecordKakaoMapView) {
            self.parent = parent
        }
        
        func cleanup() {
            controller?.cleanup()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> RecordKakaoMapViewController {
        let vc = RecordKakaoMapViewController()
        context.coordinator.controller = vc
        return vc
    }
    
    func updateUIViewController(_ uiViewController: RecordKakaoMapViewController, context: Context) {
        // 경로선 업데이트
        uiViewController.updateMapLine(mapLineInfo.previousLocation, mapLineInfo.currentLocation, getLocationList: getLocationList)
        
        // 마커 업데이트
        uiViewController.updateMarkers(markers)
        uiViewController.updatePhotoMarkers(photoMarkers)
        uiViewController.updateBoundaryMarkers(boundaryMarkers)
        
        // 사용자 위치 업데이트 (모니터링)
        if let location = userLocation {
            uiViewController.updateCurrentLocation(location)
        }
        
        if shouldCleanup {
            context.coordinator.cleanup()
            Task { @MainActor in
                self.shouldCleanup = false
            }
        }
        
        // MARK: 외부 액션 (Zoom, Move 등) 처리
        if let action = mapAction {
            if let map = uiViewController.controller?.getView("mapview") as? KakaoMap {
                switch action {
                case .zoomIn:
                    let currentZoom = map.zoomLevel
                    if currentZoom < 21 { // 카카오맵 최대 줌레벨
                        let cameraUpdate = CameraUpdate.make(target: map.getPosition(CGPoint(x: map.viewRect.width / 2, y: map.viewRect.height / 2)), zoomLevel: currentZoom + 1, mapView: map)
                        map.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 300))
                    }
                case .zoomOut:
                    let currentZoom = map.zoomLevel
                    if currentZoom > 0 {
                        let cameraUpdate = CameraUpdate.make(target: map.getPosition(CGPoint(x: map.viewRect.width / 2, y: map.viewRect.height / 2)), zoomLevel: currentZoom - 1, mapView: map)
                        map.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 300))
                    }
                case .moveToUserLocation:
                    if let location = userLocation {
                        let targetPoint = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
                        let cameraUpdate = CameraUpdate.make(target: targetPoint, zoomLevel: 15, mapView: map) // 기본 15 레벨
                        map.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 300))
                    }
                case .clearMap:
                    uiViewController.cleanup()
                }
            }
            // 액션 처리 후 리셋
            Task { @MainActor in
                self.mapAction = nil
            }
        }
    }
}
