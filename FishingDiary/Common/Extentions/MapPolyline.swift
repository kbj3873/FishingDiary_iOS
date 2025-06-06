//
//  MapPolyline.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/01/31.
//

import KakaoMapsSDK

extension MapPolyline {
    struct PolylineInfo {
        static var _title: String?
        static var _color: UIColor?
        static var _kmh: Float?     // > 시속
        static var _knot: Float?  // > 노트
    }
    
    var title: String? {
        get {
            return PolylineInfo._title
        }
        set(newValue) {
            PolylineInfo._title = newValue
        }
    }
    
    var kmh: Float? {
        get {
            return PolylineInfo._kmh
        }
        set(newValue) {
            PolylineInfo._kmh = newValue
        }
    }
    
    var knot: Float? {
        get {
            return PolylineInfo._knot
        }
        set(newValue) {
            PolylineInfo._knot = newValue
        }
    }
    
    var color: UIColor? {
        get {
            return PolylineInfo._color
        }
        set(newValue) {
            PolylineInfo._color = newValue
        }
        /*
        get {
            if let kmh = PolylineInfo._kmh, kmh < FDAppManager.pointVelocity {
                return UIColor.red
            } else {
                return UIColor.blue
            }
        }
         */
    }
}
