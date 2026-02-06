//
//  RecordMapView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/29/25.
//

import UIKit
import MapKit
import SwiftUI

struct RecordMapView: UIViewRepresentable {
    @Binding var mapLineInfo: MapLineInfo
    @Binding var shouldCleanup: Bool
    @Binding var markers: [FishingRecordViewModel.StateChangeMarker]
    @Binding var photoMarkers: [FishingRecordViewModel.PhotoMarker]
    @Binding var fishingState: FDAppManager.FishingState
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
        // print("updateUIView: shouldCleanup = \(shouldCleanup ? "true":"false")")
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
                to: currentMapLine.currentLocation,
                state: fishingState
            )
        }
        
        // 마커 업데이트 확인
        if markers.count > context.coordinator.lastMarkerCount {
            let newMarkers = markers.suffix(markers.count - context.coordinator.lastMarkerCount)
            for marker in newMarkers {
                context.coordinator.addMarker(marker)
            }
            context.coordinator.lastMarkerCount = markers.count
        }
        
        // 사진 마커 업데이트 확인
        if photoMarkers.count > context.coordinator.lastPhotoMarkerCount {
            let newPhotoMarkers = photoMarkers.suffix(photoMarkers.count - context.coordinator.lastPhotoMarkerCount)
            for photoMarker in newPhotoMarkers {
                context.coordinator.addPhotoMarker(photoMarker)
            }
            context.coordinator.lastPhotoMarkerCount = photoMarkers.count
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RecordMapView
        weak var mapView: MKMapView?
        var lastMarkerCount = 0
        var lastPhotoMarkerCount = 0
        private var isCleanedUp = false
        private var hasSetInitialRegion = false // 초기 region 설정
        
        init(_ parent: RecordMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            // 첫 위치 업데이트 시 지도 확대
            if !hasSetInitialRegion, userLocation.coordinate.latitude != 0 {
                hasSetInitialRegion = true
                
                // 현재 위치 중심으로 region 설정 (확대)
                let region = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 500, // 500m 반경 (더 확대)
                                                longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
                mapView.setUserTrackingMode(.follow, animated: true)
            }
        }
        
        // polyline 추가
        func addPolyline(from: CLLocation, to: CLLocation, state: FDAppManager.FishingState) {
            guard let mapView = mapView else { return }
            
            var coordinates = [from.coordinate, to.coordinate]
            // RecordFishingPolyline 사용 (색상 정보 포함)
            let polyline = RecordFishingPolyline(coordinates: &coordinates, count: 2)
            polyline.lineColor = getColor(for: state)
            mapView.addOverlay(polyline)
        }
        
        // 마커 추가
        func addMarker(_ marker: FishingRecordViewModel.StateChangeMarker) {
            guard let mapView = mapView else { return }
            
            let annotation = RecordFishingStateAnnotation()
            annotation.coordinate = marker.coordinate
            annotation.title = marker.state.rawValue
            annotation.state = marker.state
            mapView.addAnnotation(annotation)
        }
        
        // 사진 마커 추가
        func addPhotoMarker(_ photoMarker: FishingRecordViewModel.PhotoMarker) {
            guard let mapView = mapView else { return }
            
            let annotation = RecordPhotoAnnotation()
            annotation.coordinate = photoMarker.coordinate
            annotation.thumbnailPath = photoMarker.thumbnailPath
            mapView.addAnnotation(annotation)
        }
        
        // polyline 및 annotation 렌더링
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let fishingPolyline = overlay as? RecordFishingPolyline {
                let renderer = MKPolylineRenderer(overlay: fishingPolyline)
                renderer.strokeColor = fishingPolyline.lineColor ?? .blue
                renderer.lineWidth = 3.0
                return renderer
            }
            
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3.0
                return renderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 사진 마커 처리
            if let photoAnnotation = annotation as? RecordPhotoAnnotation {
                return photoAnnotationView(for: photoAnnotation, in: mapView)
            }
            
            guard let fishingAnnotation = annotation as? RecordFishingStateAnnotation else {
                return nil
            }
            
            let identifier = "FishingStateMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if view == nil {
                view = MKAnnotationView(annotation: fishingAnnotation, reuseIdentifier: identifier)
                view?.canShowCallout = false // 말풍선 끄기
            } else {
                view?.annotation = fishingAnnotation
            }
            
            // 상태별 이미지 설정
            switch fishingAnnotation.state {
            case .moving:
                view?.image = UIImage(named: "ic_map_marker_blue")
            case .drifting:
                view?.image = UIImage(named: "ic_map_marker_orange")
            case .fishing:
                view?.image = UIImage(named: "ic_map_marker_red")
            case .none:
                break
            }
            
            // 이미지 크기 조정 등 필요 시 추가 설정
            // view?.centerOffset = CGPoint(x: 0, y: -view!.frame.size.height / 2) // 핀 끝이 좌표에 오도록 조정
            
            return view
        }
        
        // 사진 마커 렌더링 - Figma 디자인: 둥근 모서리 사각형 + 초록색 테두리
        private func photoAnnotationView(for annotation: RecordPhotoAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
            let identifier = "PhotoMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = false
            } else {
                view?.annotation = annotation
            }
            
            // 썸네일 이미지 로드
            if let thumbnailPath = annotation.thumbnailPath {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(thumbnailPath)
                
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    // Figma 디자인 기준 썸네일 크기
                    let imageSize: CGFloat = 48
                    let borderWidth: CGFloat = 3
                    let cornerRadius: CGFloat = 10
                    let totalSize = imageSize + (borderWidth * 2)
                    
                    // 썸네일 크기로 조정
                    let size = CGSize(width: imageSize, height: imageSize)
                    UIGraphicsBeginImageContextWithOptions(size, false, 0)
                    image.draw(in: CGRect(origin: .zero, size: size))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    // 둥근 모서리 사각형 + 초록색 테두리 추가
                    if let resized = resizedImage {
                        let rendererSize = CGSize(width: totalSize, height: totalSize)
                        let renderer = UIGraphicsImageRenderer(size: rendererSize)
                        let finalImage = renderer.image { ctx in
                            // 초록색 테두리 배경 (Figma 디자인 색상)
                            let borderColor = UIColor(hex: "#10B981") // 초록색
                            ctx.cgContext.setFillColor(borderColor.cgColor)
                            let borderPath = UIBezierPath(
                                roundedRect: CGRect(origin: .zero, size: rendererSize),
                                cornerRadius: cornerRadius + borderWidth
                            )
                            borderPath.fill()
                            
                            // 이미지 영역 클리핑 및 그리기
                            let imageRect = CGRect(x: borderWidth, y: borderWidth, width: imageSize, height: imageSize)
                            let clipPath = UIBezierPath(roundedRect: imageRect, cornerRadius: cornerRadius)
                            clipPath.addClip()
                            resized.draw(in: imageRect)
                        }
                        view?.image = finalImage
                        // 좌표 지점이 썸네일 하단에 위치하도록 위로 이동
                        view?.centerOffset = CGPoint(x: 0, y: -totalSize * 2 / 3)
                    }
                } else {
                    // 이미지 로드 실패 시 기본 카메라 아이콘
                    view?.image = UIImage(systemName: "camera.fill")
                }
            }
            
            return view
        }
        
        // MARK: - Helper Methods
        private func getColor(for state: FDAppManager.FishingState) -> UIColor {
            switch state {
            case .moving:
                return UIColor(hex: "#2563EB") // Blue
            case .drifting:
                return UIColor(hex: "#F59E0B") // Orange
            case .fishing:
                return UIColor(hex: "#EF4444") // Red
            }
        }
        
        // MARK: - Map Control Methods
        func zoomIn() {
            guard let mapView = mapView else { return }
            var region = mapView.region
            region.span.latitudeDelta /= 2.0
            region.span.longitudeDelta /= 2.0
            mapView.setRegion(region, animated: true)
        }
        
        func zoomOut() {
            guard let mapView = mapView else { return }
            var region = mapView.region
            region.span.latitudeDelta *= 2.0
            region.span.longitudeDelta *= 2.0
            mapView.setRegion(region, animated: true)
        }
        
        func moveToUserLocation() {
            guard let mapView = mapView else { return }
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        
        func cleanup() {
            guard !isCleanedUp, let mapView = mapView else { return }
            
            print("RecordMapView 리소스 정리 시작")
            
            mapView.delegate = nil
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
            mapView.showsUserLocation = false
            mapView.userTrackingMode = .none
            
            isCleanedUp = true
            print("RecordMapView 리소스 정리 완료")
        }
        
        func clearMap() {
            guard let mapView = mapView else { return }
            
            print("RecordMapView 오버레이 및 마커 초기화")
            
            // 모든 경로 및 마커 제거
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
            
            // 카운터 초기화
            lastMarkerCount = 0
            lastPhotoMarkerCount = 0
            
            // 초기 위치 설정 플래그 리셋 (다음 기록 시작 시 다시 현재 위치로 줌인)
            hasSetInitialRegion = false
        }
        
        deinit {
            cleanup()
            print("RecordMapView.Coordinator deinit")
        }
    }
}

// MARK: - Custom Classes (Record Prefix 추가)
class RecordFishingPolyline: MKPolyline {
    var lineColor: UIColor?
}

class RecordFishingStateAnnotation: MKPointAnnotation {
    var state: FDAppManager.FishingState?
}

class RecordPhotoAnnotation: MKPointAnnotation {
    var thumbnailPath: String?
}
