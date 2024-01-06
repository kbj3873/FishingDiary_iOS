//
//  MapViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/05.
//

import UIKit
import MapKit
import CoreLocation
import Combine

class TrackMapViewController: UIViewController, StoryboardInstantiable {
    
    private var viewModel: TrackMapViewModel!
    
    var cancelBag = Set<AnyCancellable>()   // > combine
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var speedLb: UILabel!
    @IBOutlet var latitudeLb: UILabel!
    @IBOutlet var longitudeLb: UILabel!
    
    static func create(with viewModel: TrackMapViewModel) -> TrackMapViewController {
        let view = TrackMapViewController.instantiateViewController(boardName: .main)
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMapView()
        self.bind(with: viewModel)
        
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.viewWillDisappear()
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

// MARK: - private function
extension TrackMapViewController {
    private func initMapView() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    // > combine
    private func bind(with viewModel: TrackMapViewModel) {
        viewModel.mapLineItem.sink(receiveValue: { [weak self] mapLine in
            guard let self = self else {return}
            
            let previousLocation = mapLine.previousLocation
            let currentLocation = mapLine.currentLocation
            
            self.updateUI(currentLocation)
            self.updateMapLine(previousLocation, currentLocation)
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
        let previousCoordinate = previousLocation.coordinate
        let currentCoordinate = currentLocation.coordinate
        var area = [previousCoordinate, currentCoordinate]
        let poliline = MKPolyline(coordinates: &area, count: area.count)
        mapView.addOverlay(poliline)
    }
}

// MARK: - map delegate
extension TrackMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            //print("draw polyline")
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red
            
            if let info = viewModel.getLocationList().last {
                let speed = info.locationInfo.speed
                if Float(speed * 3.6) > FDAppManager.pointVelocity {
                    polylineRenderer.strokeColor = UIColor.blue
                }
            }
            
            polylineRenderer.lineWidth = 2.0
            return polylineRenderer
        }
        
        else {
            return MKPolylineRenderer()
        }
    }
}

// MARK: - Extension UIViewController for show TrackMapViewController
/*
extension UIViewController {
    func showMapView() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrackMapViewController") as? TrackMapViewController {
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }
}
*/
