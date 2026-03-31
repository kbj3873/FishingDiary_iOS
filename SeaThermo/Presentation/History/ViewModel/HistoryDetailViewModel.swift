import Foundation
import CoreLocation
import Combine
import UIKit
import MapKit

// MARK: - 백그라운드 지도 데이터 계산 결과
private struct HistoryMapDataResult {
    let polylines: [HistoryFishingPolyline]
    let markers: [HistoryPhotoMarker]
    let stateMarkers: [FishingRecordViewModel.StateChangeMarker]
    let stateMarkerInfos: [HistoryDetailViewModel.HistoryStateMarkerInfo]
    let centerCoordinate: CLLocationCoordinate2D

    static var empty: HistoryMapDataResult {
        HistoryMapDataResult(
            polylines: [],
            markers: [],
            stateMarkers: [],
            stateMarkerInfos: [],
            centerCoordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        )
    }
}

@MainActor
final class HistoryDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var dateString: String = ""
    @Published var startTimeString: String = "" // "HH:mm 출발"
    @Published var totalDistance: Double = 0.0 // km
    @Published var totalDuration: String = "00:00:00"
    
    @Published var polylines: [HistoryFishingPolyline] = []
    @Published var stateMarkers: [FishingRecordViewModel.StateChangeMarker] = []
    @Published var stateMarkerInfos: [HistoryStateMarkerInfo] = [] // 상태 마커 상세 정보
    @Published var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // 기본 서울
    @Published var markers: [HistoryPhotoMarker] = []
    
    // 상태 마커 상세 정보 (지점 번호 + 시간 포함)
    struct HistoryStateMarkerInfo: Identifiable {
        let id: UUID // 수정: 외부 주입 가능하도록 초기값 제거
        let title: String       // "지점 #N"
        let timeString: String  // "HH:mm"
        let coordinate: CLLocationCoordinate2D
        let state: FDAppManager.FishingState
    }
    
    struct SelectedMarkerInfo: Identifiable {
        let id = UUID()
        let title: String
        let timeString: String
        let thumbnailPath: String?
        let coordinate: CLLocationCoordinate2D
        let state: FDAppManager.FishingState? // 상태 마커일 경우 상태 정보
    }
    
    @Published var selectedMarker: SelectedMarkerInfo? = nil
    
    @Published var selectedImageIndex: Int = 0
    @Published var isImageViewerPresented: Bool = false
    
    // MARK: - Map State
    @Published var isMapInitialized: Bool = false // 지도 초기화 여부 (Zoom To Fit 1회 제한용)
    
    // MARK: - Properties
    private let sessionId: String
    private let useCase: FishingRecordUseCase
    private var records: [FishingRecord] = []
    
    // MARK: - Initializer
    init(sessionId: String, useCase: FishingRecordUseCase) {
        self.sessionId = sessionId
        self.useCase = useCase
    }
    
    // MARK: - Methods
    func onAppear() {
        fetchSessionMapData()
    }
    
    private func fetchSessionMapData() {
        Task {
            do {
                let allRecords = try await useCase.fetchAllRecords()
                let sessionId = self.sessionId
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

                // 필터링·정렬·지도 데이터 가공을 백그라운드에서 처리
                let (sortedRecords, mapResult) = await Task.detached(priority: .userInitiated) {
                    let filtered = allRecords.filter { $0.sessionId == sessionId }
                    let sorted = filtered.sorted { $0.date < $1.date }
                    let result = HistoryDetailViewModel.buildMapData(records: sorted, documentsURL: documentsURL)
                    return (sorted, result)
                }.value

                self.records = sortedRecords

                guard !sortedRecords.isEmpty else {
                    self.isMapInitialized = false
                    return
                }

                // 요약 데이터(가벼운 연산)는 메인 스레드에서
                self.setupSummaryData()

                // 지도 데이터 @Published 업데이트
                self.polylines = mapResult.polylines
                self.markers = mapResult.markers
                self.stateMarkers = mapResult.stateMarkers
                self.stateMarkerInfos = mapResult.stateMarkerInfos
                self.centerCoordinate = mapResult.centerCoordinate
                self.isMapInitialized = false

            } catch {
                print("Error fetching records: \(error)")
            }
        }
    }
    
    private func setupSummaryData() {
        guard let first = records.first, let last = records.last else { return }
        
        // 날짜 (yyyy.MM.dd)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        self.dateString = formatter.string(from: first.date)
        
        // 출발 시간 (HH:mm 출발)
        formatter.dateFormat = "HH:mm"
        self.startTimeString = "\(formatter.string(from: first.date)) 출발"
        
        // 소요 시간
        let duration = last.date.timeIntervalSince(first.date)
        self.totalDuration = formatDuration(duration)
        
        // 이동 거리 (좌표 간 거리 누적)
        self.totalDistance = calculateTotalDistance(records: records)
    }
    
    // MARK: - 백그라운드 지도 데이터 계산 (nonisolated: Task.detached에서 호출)
    nonisolated private static func buildMapData(records: [FishingRecord], documentsURL: URL?) -> HistoryMapDataResult {
        guard !records.isEmpty else { return .empty }

        let centerCoordinate = records.first.map {
            CLLocationCoordinate2D(latitude: $0.location.latitude, longitude: $0.location.longitude)
        } ?? CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)

        var segments: [HistoryFishingPolyline] = []
        var newMarkers: [HistoryPhotoMarker] = []
        var newStateMarkers: [FishingRecordViewModel.StateChangeMarker] = []
        var newStateMarkerInfos: [HistoryDetailViewModel.HistoryStateMarkerInfo] = []

        var currentSegmentCoordinates: [CLLocationCoordinate2D] = []
        var currentSegmentState: Int?
        var lastState: FDAppManager.FishingState?
        var globalPointIndex = 1

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        for record in records {
            let coord = CLLocationCoordinate2D(latitude: record.location.latitude, longitude: record.location.longitude)
            let stateInt = record.state
            let fishingState: FDAppManager.FishingState
            switch stateInt {
            case 1: fishingState = .drifting
            case 2: fishingState = .fishing
            default: fishingState = .moving
            }
            let timeStr = timeFormatter.string(from: record.date)

            // 1. 상태 변경 마커: MOVING → 탐색/낚시 전환 시에만 생성 (Android 동기화)
            if let last = lastState, last == .moving && fishingState != .moving {
                var markerCoord = coord
                if let lastSegmentCoord = currentSegmentCoordinates.last {
                    markerCoord = lastSegmentCoord
                }

                let marker = FishingRecordViewModel.StateChangeMarker(coordinate: markerCoord, state: fishingState)
                newStateMarkers.append(marker)

                let info = HistoryDetailViewModel.HistoryStateMarkerInfo(
                    id: marker.id,
                    title: "지점 #\(globalPointIndex)",
                    timeString: timeStr,
                    coordinate: markerCoord,
                    state: fishingState
                )
                newStateMarkerInfos.append(info)
                globalPointIndex += 1
            }
            lastState = fishingState

            // 2. 사진 마커
            if !record.imagePaths.isEmpty {
                for path in record.imagePaths {
                    let fullPath = getFullImagePath(from: path, documentsURL: documentsURL)
                    newMarkers.append(HistoryPhotoMarker(
                        recordId: record.id,
                        coordinate: coord,
                        thumbnailPath: fullPath,
                        title: "지점 #\(globalPointIndex)",
                        timeString: timeStr
                    ))
                    globalPointIndex += 1
                }
            }

            // 3. 경로 세그먼트 (createPolyline은 Int 타입 사용)
            if let currentState = currentSegmentState {
                if currentState == stateInt {
                    currentSegmentCoordinates.append(coord)
                } else {
                    if currentSegmentCoordinates.count > 1 {
                        segments.append(createPolyline(coordinates: currentSegmentCoordinates, state: currentState))
                    }
                    currentSegmentCoordinates = [currentSegmentCoordinates.last ?? coord, coord]
                    currentSegmentState = stateInt
                }
            } else {
                currentSegmentState = stateInt
                currentSegmentCoordinates.append(coord)
            }
        }

        if let currentState = currentSegmentState, currentSegmentCoordinates.count > 1 {
            segments.append(createPolyline(coordinates: currentSegmentCoordinates, state: currentState))
        }

        return HistoryMapDataResult(
            polylines: segments,
            markers: newMarkers,
            stateMarkers: newStateMarkers,
            stateMarkerInfos: newStateMarkerInfos,
            centerCoordinate: centerCoordinate
        )
    }

    nonisolated private static func createPolyline(coordinates: [CLLocationCoordinate2D], state: Int) -> HistoryFishingPolyline {
        var coords = coordinates
        let polyline = HistoryFishingPolyline(coordinates: &coords, count: coords.count)
        switch state {
        case 0: polyline.lineColor = UIColor(hex: "#2563EB")
        case 1: polyline.lineColor = UIColor(hex: "#F59E0B")
        case 2: polyline.lineColor = UIColor(hex: "#EF4444")
        default: polyline.lineColor = UIColor(hex: "#2563EB")
        }
        return polyline
    }

    nonisolated private static func getFullImagePath(from path: String, documentsURL: URL?) -> String {
        guard let documentsURL else { return path }
        let fileName = (path as NSString).lastPathComponent
        return documentsURL.appendingPathComponent(fileName).path
    }
    
    // MARK: - Helper Methods
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d시간 %d분", hours, minutes)
        } else {
            return String(format: "%d분", minutes)
        }
    }
    
    private func calculateTotalDistance(records: [FishingRecord]) -> Double {
        guard records.count > 1 else { return 0.0 }
        
        var distance: Double = 0.0
        for i in 0..<(records.count - 1) {
            let loc1 = CLLocation(latitude: records[i].location.latitude, longitude: records[i].location.longitude)
            let loc2 = CLLocation(latitude: records[i+1].location.latitude, longitude: records[i+1].location.longitude)
            distance += loc1.distance(from: loc2)
        }
        
        return distance / 1000.0 // meters to km
    }
    
    // MARK: - Action
    @Published var isDeletePopupPresented: Bool = false
    @Published var isPhotoDeletePopupPresented: Bool = false
    @Published var shouldDismiss: Bool = false
    @Published var isDataModified: Bool = false // 데이터 수정 여부
    
    func deleteRecord() {
        useCase.deleteSession(sessionId: sessionId)
        
        // 삭제 후 화면 닫기 트리거
        shouldDismiss = true
    }
    
    func deletePhoto(at index: Int) {
        guard index >= 0 && index < markers.count else { return }
        
        let marker = markers[index]
        
        // 실제 데이터 삭제
        useCase.deleteFishingRecord(id: marker.recordId)
        
        // UI 업데이트
        markers.remove(at: index)
        isDataModified = true
        
        // 인덱스 조정
        if markers.isEmpty {
            isImageViewerPresented = false
        } else if selectedImageIndex >= markers.count {
            selectedImageIndex = markers.count - 1
        }
    }
}
