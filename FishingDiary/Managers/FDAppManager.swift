//
//  FDAppManager.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/08.
//

import Foundation

class FDAppManager: NSObject {
    static let shared = FDAppManager()
    
    static let saveForPoints: Int   = 200           // > 저장할 포인트 개수 단위
    static let kmhKnot      : Float = 1.852         // > 1knot = 1.852km/h
    static let pointVelocity: Float = 2 * kmhKnot   // > 해당속도 미만일경우 포인트 구간으로 간주
    
    func appInitialize() {
        FDFileManager().createDefaultDirectories()
    }
}
