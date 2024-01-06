//
//  PointMap.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/14.
//

import Foundation
import MapKit

struct LocationData: Codable {
    var time: String
    var latitude: String
    var longitude: String
    var kmh: String
    var knot: String
    var sequence: Int
}

enum DMSType: Int {
    case D
    case DM
    case DMS
    
    var desc: String {
        switch self {
        case .D:
            return "D"
        case .DM:
            return "D/M"
        case .DMS:
            return "D/M/S"
        }
    }
    
    mutating func next() {
        self = DMSType(rawValue: rawValue + 1) ?? DMSType(rawValue: 0)!
    }
}

class MapPin: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let locationData: LocationData
    let image: UIImage
    var dmsType: DMSType
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, locationData: LocationData, image: UIImage, dmsType: DMSType) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.locationData = locationData
        self.image = image
        self.dmsType = dmsType
    }
}

struct LocationInfo {
    var locationData: LocationData
    var locationInfo: CLLocation
}

struct MapLineInfo {    // > combine
    var previousLocation: CLLocation
    var currentLocation: CLLocation
    
    init(_ previousLocation: CLLocation, _ currentLocation: CLLocation ) {
        self.previousLocation = previousLocation
        self.currentLocation = currentLocation
    }
}
