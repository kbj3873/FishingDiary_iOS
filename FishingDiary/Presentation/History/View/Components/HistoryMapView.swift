import SwiftUI
import MapKit

// 히스토리 지도용 마커 모델
struct HistoryPhotoMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let thumbnailPath: String
    let title: String // e.g., "지점 #1"
    let timeString: String // e.g., "17:40"
}

struct HistoryMapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var polylines: [FishingPolyline]
    @Binding var markers: [HistoryPhotoMarker]
    @Binding var stateMarkers: [FishingRecordViewModel.StateChangeMarker]
    @Binding var stateMarkerInfos: [HistoryDetailViewModel.HistoryStateMarkerInfo] // 상태 마커 상세 정보
    @Binding var selectedMarker: HistoryDetailViewModel.SelectedMarkerInfo?
    
    // 줌 레벨 조정 등을 위한 Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false 
        mapView.isPitchEnabled = false
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // ... (생략, 기존과 동일) ...
        // 1. 경로 그리기 (Polyline)
        updatePolyline(on: uiView)
        
        // 2. 마커 표시 (Annotations)
        updateAnnotations(on: uiView)
        
        // 3. 카메라 이동
        if !polylines.isEmpty {
             // ...
             let allCoordinates = polylines.flatMap { polyline -> [CLLocationCoordinate2D] in
                let count = polyline.pointCount
                var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: count)
                polyline.getCoordinates(&coords, range: NSRange(location: 0, length: count))
                return coords
            }
            if !allCoordinates.isEmpty {
                let region = regionFor(coordinates: allCoordinates)
                uiView.setRegion(region, animated: true)
            }
        } else if !markers.isEmpty {
             let coords = markers.map { $0.coordinate }
             let region = regionFor(coordinates: coords)
             uiView.setRegion(region, animated: true)
        }
    }
    
    private func updatePolyline(on mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlays(polylines)
    }
    
    private func updateAnnotations(on mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        
        // 사진 마커 추가
        for marker in markers {
            let annotation = PhotoAnnotation()
            annotation.coordinate = marker.coordinate
            annotation.thumbnailPath = marker.thumbnailPath
            annotation.title = "조과물"
            mapView.addAnnotation(annotation)
        }
        
        // 상태 변경 마커 추가
        for marker in stateMarkers {
            let annotation = FishingStateAnnotation()
            annotation.coordinate = marker.coordinate
            annotation.state = marker.state
            // 타이틀에 상태명 설정 (e.g. "이동")
            switch marker.state {
            case .moving: annotation.title = "이동"
            case .drifting: annotation.title = "탐색"
            case .fishing: annotation.title = "낚시"
            }
            mapView.addAnnotation(annotation)
        }
    }
    
    // ... (regionFor 메서드 생략) ...
    private func regionFor(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else { return MKCoordinateRegion() }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let latDelta = max((maxLat - minLat) * 1.5, 0.005)
        let lonDelta = max((maxLon - minLon) * 1.5, 0.005)
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        return MKCoordinateRegion(center: center, span: span)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: HistoryMapView
        
        init(_ parent: HistoryMapView) {
            self.parent = parent
        }
        
        // ... (rendererFor, viewFor 메서드 생략, 기존 로직 유지하되 didSelect 추가) ...
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let fishingPolyline = overlay as? FishingPolyline {
                let renderer = MKPolylineRenderer(polyline: fishingPolyline)
                renderer.strokeColor = fishingPolyline.lineColor ?? .blue
                renderer.lineWidth = 4
                return renderer
            }
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            if let photoAnnotation = annotation as? PhotoAnnotation {
                return photoAnnotationView(for: photoAnnotation, in: mapView)
            }
            
             if let fishingAnnotation = annotation as? FishingStateAnnotation {
                return fishingStateAnnotationView(for: fishingAnnotation, in: mapView)
            }
            
            return nil
        }
        
        private func photoAnnotationView(for annotation: PhotoAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
            let identifier = "HistoryPhotoMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = false
            } else {
                view?.annotation = annotation
            }
            
            // 썸네일 이미지 생성 로직
            if let thumbnailPath = annotation.thumbnailPath {
                let fileURL = URL(fileURLWithPath: thumbnailPath)
                
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    let imageSize: CGFloat = 40
                    let borderWidth: CGFloat = 2
                    let cornerRadius: CGFloat = 8
                    let totalSize = imageSize + (borderWidth * 2)
                    
                    let size = CGSize(width: imageSize, height: imageSize)
                    UIGraphicsBeginImageContextWithOptions(size, false, 0)
                    image.draw(in: CGRect(origin: .zero, size: size))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let resized = resizedImage {
                        let rendererSize = CGSize(width: totalSize, height: totalSize)
                        let renderer = UIGraphicsImageRenderer(size: rendererSize)
                        let finalImage = renderer.image { ctx in
                            let borderColor = UIColor(hex: "#10B981")
                            ctx.cgContext.setFillColor(borderColor.cgColor)
                            let borderPath = UIBezierPath(
                                roundedRect: CGRect(origin: .zero, size: rendererSize),
                                cornerRadius: cornerRadius + borderWidth
                            )
                            borderPath.fill()
                            
                            let imageRect = CGRect(x: borderWidth, y: borderWidth, width: imageSize, height: imageSize)
                            let clipPath = UIBezierPath(roundedRect: imageRect, cornerRadius: cornerRadius)
                            clipPath.addClip()
                            resized.draw(in: imageRect)
                        }
                        view?.image = finalImage
                        view?.centerOffset = CGPoint(x: 0, y: -totalSize / 2)
                    }
                }
            }
            return view
        }
        
        private func fishingStateAnnotationView(for annotation: FishingStateAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
            let identifier = "HistoryStateMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = false
            } else {
                view?.annotation = annotation
            }
            
            switch annotation.state {
            case .moving:
                view?.image = UIImage(named: "ic_map_marker_blue")
            case .drifting:
                view?.image = UIImage(named: "ic_map_marker_orange")
            case .fishing:
                view?.image = UIImage(named: "ic_map_marker_red")
            case .none:
                break
            }
            return view
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // 1. 사진 마커 선택 시
            if let photoAnnotation = view.annotation as? PhotoAnnotation,
               let thumbnailPath = photoAnnotation.thumbnailPath {
                
                if let marker = parent.markers.first(where: { $0.thumbnailPath == thumbnailPath }) {
                    withAnimation {
                        // SelectedMarkerInfo 생성
                        parent.selectedMarker = HistoryDetailViewModel.SelectedMarkerInfo(
                            title: marker.title,
                            timeString: marker.timeString,
                            thumbnailPath: marker.thumbnailPath,
                            coordinate: marker.coordinate,
                            state: nil
                        )
                        
                        let region = MKCoordinateRegion(center: marker.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                        mapView.setRegion(region, animated: true)
                    }
                }
            }
            // 2. 상태 마커 선택 시
            else if let stateAnnotation = view.annotation as? FishingStateAnnotation {
                withAnimation {
                    // stateMarkerInfos에서 좌표 기준으로 일치하는 정보 조회
                    if let markerInfo = parent.stateMarkerInfos.first(where: {
                        abs($0.coordinate.latitude - stateAnnotation.coordinate.latitude) < 0.0001 &&
                        abs($0.coordinate.longitude - stateAnnotation.coordinate.longitude) < 0.0001
                    }) {
                        parent.selectedMarker = HistoryDetailViewModel.SelectedMarkerInfo(
                            title: markerInfo.title,
                            timeString: markerInfo.timeString,
                            thumbnailPath: nil,
                            coordinate: markerInfo.coordinate,
                            state: markerInfo.state
                        )
                    } else {
                        // Fallback: 기본 정보 사용
                        let title = stateAnnotation.title ?? "상태 변경"
                        parent.selectedMarker = HistoryDetailViewModel.SelectedMarkerInfo(
                            title: title,
                            timeString: "",
                            thumbnailPath: nil,
                            coordinate: stateAnnotation.coordinate,
                            state: stateAnnotation.state
                        )
                    }
                    
                    let region = MKCoordinateRegion(center: stateAnnotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                    mapView.setRegion(region, animated: true)
                }
            }
        }
    }
}
