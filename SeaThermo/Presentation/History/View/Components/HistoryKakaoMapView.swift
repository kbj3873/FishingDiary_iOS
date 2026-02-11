//
//  HistoryKakaoMapView.swift
//  SeaThermo
//
//  Created by Antigravity on 2026/02/10.
//

import SwiftUI
import CoreLocation

struct HistoryKakaoMapView: UIViewControllerRepresentable {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var polylines: [HistoryFishingPolyline]
    @Binding var markers: [HistoryPhotoMarker]
    @Binding var stateMarkers: [FishingRecordViewModel.StateChangeMarker]
    @Binding var stateMarkerInfos: [HistoryDetailViewModel.HistoryStateMarkerInfo]
    @Binding var selectedMarker: HistoryDetailViewModel.SelectedMarkerInfo?
    @Binding var isMapInitialized: Bool // 지도 초기화 여부 (Zoom to Fit 1회 제한용)
    
    func makeUIViewController(context: Context) -> HistoryKakaoMapViewController {
        let vc = HistoryKakaoMapViewController()
        vc.initialCenter = centerCoordinate
        vc.isMapInitialized = isMapInitialized
        vc.onMapInitialized = {
            DispatchQueue.main.async {
                self.isMapInitialized = true
            }
        }
        vc.onMarkerTapped = { uuid in
            context.coordinator.handleMarkerTap(uuid: uuid, viewController: vc)
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: HistoryKakaoMapViewController, context: Context) {
        // 초기화 상태 동기화
        uiViewController.isMapInitialized = isMapInitialized
        
        // 데이터 업데이트
        uiViewController.updateData(center: centerCoordinate,
                                    polylines: polylines,
                                    photoMarkers: markers,
                                    stateMarkerInfos: stateMarkerInfos)
        
        // 코디네이터 업데이트
        context.coordinator.parent = self
        context.coordinator.viewController = uiViewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: HistoryKakaoMapView
        weak var viewController: HistoryKakaoMapViewController?
        
        init(_ parent: HistoryKakaoMapView) {
            self.parent = parent
        }
        
        func handleMarkerTap(uuid: UUID, viewController: HistoryKakaoMapViewController) {
            // UUID를 기반으로 배열에서 마커 정보 찾기
            
            // 1. 사진 마커 확인
            if let photoMarker = parent.markers.first(where: { $0.id == uuid }) {
                // SelectedMarkerInfo로 변환
                let info = HistoryDetailViewModel.SelectedMarkerInfo(
                    title: photoMarker.title,
                    timeString: photoMarker.timeString,
                    thumbnailPath: photoMarker.thumbnailPath,
                    coordinate: photoMarker.coordinate,
                    state: nil
                )
                
                withAnimation {
                    parent.selectedMarker = info
                }
                return
            }
            
            // 2. 상태 정보 마커 확인
            // HistoryDetailViewModel에 stateMarkerInfos가 있음.
            // 하지만 HistoryKakaoMapViewController는 POI ID로 stateMarkers(FishingRecordViewModel.StateChangeMarker) ID를 사용할 수도 있음.
            // ID 매칭이 필요함.
            // HistoryStateMarkerInfo가 'id'를 가짐. StateChangeMarker와 일치하는가?
            // ViewModel에서 둘 다 생성되지만 ID는 각각 생성됨:
            //   newStateMarkers.append(StateChangeMarker(..., id: UUID()...))
            //   newStateMarkerInfos.append(HistoryStateMarkerInfo(..., id: UUID()...))
            //   잠깐, StateChangeMarker는 'let id = UUID()'를 가짐. init에서 ID를 제어하기 어려움.
            // StateChangeMarker 구조체를 다시 확인 필요.
            //
            // FishingRecordViewModel.StateChangeMarker 확인:
            // struct StateChangeMarker: Identifiable { let id = UUID(); ... }
            // init 시 새로운 UUID 생성됨.
            
            // HistoryDetailViewModel에서:
            /*
            newStateMarkers.append(FishingRecordViewModel.StateChangeMarker(coordinate: coord, state: markerState))
            // 여기서 하나의 UUID 생성.
            
            let info = HistoryStateMarkerInfo(...)
            // 여기서 또 다른 UUID 생성.
            */
            // 문제: ID가 일치하지 않음. POI가 StateChangeMarker.id를 사용하면 POI ID로 info를 조회할 수 없음.
            
            // 해결책: 둘을 연결할 방법이 필요함.
            // 또는, VC에서 마커를 그릴 때 `stateMarkerInfos`를 사용해야 함(좌표, 상태, ID 포함).
            // `stateMarkerInfos`가 있다면 HistoryDetailViewModel의 `stateMarkers` 배열은 중복일 수 있음.
            // 단, MapView가 Recording VM의 공유 타입을 기대할 수 있음.
            // Apple Map View(HistoryMapView)는 그리기에 `stateMarkers`를, 정보 조회에 `stateMarkerInfos`를 사용함.
            
            // HistoryMapView (Apple 버전) 사용 예시:
            /*
            HistoryMapView(
                ...
                stateMarkers: $viewModel.stateMarkers,
                stateMarkerInfos: $viewModel.stateMarkerInfos, // 둘 다 받음
                ...
            )
            */
            // 암시적으로 Apple Map View는 좌표를 사용하여 가장 가까운 것을 찾거나 어노테이션 매칭을 할 수 있음.
            // Kakao 버전을 새로 구현 중이므로 변경/최적화 가능.
            //
            // 최선의 수정: `stateMarkers` 대신 `stateMarkerInfos`를 Controller에 전달하여 마커를 그리게 함.
            // `stateMarkerInfos`는 좌표 + 상태 + ID + 제목 + 시간을 포함하므로 완벽함.
            // `FishingRecordViewModel.StateChangeMarker`는 단순히 (좌표, 상태)만 가짐.
            
            // 따라서 HistoryKakaoMapViewController에서는 `stateMarkerInfos`를 사용하여 상태 마커를 그려야 함.
            
            if let stateInfo = parent.stateMarkerInfos.first(where: { $0.id == uuid }) {
                let info = HistoryDetailViewModel.SelectedMarkerInfo(
                    title: stateInfo.title,
                    timeString: stateInfo.timeString,
                    thumbnailPath: nil,
                    coordinate: stateInfo.coordinate,
                    state: stateInfo.state
                )
                withAnimation {
                    parent.selectedMarker = info
                }
            }
        }
    }
}
