//
//  AppleMapViewRepresentable.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/23/25.
//

import SwiftUI
import MapKit

struct AppleMapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var polylines: [MKPolyline]
    @Binding var annotations: [MapPin]
    @Binding var selectedAnnotation: MapPin?
    @Binding var shouldCleanup: Bool // 정리 트리거
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // 3D 기능 비활성화 (성능 개선)
        mapView.mapType = .standard
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        context.coordinator.mapView = mapView   // coordinator에 저장
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // cleanup 플래그가 true면 즉시 정리
        if shouldCleanup {
            context.coordinator.cleanup()
            return
        }
        
        // Region 업데이트
        if context.coordinator.shouldUpdateRegion(newRegion: region, currentRegion: mapView.region) {
            mapView.setRegion(region, animated: true)
        }
        
        // Polylines 업데이트
        if context.coordinator.shouldUpdatePolylines(current: mapView.overlays, new: polylines) {
            mapView.removeOverlays(mapView.overlays)
            if !polylines.isEmpty {
                mapView.addOverlays(polylines)
            }
        }
        
        // Annotation 업데이트
        let currentAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        if context.coordinator.shouldUpdateAnnotations(current: currentAnnotations, new: annotations) {
            mapView.removeAnnotations(currentAnnotations)
            if !annotations.isEmpty {
                mapView.addAnnotations(annotations)
            }
            
        }
    }
    
    // 메모리 정리
    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        // Delegate 제거
        uiView.delegate = nil
        
        // 모든 오버레이 제거
        uiView.removeOverlays(uiView.overlays)
        
        // 모든 annotation 제거
        let annotations = uiView.annotations
        uiView.removeAnnotations(annotations)
        
        // 렌더링 중지
        uiView.showsUserLocation = false
        
        print("release MKMapView resources")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: AppleMapViewRepresentable
        weak var mapView: MKMapView?
        
        // 이전 데이터 캐싱
        private var lastRegion: MKCoordinateRegion?
        private var lastPolylineCount: Int = 0
        private var lastAnnotationCount: Int = 0
        private var isCleanedUp = false
        
        init(_ parent: AppleMapViewRepresentable) {
            self.parent = parent
        }
        
        // 메모리 정리
        deinit {
            print("Coordinator deinit")
        }
        
        // 명시적 정리 메서드
        func cleanup() {
            guard !isCleanedUp, let mapView = mapView else { return }
            
            print("Map 리소스 정리 시작")
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    // Delegate 제거
                    mapView.delegate = nil
                    
                    // 모든 오버레이 제거
                    mapView.removeOverlays(mapView.overlays)
                    
                    // 모든 Annotation 제거
                    let annotations = mapView.annotations.filter { !($0 is MKUserLocation) }
                    mapView.removeAnnotations(annotations)
                    
                    // 사용자 위치 추적 중기
                    mapView.showsUserLocation = false
                    
                    self.isCleanedUp = true
                    print("Map 리소스 정리 완료")
                }
            }
        }
        
        // Region 업데이트 필요 여부 확인
        func shouldUpdateRegion(newRegion: MKCoordinateRegion, currentRegion: MKCoordinateRegion) -> Bool {
            guard newRegion.center.latitude != 0 && newRegion.center.longitude != 0 else {
                return false
            }
            
            if let last = lastRegion {
                let latDiff = abs(last.center.latitude - newRegion.center.latitude)
                let lonDiff = abs(last.center.longitude - newRegion.center.longitude)
                let spanLatDiff = abs(last.span.latitudeDelta - newRegion.span.latitudeDelta)
                let spanLonDiff = abs(last.span.longitudeDelta - newRegion.span.longitudeDelta)
                
                if latDiff < 0.0001 && lonDiff < 0.0001 &&
                    spanLatDiff < 0.0001 && spanLonDiff < 0.0001 {
                    return false
                }
            }
            
            lastRegion = newRegion
            return true
        }
        
        // Polylines 업데이트 필요 여부 확인
        func shouldUpdatePolylines(current: [MKOverlay], new: [MKPolyline]) -> Bool {
            let count = new.count
            if lastPolylineCount != count {
                lastPolylineCount = count
                return true
            }
            return false
        }
        
        // Annotations 업데이트 필요 여부 확인
        func shouldUpdateAnnotations(current: [MKAnnotation], new: [MKAnnotation]) -> Bool {
            let count = new.count
            if lastAnnotationCount != count {
                lastAnnotationCount = count
                return true
            }
            return false
        }
        
        // Polyline 렌더링
        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = (polyline.title == "point") ? UIColor.red:UIColor.blue
            renderer.lineWidth = 2.0
            return renderer
        }
        
        // Annotation View
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let mapPin = annotation as? MapPin else {
                return nil
            }
            let identifier = "point"
            //print("draw annotation view title: \(String(describing: antn.title))") // > testcode
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKPinAnnotationView(annotation: mapPin, reuseIdentifier: identifier)
            annotationView.annotation = mapPin
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            annotationView.image = mapPin.image
            
            let button = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = button
            
            return annotationView
        }
        
        // Annotation 선택 이벤트
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let mapPin = view.annotation as? MapPin {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.selectedAnnotation = mapPin
                }
            }
        }
        // Annotation 선택 해제
        func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.selectedAnnotation = nil
            }
        }
    }
}
