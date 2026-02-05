import Foundation
import CoreLocation
import Combine
import UIKit
import MapKit

final class HistoryDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var dateString: String = ""
    @Published var startTimeString: String = "" // "HH:mm 출발"
    @Published var totalDistance: Double = 0.0 // km
    @Published var totalDuration: String = "00:00:00"
    
    @Published var polylines: [FishingPolyline] = []
    @Published var stateMarkers: [FishingRecordViewModel.StateChangeMarker] = []
    @Published var stateMarkerInfos: [HistoryStateMarkerInfo] = [] // 상태 마커 상세 정보
    @Published var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // 기본 서울
    @Published var markers: [HistoryPhotoMarker] = []
    
    // 상태 마커 상세 정보 (지점 번호 + 시간 포함)
    struct HistoryStateMarkerInfo: Identifiable {
        let id = UUID()
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
    
    // MARK: - Properties
    private let sessionId: String
    private let useCase: FishingRecordUseCase
    private var records: [FishingRecord] = []
    private var cancellable: Cancellable? // 비동기 작업 취소용
    
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
        // 1. 전체 데이터 가져오기 (비동기)
        cancellable = useCase.fetchAllRecords { [weak self] (result: Result<[FishingRecord], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let allRecords):
                    // 2. sessionId로 필터링 및 정렬 (시간순)
                    let filteredRecords: [FishingRecord] = allRecords.filter { record in
                        return record.sessionId == self.sessionId
                    }
                    
                    self.records = filteredRecords.sorted { (lhs: FishingRecord, rhs: FishingRecord) -> Bool in
                        return lhs.date < rhs.date
                    }
                    
                    if !self.records.isEmpty {
                        // 3. UI 데이터 가공
                        self.setupSummaryData()
                        self.setupMapData()
                    }
                    
                case .failure(let error):
                    print("Error fetching records: \(error)")
                    // 에러 처리 로직 (필요 시 Alert 표시 등)
                }
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
    
    private func setupMapData() {
        // 이미지가 있는 레코드만 필터링 (사진 마커용)
        let recordsWithImage = records.filter { !$0.imagePaths.isEmpty }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        // flatMap을 사용하면 인덱스가 꼬일 수 있으므로, 외부 변수로 카운팅
        var globalMarkerIndex = 1
        
        self.markers = recordsWithImage.flatMap { record -> [HistoryPhotoMarker] in
            let timeStr = timeFormatter.string(from: record.date)
            
            return record.imagePaths.enumerated().map { (index, path) in
                let fullPath = self.getFullImagePath(from: path)
                let title = "지점 #\(globalMarkerIndex)"
                globalMarkerIndex += 1
                
                return HistoryPhotoMarker(
                    coordinate: CLLocationCoordinate2D(latitude: record.location.latitude, longitude: record.location.longitude),
                    thumbnailPath: fullPath,
                    title: title,
                    timeString: timeStr
                )
            }
        }
        
        // 경로 데이터 가공 (Polyline Segments) 및 상태 변경 마커 생성
        // 날짜순 정렬
        let sortedRecords = records.sorted { $0.date < $1.date }
        guard !sortedRecords.isEmpty else { return }
        
        // 초기 중심 좌표
        if let first = sortedRecords.first {
            self.centerCoordinate = CLLocationCoordinate2D(latitude: first.location.latitude, longitude: first.location.longitude)
        }
        
        var segments: [FishingPolyline] = []
        var newStateMarkers: [FishingRecordViewModel.StateChangeMarker] = []
        var newStateMarkerInfos: [HistoryStateMarkerInfo] = []
        
        var currentSegmentCoordinates: [CLLocationCoordinate2D] = []
        var currentSegmentState: Int?
        var lastState: Int? // 이전 레코드의 상태 (마커 감지용)
        
        // 지점 번호 카운터 (사진 마커 다음 번호부터 시작)
        var stateMarkerIndex = self.markers.count + 1
        
        for (index, record) in sortedRecords.enumerated() {
            let coord = CLLocationCoordinate2D(latitude: record.location.latitude, longitude: record.location.longitude)
            let state = record.state
            
            // 1. 상태 변경 마커 (이전 상태와 다르면 마커 추가)
            if let last = lastState, last != state {
                // 상태값(Int) -> FishingState(Enum) 변환
                let markerState: FDAppManager.FishingState
                switch state {
                case 0: markerState = .moving
                case 1: markerState = .drifting
                case 2: markerState = .fishing
                default: markerState = .moving
                }
                
                newStateMarkers.append(FishingRecordViewModel.StateChangeMarker(coordinate: coord, state: markerState))
                
                // 상세 정보도 추가 (지점 번호 + 시간)
                let info = HistoryStateMarkerInfo(
                    title: "지점 #\(stateMarkerIndex)",
                    timeString: timeFormatter.string(from: record.date),
                    coordinate: coord,
                    state: markerState
                )
                newStateMarkerInfos.append(info)
                stateMarkerIndex += 1
            }
            lastState = state
            
            // 2. 경로 세그먼트 생성
            if let currentState = currentSegmentState {
                if currentState == state {
                    currentSegmentCoordinates.append(coord)
                } else {
                    if currentSegmentCoordinates.count > 1 {
                        let polyline = createPolyline(coordinates: currentSegmentCoordinates, state: currentState)
                        segments.append(polyline)
                    }
                    if let lastCoord = currentSegmentCoordinates.last {
                         currentSegmentCoordinates = [lastCoord, coord]
                    } else {
                         currentSegmentCoordinates = [coord]
                    }
                    currentSegmentState = state
                }
            } else {
                currentSegmentState = state
                currentSegmentCoordinates.append(coord)
            }
        }
        
        if let currentState = currentSegmentState, currentSegmentCoordinates.count > 1 {
            let polyline = createPolyline(coordinates: currentSegmentCoordinates, state: currentState)
            segments.append(polyline)
        }
        
        self.polylines = segments
        self.stateMarkers = newStateMarkers
        self.stateMarkerInfos = newStateMarkerInfos
    }
    
    // Helper to create colored polyline
    private func createPolyline(coordinates: [CLLocationCoordinate2D], state: Int) -> FishingPolyline {
        var coords = coordinates
        let polyline = FishingPolyline(coordinates: &coords, count: coords.count)
        
        // 색상 지정 (FishingRecordView와 동일)
        switch state {
        case 0: // Moving
            polyline.lineColor = UIColor(hex: "#2563EB")
        case 1: // Drifting
            polyline.lineColor = UIColor(hex: "#F59E0B")
        case 2: // Fishing
            polyline.lineColor = UIColor(hex: "#EF4444")
        default:
            polyline.lineColor = UIColor(hex: "#2563EB")
        }
        
        return polyline
    }
    
    // 샌드박스 경로 변경에 대응하여 항상 현재의 Documents 경로를 기반으로 파일 경로 생성
    private func getFullImagePath(from path: String) -> String {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return path }
        let fileName = (path as NSString).lastPathComponent // 경로가 포함되어 있다면 파일명만 추출
        return documentsURL.appendingPathComponent(fileName).path
    }
    
    // MARK: - Helper Methods
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "00:00:00"
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
}
