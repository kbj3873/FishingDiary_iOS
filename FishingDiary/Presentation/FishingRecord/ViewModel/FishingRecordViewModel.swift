import Foundation
import Combine
import CoreLocation
import AVFoundation

final class FishingRecordViewModel: ObservableObject {
    // MARK: - Types
    struct StateChangeMarker: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let state: FDAppManager.FishingState
    }
    
    struct PhotoMarker: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let thumbnailPath: String
    }

    // MARK: - Published Properties
    /// 현재 녹화 중인지 여부
    @Published var isRecording: Bool = false
    
    /// 현재 낚시 상태 (이동 중, 탐색 중, 낚시 중)
    @Published var fishingState: FDAppManager.FishingState = .moving
    
    /// 현재 속도 (knots)
    @Published var currentSpeed: Double = 0.0
    
    /// 이동 거리 (km)
    @Published var distance: Double = 0.0
    
    /// 녹화 시간 (초)
    @Published var duration: TimeInterval = 0
    
    /// 지도에 그릴 경로 좌표들
    @Published var pathCoordinates: [CLLocationCoordinate2D] = []
    
    /// 지도 경로 그리기용 (Combine Binding)
    @Published var currentMapLine: MapLineInfo = MapLineInfo(CLLocation(), CLLocation())
    
    /// 저장된 사진 썸네일 경로 목록 (최신순)
    @Published var savedImagePaths: [String] = []
    
    /// 상태 변경 마커 목록
    @Published var markers: [StateChangeMarker] = []
    
    /// 사진 위치 마커 목록
    @Published var photoMarkers: [PhotoMarker] = []
    
    /// 실제 저장된 지점 개수 (마커 + 사진)
    @Published var savedPointCount: Int = 0
    
    /// 기록 중단 팝업 표시 여부
    @Published var isStopPopupPresented: Bool = false
    
    /// 권한 설정 팝업 표시 여부
    @Published var isPermissionPopupPresented: Bool = false

    
    // MARK: - Dependencies
    private let useCase: FishingRecordUseCase
    private let locationManager = FDLocationManager.shared
    private var cancellables = Set<AnyCancellable>()

    private var timerPublisher: AnyCancellable?
    
    // 이전 상태 추적용 (초기값 nil로 변경하여 첫 상태 진입 시 마커 생성 방지)
    private var lastFishingState: FDAppManager.FishingState? = nil
    
    // 현재 낚시 세션 ID (녹화 시작 시 생성)
    private var currentSessionId: String = ""
    
    // 위치 저장 스로틀링
    private var lastSavedTime: Date = Date.distantPast
    private let saveInterval: TimeInterval = 3.0 // 3초 간격 저장 (사용자 요청)

    
    // MARK: - Initializer
    init(useCase: FishingRecordUseCase) {
        self.useCase = useCase
        // 초기 MapLine 설정
        if let lastLocation = locationManager.locationList.last?.locationInfo {
             self.currentMapLine = MapLineInfo(lastLocation, lastLocation)
        }
        bindLocationupdates()
    }
    
    // MARK: - Bindings
    private func bindLocationupdates() {
        locationManager.curMapLine
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mapLine in
                guard let self = self, self.isRecording else { return }
                
                // MapLineInfo 업데이트 (View 바인딩용)
                self.currentMapLine = mapLine
                
                let currentLocation = mapLine.currentLocation
                
                // 1. 좌표 업데이트
                self.pathCoordinates.append(currentLocation.coordinate)
                
                // 2. 속도 업데이트 및 상태 판별
                let speedMps = currentLocation.speed
                let speedKnots = speedMps * 1.94384 // m/s to knots
                self.currentSpeed = speedKnots
                
                // FishingState 업데이트
                if speedKnots >= FDAppManager.speedThresholdHigh {
                    self.fishingState = .moving
                } else if speedKnots >= FDAppManager.speedThresholdLow {
                    self.fishingState = .drifting
                } else {
                    self.fishingState = .fishing
                }
                
                // 상태 변경 감지 및 마커 추가
                // 1. 첫 상태 진입(nil)인 경우: 현재 상태를 저장만 하고 마커는 찍지 않음
                // 2. 상태가 변경된 경우: 마커를 생성하고 상태 갱신
                if let lastState = self.lastFishingState {
                    if self.fishingState != lastState {
                        print("State Changed: \(lastState) -> \(self.fishingState)")
                        let marker = StateChangeMarker(coordinate: currentLocation.coordinate, state: self.fishingState)
                        self.markers.append(marker)
                        self.lastFishingState = self.fishingState
                        
                        // 상태 변경 시 지점 저장
                        self.useCase.savePoint(sessionId: self.currentSessionId,
                                               latitude: currentLocation.coordinate.latitude,
                                               longitude: currentLocation.coordinate.longitude,
                                               speed: speedKnots,
                                               state: self.currentStateValue)
                        self.savedPointCount += 1
                    }
                } else {
                    // 첫 상태 설정 (마커 생성 안함)
                    self.lastFishingState = self.fishingState
                }


                
                // 3. 거리 계산 (단순 누적은 오차 있을 수 있음, 이전 좌표와 거리 계산)
                let prevLocation = mapLine.previousLocation
                // 첫 위치가 아닐 때만 거리 누적 (lat/lon이 0.0이 아닌지 체크 필요하나 여기서는 단순화)
                if prevLocation.coordinate.latitude != 0 && prevLocation.coordinate.longitude != 0 {
                    let segmentDistance = currentLocation.distance(from: prevLocation)
                    self.distance += (segmentDistance / 1000.0) // m to km
                }
                
                // 4. 주기적 위치 저장 (5초 간격)
                // 너무 잦은 저장은 DB 용량과 로딩 속도에 영향을 주므로 적절한 주기 설정 필요
                if Date().timeIntervalSince(self.lastSavedTime) >= self.saveInterval {
                    self.useCase.savePoint(sessionId: self.currentSessionId,
                                           latitude: currentLocation.coordinate.latitude,
                                           longitude: currentLocation.coordinate.longitude,
                                           speed: speedKnots,
                                           state: self.currentStateValue)
                    // 자동 저장 시에는 화면 상단 '지점 저장' 카운트를 증가시키지 않음 (사용자 요청)
                    // self.savedPointCount += 1
                    self.lastSavedTime = Date()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions

    func startRecording() {
        isRecording = true
        markers.removeAll() // 시작 시 마커 초기화
        photoMarkers.removeAll() // 사진 마커도 초기화
        fishingState = .moving // 초기 상태
        lastFishingState = nil // 초기 상태 리셋 (nil로 설정하여 첫 수신 시 마커 안 찍히게 함)
        savedPointCount = 0 // 저장된 지점 수 초기화
        currentSessionId = UUID().uuidString // 새로운 세션 ID 생성
        locationManager.startTracking()
        
        // 세션 시작 지점 저장 (현재 위치 또는 기본 위치)
        if let lastLocation = locationManager.locationList.last?.locationInfo {
            useCase.savePoint(sessionId: currentSessionId,
                            latitude: lastLocation.coordinate.latitude,
                            longitude: lastLocation.coordinate.longitude,
                            speed: 0,
                            state: currentStateValue)
            savedPointCount += 1
        }
        
        // 타이머 시작
        duration = 0
        timerPublisher = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.duration += 1
            }
    }
    
    func stopRecording() {
        // 세션 종료 지점 저장
        if let lastLocation = locationManager.locationList.last?.locationInfo {
            useCase.savePoint(sessionId: currentSessionId,
                            latitude: lastLocation.coordinate.latitude,
                            longitude: lastLocation.coordinate.longitude,
                            speed: 0,
                            state: currentStateValue)
            savedPointCount += 1
        } else if let lastCoord = pathCoordinates.last {
            // 위치 리스트가 없으면 경로 좌표에서 가져옴
            useCase.savePoint(sessionId: currentSessionId,
                            latitude: lastCoord.latitude,
                            longitude: lastCoord.longitude,
                            speed: 0,
                            state: currentStateValue)
            savedPointCount += 1
        }
        
        isRecording = false
        locationManager.stopTracking()
        timerPublisher?.cancel()
        timerPublisher = nil
        isStopPopupPresented = false
        
        // UI 및 상태 초기화 (기록 중단 시 Reset)
        markers.removeAll()
        photoMarkers.removeAll()
        pathCoordinates.removeAll()
        savedImagePaths.removeAll()
        savedPointCount = 0
        currentSpeed = 0
        distance = 0
        duration = 0
        fishingState = .moving // 기본 상태로 복구
        
        // MapLine 초기화 (마지막 위치 기준으로 점 하나만 남김)
        if let lastLocation = locationManager.locationList.last?.locationInfo {
             self.currentMapLine = MapLineInfo(lastLocation, lastLocation)
        } else {
             self.currentMapLine = MapLineInfo(CLLocation(), CLLocation())
        }
    }
    
    func savePhoto(data: Data) {
        // 현재 위치 (마지막 좌표)
        let lat = pathCoordinates.last?.latitude ?? 0.0
        let lon = pathCoordinates.last?.longitude ?? 0.0
        
        // 0: 이동, 1: 탐색, 2: 낚시
        if let path = useCase.savePhoto(sessionId: currentSessionId, image: data, location: (lat, lon), state: currentStateValue) {
            // UI 표시용 썸네일 경로 업데이트
            savedImagePaths.insert(path, at: 0)
            
            // 사진 위치 마커 추가
            let photoMarker = PhotoMarker(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                thumbnailPath: path
            )
            photoMarkers.append(photoMarker)
            
            // 사진 촬영 시 지점 저장
            useCase.savePoint(sessionId: currentSessionId, latitude: lat, longitude: lon, speed: currentSpeed, state: currentStateValue)
            savedPointCount += 1
        }
    }
    
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            // 권한 있음 -> View에서 바로 showCamera = true 처리하도록 여기서는 아무것도 안 하거나 콜백
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                // 첫 요청 시에는 시스템 팝업이 뜨므로 별도 처리 불필요
                // 다만 사용자가 허용한 직후에 바로 카메라를 띄우려면 콜백이 필요할 수 있음
                // 여기서는 단순히 요청만 보냄
            }
        case .denied, .restricted:
            isPermissionPopupPresented = true
        @unknown default:
            break
        }
    }
    
    // View에서 호출하기 위한 Helper
    func isCameraAuthorized() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized { return true }
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { _ in }
            return false // 요청을 보냈으므로 이번 탭에서는 false (사용자가 허용하면 다음 탭에 됨, 혹은 비동기 처리 필요)
        }
        
        if status == .denied || status == .restricted {
            isPermissionPopupPresented = true
            return false
        }
        
        return false
    }
    
    func getLocationList() -> [LocationInfo] {
        return locationManager.locationList
    }
    
    // MARK: - Helper
    private var currentStateValue: Int {
        switch fishingState {
        case .moving: return 0
        case .drifting: return 1
        case .fishing: return 2
        }
    }
}
