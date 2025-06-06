//
//  KakaoTrackMapViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/02/16.
//

import UIKit
import Combine
import KakaoMapsSDK
import CoreLocation

class KakaoTrackMapViewController: UIViewController, StoryboardInstantiable {

    private var viewModel: KakaoTrackMapViewModel!
    
    var cancelBag = Set<AnyCancellable>()
    
    @IBOutlet var speedLb: UILabel!
    @IBOutlet var latitudeLb: UILabel!
    @IBOutlet var longitudeLb: UILabel!
    
    // kakao map
    var observerAdded: Bool
    var appeared: Bool
    
    var shapeManager: ShapeManager!
    var _mapTapEventHandler: DisposableEventHandler?
    
    var mapContainer: KMViewContainer!
    var controller: KMController!
    
    var _currentPositionPoi: Poi?
    
    var polylines = [MapPolyline]()
    
    required init?(coder: NSCoder) {
        observerAdded = false
        appeared = false
        super.init(coder: coder)
    }
    
    deinit {
        controller.stopEngine()
        _mapTapEventHandler?.dispose()
    }
    
    static func create(with viewModel: KakaoTrackMapViewModel) -> KakaoTrackMapViewController {
        let view = KakaoTrackMapViewController.instantiateViewController(boardName: .point)
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initKakaoMap()
        self.bind(with: viewModel)
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 지도뷰를 추가한다.
        self.view.addSubview(mapContainer)
        self.view.sendSubviewToBack(mapContainer)
        
        controller.startRendering() // 지도뷰 렌더링 시작.
        
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        controller.stopRendering() // 현재 뷰가 사라질 때, 지도뷰 렌더링을 멈춘다.
        
        viewModel.viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
        //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
        controller.stopRendering()
    }

    @objc func didBecomeActive(){
        //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
        controller.startRendering()
    }
}

// MARK: - private ui function
extension KakaoTrackMapViewController {
    private func bind(with viewModel: KakaoTrackMapViewModel) {
        viewModel.mapLineItem.sink(receiveValue: { [weak self] mapLine in
            guard let self = self else { return }
            
            let previousLocation = mapLine.previousLocation
            let currentLocation = mapLine.currentLocation
            
            self.updateUI(currentLocation)
            self.updateMapLine(previousLocation, currentLocation)
            self.moveCurrentPoi(location: currentLocation)
            self.startTracking()
        }).store(in: &cancelBag)
    }
    
    private func updateUI(_ currentLocation: CLLocation) {
        let latitude = String(format: "%.6f", currentLocation.coordinate.latitude)
        let longitude = String(format: "%.6f", currentLocation.coordinate.longitude)
        let speed = currentLocation.speed * 3.6 // km/h
        
        self.latitudeLb.text = latitude
        self.longitudeLb.text = longitude
        self.speedLb.text = String(format: "%.2f", speed)
    }
    
    private func updateMapLine(_ previousLocation: CLLocation,_ currentLocation: CLLocation) {
        self.createPolyLineShape(previousLocation, currentLocation)
    }
}

// MARK: - kakao map private function
extension KakaoTrackMapViewController: KakaoMapEventDelegate {
    private func initKakaoMap() {
        mapContainer = KMViewContainer(frame: self.view.frame)
        controller = KMController(viewContainer: mapContainer)
        // 지도뷰(KMContainer)를 생성하고, 엔진을 초기화한다.
        // 지도뷰 인스턴스를 계속 유지한채로 들고 사용하려면 initEngine 및 startEngine & stopEngine은 초기화 및 더이상 사용하지 않을때 1번씩만 호출한다.
        // 그 외에 뷰 라이프 싸이클에 따른 지도 렌더링 컨트롤은 startRendering & stopRendering으로만 컨트롤한다.
        controller.delegate = self
        controller.initEngine()
        controller.startEngine()
    }
    
    private func afterAddViews() {
        initializeShapeManager()
        createPolylineStyleSet()
        createCurrentPoiLabelLayer()
        createCurrentPoiStyle()
        createCurrentPoi()
        showCompass()
    }
    
    private func initializeShapeManager() {
        guard let map = controller.getView("mapview") as? KakaoMap else {
            print("init shape manager failed")
            return
        }
        
        shapeManager = map.getShapeManager()
    }
    
    // 나침반 표시. 표시 영역의 left/top에 표시한다.
    func showCompass() {
        let mapView: KakaoMap = controller.getView("mapview") as! KakaoMap
        
        mapView.setCompassPosition(origin: GuiAlignment(vAlign: .top, hAlign: .right), position: CGPoint(x: 20, y: 40))
        mapView.showCompass()
    }
    
    private func clearShapeManager() {
        shapeManager.removeShapeLayer(layerID: "")
    }
 
    // MARK: - shape line
    
    private func createPolylineStyleSet() {
        print("create polyline style set")
        let _ = shapeManager.addShapeLayer(layerID: "PolylineLayer", zOrder: 9999)
        
        // 파란선 : 이동
        // 빨간선 : 포인트 구간
        let pointPolylineStyle = PolylineStyle(styles: [
            PerLevelPolylineStyle(bodyColor: UIColor.red, bodyWidth: 4, strokeColor: UIColor.white, strokeWidth: 1, level: 0)
        ])
        let movePolylineStyle = PolylineStyle(styles: [
            PerLevelPolylineStyle(bodyColor: UIColor.blue, bodyWidth: 4, strokeColor: UIColor.white, strokeWidth: 1, level: 0)
        ])
        
        let styleSet = PolylineStyleSet(styleSetID: "polylineStyleSet", styles: [pointPolylineStyle, movePolylineStyle])
        shapeManager.addPolylineStyleSet(styleSet)
    }
    
    private func startTracking() {
        guard let view = controller.getView("mapview") as? KakaoMap else {
            print("fail rect point camara area")
            return
        }
        
        let trackingManager = view.getTrackingManager()
        if !trackingManager.isTracking {
            trackingManager.startTrackingPoi(_currentPositionPoi!)
        }
    }
    
    private func createPolyLineShape(_ previousLocation: CLLocation,_ currentLocation: CLLocation) {
        let preMapPoint = MapPoint(longitude: previousLocation.coordinate.longitude,
                                   latitude: previousLocation.coordinate.latitude)
        let curMapPoint = MapPoint(longitude: currentLocation.coordinate.longitude,
                                   latitude: currentLocation.coordinate.latitude)
        
        var styleIndex: UInt = 0
        if let info = viewModel.getLocationList().last {
            let speed = info.locationInfo.speed
            styleIndex = (Float(speed * 3.6) > FDAppManager.pointVelocity) ? 1:0    // > 0:point 1:move
        }
        
        let polyline = MapPolyline(line: [preMapPoint, curMapPoint], styleIndex: styleIndex)
        self.polylines.append(polyline)
        
        let layer = shapeManager.getShapeLayer(layerID: "PolylineLayer")
        if let _ = layer?.getMapPolylineShape(shapeID: "mapPolylines") {
            layer?.removeMapPolylineShape(shapeID: "mapPolylines")      // > 덮어써야 하므로 삭제처리
        }
        
        let options = MapPolylineShapeOptions(shapeID: "mapPolylines", styleID: "polylineStyleSet", zOrder: 1)
        options.polylines = self.polylines
        
        let shape = layer?.addMapPolylineShape(options)
        shape?.show()
    }
    
    // MARK: - shape current position poi
    private func createCurrentPoiLabelLayer() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let currentPoiLayerOption = LabelLayerOptions(layerID: "CurrentPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
        let _ = manager.addLabelLayer(option: currentPoiLayerOption)
    }
    
    private func createCurrentPoiStyle() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let marker = PoiIconStyle(symbol: UIImage(named: "map_ico_marker"))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: marker, level: 0)
        let poiStyle = PoiStyle(styleID: "currentPoiStyle", styles: [perLevelStyle])
        
        manager.addPoiStyle(poiStyle)
    }
    
    private func createCurrentPoi() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let currentPoiLayer = manager.getLabelLayer(layerID: "CurrentPoiLayer")
        
        let poiOption = PoiOptions(styleID: "currentPoiStyle", poiID: "CurrentPoi")
        poiOption.rank = 1
        poiOption.transformType = .decal
        
        let currentLocation = MapPoint(longitude: 126.974726, latitude: 37.562632) // > default exam point
        _currentPositionPoi = currentPoiLayer?.addPoi(option:poiOption, at: currentLocation)
        _currentPositionPoi?.show()
    }
    
    private func moveCurrentPoi(location: CLLocation) {
        if let curPoi = _currentPositionPoi {
            let currentLocation = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
            curPoi.moveAt(currentLocation, duration: 0)
        }
    }
}

// MARK: - kakao map delegate function
extension KakaoTrackMapViewController: MapControllerDelegate {
    func authenticationSucceeded() {
        print("kakao map auth succeeded")
        if controller.engineStarted == false {
            controller.startEngine()
            
            if appeared {
                controller.startRendering()
            }
        }
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("kakao map auth failed - error code: \(errorCode)")
        print("\(desc)")
        
        controller.authenticate()
    }
    
    func addViews() {
        print("kakao map add views")
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        //지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 15)
        
        if controller.addView(mapviewInfo) == Result.OK {
            print("mapview OK")
        }
        
        self.afterAddViews()
    }
    
    // Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        guard let mapView = controller.getView("mapview") as? KakaoMap else {
            print("fail rect point camara area")
            return
        }
        
        mapView.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size) // 지도뷰의 크기를 리사이즈된 크기로 지정한다.
    }
    
    func viewWillDestroyed(_ view: ViewBase) {
        // 뷰 삭제전 호출
    }
}

