//
//  FDAppManager.swift
//  SeaThermo
//
//  Created by Y0000591 on 2023/09/08.
//

import Foundation

class FDAppManager: NSObject {
    static let shared = FDAppManager()
    
    static let saveForPoints: Int   = 200           // > 저장할 포인트 개수 단위
    static let kmhKnot      : Float = 1.852         // > 1knot = 1.852km/h
    static let pointVelocity: Float = 2 * kmhKnot   // > 해당속도 미만일경우 포인트 구간으로 간주
    
    // MARK: - Fishing Record Constants
    static let speedThresholdHigh: Double = 2.0 // knots
    static let speedThresholdLow: Double = 0.5  // knots
    
    // MARK: - Fishing State
    enum FishingState: String {
        case moving = "이동 중"   // 2.0 knots 이상
        case drifting = "탐색 중" // 0.5 ~ 2.0 knots
        case fishing = "낚시 중"  // 0.5 knots 미만
    }
    
    var mapTp: MapType = .AppleMap           // > 초기 지도 종류
    
    func appInitialize() {
        FDFileManager().createDefaultDirectories()
    }
    
    func setMapTp(_ rawValue: Int) {
        switch rawValue {
        case 0:
            mapTp = .AppleMap
        case 1:
            mapTp = .KakaoMap
        default:
            mapTp = .AppleMap
        }
    }
}
