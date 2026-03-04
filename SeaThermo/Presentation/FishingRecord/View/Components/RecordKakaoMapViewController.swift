//
//  RecordKakaoMapViewController.swift
//  SeaThermo
//
//  Created by Antigravity on 2026/02/10.
//

import UIKit
import KakaoMapsSDK
import CoreLocation

class RecordKakaoMapViewController: UIViewController {

    // ViewModel 의존성 제거됨
    
    // 카카오맵
    var observerAdded: Bool = false
    var appeared: Bool = false
    
    var shapeManager: ShapeManager!
    var _mapTapEventHandler: DisposableEventHandler?
    
    var mapContainer: KMViewContainer!
    var controller: KMController!
    
    var _currentPositionPoi: Poi?
    
    var polylines = [MapPolyline]()
    
    // 마커 관리
    private var currentMarkers: [UUID: Poi] = [:]
    private var currentPhotoMarkers: [UUID: Poi] = [:]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        controller?.stopEngine()
        _mapTapEventHandler?.dispose()
        print("RecordKakaoMapViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initKakaoMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 지도뷰를 추가한다.
        if mapContainer.superview == nil {
            self.view.addSubview(mapContainer)
            self.view.sendSubviewToBack(mapContainer)
        }
        
        // mapContainer 오토레이아웃 설정
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapContainer.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        if !controller.engineStarted {
             controller.startEngine()
        }
        
        controller.startRendering() // 지도뷰 렌더링 시작.
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appeared = true
        if !controller.engineStarted {
             controller.startEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        controller.stopRendering() // 현재 뷰가 사라질 때, 지도뷰 렌더링을 멈춘다.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appeared = false
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
        observerAdded = true
    }
     
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

        observerAdded = false
    }
    
    @objc func willResignActive(){
        controller.stopRendering()
    }

    @objc func didBecomeActive(){
        controller.startRendering()
    }
    
    // 초기화 플래그
    private var isFirstLocationUpdate = true
    
    func cleanup() {
        // 정리(Cleanup) 로직
        polylines.removeAll()
        currentMarkers.removeAll()
        currentPhotoMarkers.removeAll()
        
        // 지도 아이템 제거 (레이어 유지)
        if let map = controller.getView("mapview") as? KakaoMap {
            let shapeManager = map.getShapeManager()
            if let polylineLayer = shapeManager.getShapeLayer(layerID: "PolylineLayer") {
                polylineLayer.removeMapPolylineShape(shapeID: "mapPolylines")
            }
            
            let labelManager = map.getLabelManager()
            if let stateLayer = labelManager.getLabelLayer(layerID: "StateMarkerLayer") {
                stateLayer.clearAllItems()
            }
            if let photoLayer = labelManager.getLabelLayer(layerID: "PhotoMarkerLayer") {
                photoLayer.clearAllItems()
            }
            // CurrentPoiLayer는 위치 표시용이므로 초기화 시 유지하거나, 필요 시 clear
            // 여기서는 경로와 마커만 초기화하므로 CurrentPoi는 놔둠 (또는 위치 업데이트 시 자동 이동)
            // 만약 현재 위치 마커도 리셋해야 한다면:
            // if let currentLayer = labelManager.getLabelLayer(layerID: "CurrentPoiLayer") {
            //    currentLayer.clearAllItems() 
            //    _currentPositionPoi = nil // 재생성 필요
            // }
        }
    }
}

// MARK: - Update Methods (SwiftUI에서 호출)
extension RecordKakaoMapViewController {
    func updateMapLine(_ previousLocation: CLLocation,_ currentLocation: CLLocation, getLocationList: () -> [LocationInfo]) {
        // 위치가 유효하고 다를 때만 업데이트
        guard previousLocation.coordinate.latitude != 0, currentLocation.coordinate.latitude != 0 else { return }
        
        self.createPolyLineShape(previousLocation, currentLocation, getLocationList: getLocationList)
        self.createPolyLineShape(previousLocation, currentLocation, getLocationList: getLocationList)
        self.moveCurrentPoi(location: currentLocation)
    }
    
    func updateCurrentLocation(_ location: CLLocation) {
        // POI 이동
        self.moveCurrentPoi(location: location)
        
        // 카메라 이동 (트래킹 모드 동작)
        guard let map = controller.getView("mapview") as? KakaoMap else { return }
        
        let targetPoint = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
        
        // 첫 업데이트 시 애니메이션 없이 즉시 이동
        // 이후에는 자동으로 따라가지 않음 (사용자 요청: 탭 진입 시에만 포커싱)
        if isFirstLocationUpdate {
            let cameraUpdate = CameraUpdate.make(target: targetPoint, zoomLevel: 15, mapView: map)
            map.moveCamera(cameraUpdate)
            isFirstLocationUpdate = false
        }
    }
    
    func updateMarkers(_ markers: [FishingRecordViewModel.StateChangeMarker]) {
        guard let map = controller.getView("mapview") as? KakaoMap else { return }
        let manager = map.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "StateMarkerLayer")
        
        for markerInfo in markers {
            if currentMarkers[markerInfo.id] == nil {
                // 새로운 마커 생성
                let poiOption = PoiOptions(styleID: "stateMarkerStyle_\(markerInfo.state.rawValue)", poiID: markerInfo.id.uuidString)
                poiOption.rank = 0
                // 상태에 따른 아이콘 설정
                // 각 상태별 아이콘이 있거나 다른 스타일을 사용하는 일반 아이콘 사용 가정
                // 현재는 기존 에셋이 있다면 사용하고, 없으면 대체
                
                let coordinate = MapPoint(longitude: markerInfo.coordinate.longitude, latitude: markerInfo.coordinate.latitude)
                if let poi = layer?.addPoi(option: poiOption, at: coordinate) {
                    poi.show()
                    currentMarkers[markerInfo.id] = poi
                }
            }
        }
        
        // 삭제된 마커 확인? (보통 기록 중에는 마커가 추가되기만 함)
    }
    
    func updatePhotoMarkers(_ photoMarkers: [FishingRecordViewModel.PhotoMarker]) {
        guard let map = controller.getView("mapview") as? KakaoMap else { return }
        let manager = map.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PhotoMarkerLayer")
        
        for markerInfo in photoMarkers {
            if currentPhotoMarkers[markerInfo.id] == nil {
                // 썸네일 이미지 생성
                if let thumbImage = generateThumbnail(path: markerInfo.thumbnailPath) {
                    // 동적으로 스타일 생성 또는 가능하면 재사용 (카카오맵은 미리 정의된 스타일이나 POI별 스타일 필요)
                    // 기본 설정에서는 POI별 스타일 직접 지원 안 함, 보통 매니저에 스타일 추가 먼저 함.
                    // 사진처럼 동적인 이미지는 각 사진마다 스타일 생성 필요 (또는 이미지 같으면 공유, 하지만 가능성 낮음).
                    // 카카오맵은 스타일 추가 허용함. 각 사진마다 고유 스타일 ID 생성해야 함.
                    
                    let styleID = "photoStyle_\(markerInfo.id.uuidString)"
                    let iconStyle = PoiIconStyle(symbol: thumbImage, anchorPoint: CGPoint(x: 0.5, y: 0.83))
                    let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
                    let poiStyle = PoiStyle(styleID: styleID, styles: [perLevelStyle])
                    
                    manager.addPoiStyle(poiStyle)
                    
                    let poiOption = PoiOptions(styleID: styleID, poiID: markerInfo.id.uuidString)
                    poiOption.rank = 2 // 상태 마커보다 높은 우선순위
                    
                    let coordinate = MapPoint(longitude: markerInfo.coordinate.longitude, latitude: markerInfo.coordinate.latitude)
                    if let poi = layer?.addPoi(option: poiOption, at: coordinate) {
                        poi.show()
                        currentPhotoMarkers[markerInfo.id] = poi
                    }
                }
            }
        }
    }
    
    private func generateThumbnail(path: String) -> UIImage? {
        let fileManager = FileManager.default
        // 경로는 상대 경로일 수도 있고 절대 경로일 수도 있음.
        // ViewModel에서 오는 RecordPhotoAnnotation은 보통 상대 경로 저장.
        // RecordMapView와 같이 상대 경로라고 가정:
        // let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // let fileURL = documentsDirectory.appendingPathComponent(thumbnailPath)
        
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fullPath = documentsURL.appendingPathComponent(path).path
        
        guard let originalImage = UIImage(contentsOfFile: fullPath) else { return nil }
        
        // Figma 스케일:
        // 이미지 크기: 48pt
        // 테두리: 3pt
        // 전체 크기: 54pt (48 + 3*2)
        // 코너 반경: 10pt (이미지용), 이를 감싸는 테두리.
        
        let imageSize: CGFloat = 48
        let borderWidth: CGFloat = 3
        let cornerRadius: CGFloat = 10
        let totalSize = imageSize + (borderWidth * 2)
        
        let targetSize = CGSize(width: totalSize, height: totalSize)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        if #available(iOS 12.0, *) {
            format.preferredRange = .standard
        }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let image = renderer.image { context in
             // 색상: #10B981 (초록)
             let borderColor = UIColor(hex: "#10B981")
             borderColor.setFill()
             
             let borderPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: targetSize), cornerRadius: cornerRadius + borderWidth)
             borderPath.fill()
            
             // 이미지 그리기
             let imageRect = CGRect(x: borderWidth, y: borderWidth, width: imageSize, height: imageSize)
             let clipPath = UIBezierPath(roundedRect: imageRect, cornerRadius: cornerRadius)
             clipPath.addClip()
             
             // Aspect Fill 로직
             let size = originalImage.size
             let widthRatio = imageSize / size.width
             let heightRatio = imageSize / size.height
             let scale = max(widthRatio, heightRatio)
             let drawnWidth = size.width * scale
             let drawnHeight = size.height * scale
             let drawnX = imageRect.minX + (imageSize - drawnWidth) / 2
             let drawnY = imageRect.minY + (imageSize - drawnHeight) / 2
             
             originalImage.draw(in: CGRect(x: drawnX, y: drawnY, width: drawnWidth, height: drawnHeight))
        }
        
        print("RecordKakaoMap: Thumbnail Generated - Size: \(image.size), Scale: \(image.scale) (Target: 54.0 px @ 1.0x)")
        return image
    }
}

// MARK: - Kakao Map 설정 및 이벤트 델리게이트
extension RecordKakaoMapViewController: MapControllerDelegate {
    private func initKakaoMap() {
        mapContainer = KMViewContainer(frame: self.view.frame)
        controller = KMController(viewContainer: mapContainer)
        controller.delegate = self
        controller.initEngine()
        // controller.startEngine() // authenticationSucceeded 또는 viewWillAppear로 이동됨
    }
    
    func authenticationSucceeded() {
        print("Kakao Map auth succeeded")
        controller.startEngine()
        controller.startRendering()
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("Kakao Map auth failed - error code: \(errorCode)")
        print("\(desc)")
        // Retry or handle error
    }
    
    func addViews() {
        print("Kakao Map add views")
        // 기본 위치 (예: 서울 또는 사용자 마지막 위치)
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 15)
        
        if controller.addView(mapviewInfo) == Result.OK {
            print("mapview OK")
            self.afterAddViews()
        }
    }
    
    private func afterAddViews() {
        initializeShapeManager()
        createPolylineStyleSet()
        createLabelLayers()
        createStateMarkerStyles()
        createCurrentPoiStyle()
        createCurrentPoi()
        // showCompass() // 선택사항
    }
    
    private func initializeShapeManager() {
        guard let map = controller.getView("mapview") as? KakaoMap else {
            print("init shape manager failed")
            return
        }
        shapeManager = map.getShapeManager()
    }
    
    func containerDidResized(_ size: CGSize) {
        guard let mapView = controller.getView("mapview") as? KakaoMap else {
            return
        }
        mapView.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }
}

// MARK: - Shape & POI 관리
extension RecordKakaoMapViewController {
    
    // MARK: 폴리라인
    private func createPolylineStyleSet() {
        let _ = shapeManager.addShapeLayer(layerID: "PolylineLayer", zOrder: 9999)
        
        // 스타일: 0: 이동 (파랑), 1: 탐색/표류 (주황), 2: 낚시 (빨강)
        // 매칭 색상: #2563EB, #F59E0B, #EF4444
        
        let movingStyle = PolylineStyle(styles: [
            PerLevelPolylineStyle(bodyColor: UIColor(hex: "#2563EB"), bodyWidth: 4, strokeColor: UIColor.white, strokeWidth: 1, level: 0)
        ])
        
        let driftingStyle = PolylineStyle(styles: [
            PerLevelPolylineStyle(bodyColor: UIColor(hex: "#F59E0B"), bodyWidth: 4, strokeColor: UIColor.white, strokeWidth: 1, level: 0)
        ])
        
        let fishingStyle = PolylineStyle(styles: [
            PerLevelPolylineStyle(bodyColor: UIColor(hex: "#EF4444"), bodyWidth: 4, strokeColor: UIColor.white, strokeWidth: 1, level: 0)
        ])
        
        let styleSet = PolylineStyleSet(styleSetID: "polylineStyleSet", styles: [movingStyle, driftingStyle, fishingStyle])
        shapeManager.addPolylineStyleSet(styleSet)
    }
    
    private func createPolyLineShape(_ previousLocation: CLLocation,_ currentLocation: CLLocation, getLocationList: () -> [LocationInfo]) {
        guard let map = controller.getView("mapview") as? KakaoMap else { return }
        
        let preMapPoint = MapPoint(longitude: previousLocation.coordinate.longitude,
                                   latitude: previousLocation.coordinate.latitude)
        let curMapPoint = MapPoint(longitude: currentLocation.coordinate.longitude,
                                   latitude: currentLocation.coordinate.latitude)
        
        // 속도/상태 로직에 따른 스타일 결정
        var styleIndex: UInt = 0 // 기본 이동
        
        if let info = getLocationList().last {
            let speedKnots = info.locationInfo.speed * 1.94384
            if speedKnots >= FDAppManager.speedThresholdHigh {
                styleIndex = 0 // 이동
            } else if speedKnots >= FDAppManager.speedThresholdLow {
                styleIndex = 1 // 탐색/표류
            } else {
                styleIndex = 2 // 낚시
            }
        }
        
        let polyline = MapPolyline(line: [preMapPoint, curMapPoint], styleIndex: styleIndex)
        self.polylines.append(polyline)
        
        let layer = shapeManager.getShapeLayer(layerID: "PolylineLayer")
        
        if let _ = layer?.getMapPolylineShape(shapeID: "mapPolylines") {
            layer?.removeMapPolylineShape(shapeID: "mapPolylines")
        }
        
        let options = MapPolylineShapeOptions(shapeID: "mapPolylines", styleID: "polylineStyleSet", zOrder: 1)
        options.polylines = self.polylines
        
        let shape = layer?.addMapPolylineShape(options)
        shape?.show()
        

    }
    
    // MARK: 레이어 설정
    private func createLabelLayers() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        
        // 현재 위치 POI 레이어
        let currentPoiLayerOption = LabelLayerOptions(layerID: "CurrentPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
        manager.addLabelLayer(option: currentPoiLayerOption)
        
        // 상태 마커 레이어
        let stateMarkerLayerOption = LabelLayerOptions(layerID: "StateMarkerLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 1)
        manager.addLabelLayer(option: stateMarkerLayerOption)
        
        // 사진 마커 레이어
        let photoMarkerLayerOption = LabelLayerOptions(layerID: "PhotoMarkerLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 2)
        manager.addLabelLayer(option: photoMarkerLayerOption)
    }
    
    // MARK: 상태 마커 스타일
    private func createStateMarkerStyles() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        
        // fishingState: moving, drifting, fishing
        let states: [FDAppManager.FishingState] = [.moving, .drifting, .fishing]
        for state in states {
            var iconName = "ic_map_marker_blue" // 기본 이동
            switch state {
            case .moving: iconName = "ic_map_marker_blue"
            case .drifting: iconName = "ic_map_marker_orange"
            case .fishing: iconName = "ic_map_marker_red"
            }
            
            if let image = UIImage(named: iconName) {
                let resized = resizeTo2x(image: image)
                let iconStyle = PoiIconStyle(symbol: resized, anchorPoint: CGPoint(x: 0.5, y: 1.0))
                let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
                let poiStyle = PoiStyle(styleID: "stateMarkerStyle_\(state.rawValue)", styles: [perLevelStyle])
                manager.addPoiStyle(poiStyle)
            }
        }
    }

    // MARK: 현재 위치 POI
    private func createCurrentPoiStyle() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        
        // 사용자의 요청에 따라 resizeTo1x 제거하여 원본 크기 사용
        if let image = UIImage(named: "ic_my_location") ?? UIImage(named: "map_ico_marker") {
            let marker = PoiIconStyle(symbol: image)
            let perLevelStyle = PerLevelPoiStyle(iconStyle: marker, level: 0)
            let poiStyle = PoiStyle(styleID: "currentPoiStyle", styles: [perLevelStyle])
            
            manager.addPoiStyle(poiStyle)
        }
    }
    
    private func createCurrentPoi() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let currentPoiLayer = manager.getLabelLayer(layerID: "CurrentPoiLayer")
        
        let poiOption = PoiOptions(styleID: "currentPoiStyle", poiID: "CurrentPoi")
        poiOption.rank = 1
        poiOption.transformType = .decal
        
        // 초기 위치
        let currentLocation = MapPoint(longitude: 127.108678, latitude: 37.402001)
        _currentPositionPoi = currentPoiLayer?.addPoi(option:poiOption, at: currentLocation)
        // _currentPositionPoi?.show() // 위치 정보가 있을 때만 표시
    }
    
    private func resizeTo2x(image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        if #available(iOS 12.0, *) {
            format.preferredRange = .standard
        }
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private func moveCurrentPoi(location: CLLocation) {
        if let curPoi = _currentPositionPoi {
             curPoi.show() // 보이게 처리
             let currentLocation = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
             curPoi.moveAt(currentLocation, duration: 0)
        }
    }
}
