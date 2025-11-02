//
//  KakaoPointMapViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit
import KakaoMapsSDK
import Combine

class KakaoPointMapViewController: UIViewController, StoryboardInstantiable {
    
    //private let locMgr = FDLocationManager.shared
    
    var observerAdded: Bool
    var appeared: Bool
    
    var viewModel: KakaoPointMapViewModel!
    var shapeManager: ShapeManager!
    var _mapTapEventHandler: DisposableEventHandler?
    
    private var cancelBag = Set<AnyCancellable>()
    var mapContainer: KMViewContainer!
    var controller: KMController!
    
    var pointMapPins: [KakaoMapPin]?
    var selMapPin: KakaoMapPin?
    
    @IBOutlet var infoView: UIView!
    @IBOutlet var timeLb: UILabel!
    @IBOutlet var latLb: UILabel!
    @IBOutlet var lonLb: UILabel!
    @IBOutlet var kmhLb: UILabel!
    @IBOutlet var knotLb: UILabel!
    @IBOutlet var sequenceLb: UILabel!
    @IBOutlet var convertBtn: UIButton!
    
    // SwiftUI로 이벤트 전달을 위한 콜백 추가
    var onPinSelected: ((KakaoMapPin?) -> Void)?
    
    required init?(coder: NSCoder) {
        observerAdded = false
        appeared = false
        super.init(coder: coder)
    }
    
    deinit {
        infoView?.isHidden = true
        controller.stopRendering()
        controller.stopEngine()
        _mapTapEventHandler?.dispose()
    }
    
    static func create(with viewModel: KakaoPointMapViewModel) -> KakaoPointMapViewController {
        let view = KakaoPointMapViewController.instantiateViewController(boardName: .point)
        view.viewModel = viewModel
        
        return view
    }
    
    // 초기화.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initKakaoMap()
        self.bind(with: viewModel)
        
        //viewModel.viewDidLoad()
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        appeared = false
    }
    
    private func bind(with viewModel: KakaoPointMapViewModel) {
        viewModel.points.sink(receiveValue: { [weak self] points in
            guard let self = self else { return }
            
            self.createAreaRect(points: points)
        }).store(in: &cancelBag)
        
        viewModel.polylineItems.sink(receiveValue: { [weak self] polylines in
            guard let self = self else { return }
            
            self.createPolyLineShape(polylines)
        }).store(in: &cancelBag)
        
        viewModel.mapPinItems.sink(receiveValue: { [weak self] mapPins in
            guard let self = self else { return }
            
            self.pointMapPins = mapPins
            self.createPoiStartMapPins(mapPins)
        }).store(in: &cancelBag)
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
    
    // MARK: - action
    
    @IBAction func actionConvert(_ sender: UIButton) {
        if let pin = self.selMapPin {
            let loc = pin.locationData
            guard let lat = loc.latitude.toDouble(), let lon = loc.longitude.toDouble() else {
                return
            }
            
            pin.dmsType.next()
            self.convertBtn.setTitle(pin.dmsType.desc, for: .normal)
            switch pin.dmsType {
            case .D:
                self.latLb.text = "lat: \(loc.latitude)"
                self.lonLb.text = "lon: \(loc.longitude)"
            case .DM:
                self.latLb.text = "lat: \(String.DtoDM(with: lat))"
                self.lonLb.text = "lon: \(String.DtoDM(with: lon))"
            case .DMS:
                self.latLb.text = "lat: \(String.DtoDMS(with: lat))"
                self.lonLb.text = "lon: \(String.DtoDMS(with: lon))"
            }
        }
    }
    
}

// MARK: - kakao map private function
extension KakaoPointMapViewController: KakaoMapEventDelegate {
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
        addEventHandlers()
        createPolylineStyleSet()
        createLabelLayer()
        createPoiStyle()
        //createCurrentPoiLabelLayer()
        //createCurrentPoiStyle()
        
        viewModel.loadPointData()
        
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
    
    private func addEventHandlers() {
        guard let map = controller.getView("mapview") as? KakaoMap else {
            print("add event handler failed")
            return
        }
        
        _mapTapEventHandler = map.addMapTappedEventHandler(target: self, handler: KakaoPointMapViewController.mapDidTapped)
    }
    
    private func clearShapeManager() {
        shapeManager.removeShapeLayer(layerID: "")
    }
    
    func mapDidTapped(_ param: ViewInteractionEventParam) {
        self.infoView.isHidden = true
        
        // SwiftUI에 선택 해제 전달
        onPinSelected?(nil)
    }
    
    // MARK: - shape poi
    
    private func createLabelLayer() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    private func createPoiStyle() {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        
        // image style
        let iconStyle = PoiIconStyle(symbol: UIImage(named: "pin_red"), anchorPoint: CGPoint(x: 0.5, y: 1))
        
        // text style
        let red = TextStyle(fontSize: 24, fontColor: .white, strokeThickness: 2, strokeColor: .red)
        let blue = TextStyle(fontSize: 20, fontColor: .white, strokeThickness: 2, strokeColor: .blue)
        
        let textStyles = PoiTextStyle(textLineStyles: [
            PoiTextLineStyle(textStyle: red),
            PoiTextLineStyle(textStyle: blue)
        ])
        textStyles.textLayouts = [.bottom]
        
        let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: [
            PerLevelPoiStyle(iconStyle: iconStyle, level: 14),
            PerLevelPoiStyle(iconStyle: iconStyle, textStyle: textStyles, level: 16),
        ])
        
        manager.addPoiStyle(poiStyle)
    }
    
    private func createPoiStartMapPins(_ mapPins: [KakaoMapPin]) {
        let view = controller.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")
        
        for pin in mapPins {
            let poiOption = PoiOptions(styleID: "PerLevelStyle", poiID: "\(pin.locationData.sequence)")
            poiOption.rank = 0
            poiOption.clickable = true
            
            poiOption.addText(PoiText(text: "\(pin.locationData.kmh) km/h", styleIndex: 0))
            poiOption.addText(PoiText(text: "\(pin.locationData.knot) knot", styleIndex: 1))
            
            let point = pin.mapPoint
            let poi = layer?.addPoi(option: poiOption, at: point)
            let _ = poi?.addPoiTappedEventHandler(target: self, handler: KakaoPointMapViewController.poiTappedHandler)
            poi?.show()
        }
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
    
    private func createAreaRect(points: [MapPoint]) {
        guard let view = controller.getView("mapview") as? KakaoMap else {
            print("fail rect point camara area")
            return
        }
        
        let cameraUpdate = CameraUpdate.make(area: AreaRect(points: points))
        view.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: true, consecutive: true, durationInMillis: 2000))
    }
    
    private func createPolyLineShape(_ polylines: [MapPolyline]) {
        let layer = shapeManager.getShapeLayer(layerID: "PolylineLayer")
        let options = MapPolylineShapeOptions(shapeID: "mapPolylines", styleID: "polylineStyleSet", zOrder: 1)
        options.polylines = polylines
        
        let shape = layer?.addMapPolylineShape(options)
        shape?.show()
    }
}

// MARK: - kakao map delegate function
extension KakaoPointMapViewController: MapControllerDelegate {
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
    
    func poiTappedHandler(_ param: PoiInteractionEventParam) {
        print("poi \(param.poiItem.itemID)")
        var pin: KakaoMapPin!
        for mapPin in self.pointMapPins! {
            if mapPin.locationData.sequence == Int(param.poiItem.itemID) {
                pin = mapPin
                break
            }
        }
        
        let locationData = pin.locationData
        self.timeLb.text = "time: \(locationData.time)"
        self.latLb.text = "lat: \(locationData.latitude)"
        self.lonLb.text = "lon: \(locationData.longitude)"
        self.kmhLb.text = "\(locationData.kmh) km/h"
        self.knotLb.text = "\(locationData.knot) knot"
        self.sequenceLb.text = "sequence: \(locationData.sequence)"
        self.convertBtn.setTitle(DMSType.D.desc, for: .normal)
        
        self.infoView.isHidden = false
        
        self.selMapPin = pin
        
        // SwiftUI로 이벤트 전달
        onPinSelected?(pin)
    }
}
