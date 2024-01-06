//
//  PointMapViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/11.
//

import UIKit
import MapKit
import Combine

class PointMapViewController: UIViewController, StoryboardInstantiable {
    
    private var viewModel: PointMapViewModel!
    
    private var cancelBag = Set<AnyCancellable>()
    
    //private var path: URL!
    
    //var pointList = [LocationData]()
    
    var selMapPin: MapPin?
    
    @IBOutlet var mapView: MKMapView!
        
    @IBOutlet var infoView: UIView!
    
    @IBOutlet var timeLb: UILabel!
    @IBOutlet var latLb: UILabel!
    @IBOutlet var lonLb: UILabel!
    
    @IBOutlet var kmhLb: UILabel!
    @IBOutlet var knotLb: UILabel!
    @IBOutlet var sequenceLb: UILabel!
    
    @IBOutlet var convertBtn: UIButton!
    
    static func create(with viewModel: PointMapViewModel) -> PointMapViewController {
        let view = PointMapViewController.instantiateViewController(boardName: .main)
        view.viewModel = viewModel
        
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMapView()
        
        self.bind(with: viewModel)
        
        viewModel.viewDidLoad()
        //drawStartPoint()
    }
    
    private func initMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - private functions
extension PointMapViewController {
    func bind(with viewModel: PointMapViewModel) {
        viewModel.polyLineItems.sink(receiveValue: { [weak self] polyLines in
            guard let self = self else { return }
            
            self.mapView.addOverlays(polyLines)
        }).store(in: &cancelBag)
        
        viewModel.regionItem.sink(receiveValue: { [weak self] region in
            guard let self = self else { return }
            
            self.mapView.setRegion(region, animated: true)
        }).store(in: &cancelBag)
        
        viewModel.mapPinItems.sink(receiveValue: { [weak self] mapPins in
            guard let self = self else { return }
            
            self.mapView.addAnnotations(mapPins)
        }).store(in: &cancelBag)
    }
    
    func drawStartPoint() {
        var locationList = [LocationData]()
        if let startPointList = FDFileManager.shared.getStartPointFile(fileName: "230916_point") {
            //print("\(String(describing: startPointList))")
            
            for stPoint in startPointList {
                let latitude = String(format: "%f", String.DMStoD(with: stPoint.latitude))
                let longitude = String(format: "%f", String.DMStoD(with: stPoint.longitude))
//                let latitude = String(format: "%.6f", DMStoD(val: stPoint.latitude))
//                let longitude = String(format: "%.6f", DMStoD(val: stPoint.longitude))
                
                // > testcode
                if let lat = latitude.toDouble(), let lon = longitude.toDouble() {
                    print("\(stPoint.sequence). \(String.DtoDM(with: lat)), \(String.DtoDM(with: lon))")
                }
                
                //print("seq: \(stPoint.sequence), lat: \(latitude) lon: \(longitude)")
                let location = LocationData(time: stPoint.time,
                                         latitude: latitude,
                                         longitude: longitude,
                                         kmh: "", knot: "",
                                         sequence: stPoint.sequence)
                locationList.append(location)
            }
        }
        
        if locationList.count > 0 {
            for location in locationList {
                if let lat = Double(location.latitude), let lon = Double(location.longitude) {
                    let point = CLLocationCoordinate2D(
                        latitude: lat,
                        longitude: lon
                    )
                    
                    guard let img = UIImage(named: "start_point") else {return}
                    let annotation = MapPin(title: "point \(location.sequence)", subtitle: "", coordinate: point, locationData: location, image: img, dmsType: .D)
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
}

extension PointMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let overlay = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = (overlay.title == "point") ? UIColor.red:UIColor.blue
        polylineRenderer.lineWidth = 2.0
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let antn = annotation as? MapPin {
            let identifier = "point"
            //print("draw annotation view title: \(String(describing: antn.title))") // > testcode
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = antn
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                annotationView.image = antn.image
                return annotationView
            }
            
            else {
                let annotationView = MKPinAnnotationView(annotation: antn, reuseIdentifier: identifier)
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                annotationView.image = antn.image
                
                let btn = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = btn
                return annotationView
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MapPin {
            let locationData = annotation.locationData
            self.timeLb.text = "time: \(locationData.time)"
            self.latLb.text = "lat: \(locationData.latitude)"
            self.lonLb.text = "lon: \(locationData.longitude)"
            self.kmhLb.text = "\(locationData.kmh) km/h"
            self.knotLb.text = "\(locationData.knot) knot"
            self.sequenceLb.text = "sequence: \(locationData.sequence)"
            self.convertBtn.setTitle(DMSType.D.desc, for: .normal)
            
            self.infoView.isHidden = false
            
            self.selMapPin = annotation
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        self.infoView.isHidden = true
    }
}

// MARK: - Extension UIViewController for show PointMapViewController
extension UIViewController {
    func showPointView(path: URL) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PointMapViewController") as? PointMapViewController {
            //vc.path = path
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }
}
