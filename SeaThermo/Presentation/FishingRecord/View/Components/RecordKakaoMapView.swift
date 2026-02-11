//
//  RecordKakaoMapView.swift
//  SeaThermo
//
//  Created by Antigravity on 2026/02/10.
//

import SwiftUI
import CoreLocation

struct RecordKakaoMapView: UIViewControllerRepresentable {
    
    @Binding var mapLineInfo: MapLineInfo
    @Binding var shouldCleanup: Bool
    @Binding var markers: [FishingRecordViewModel.StateChangeMarker]
    @Binding var photoMarkers: [FishingRecordViewModel.PhotoMarker]
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
        
        // 사용자 위치 업데이트 (모니터링)
        if let location = userLocation {
            uiViewController.updateCurrentLocation(location)
        }
        
        if shouldCleanup {
            context.coordinator.cleanup()
            DispatchQueue.main.async {
                self.shouldCleanup = false
            }
        }
    }
}
