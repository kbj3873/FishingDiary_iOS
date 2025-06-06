//
//  FDUserDefault.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/30/25.
//

import Foundation

/// - 사용의 간편성을 위해 전역변수로 정의해 둔다.
/// - UserDefaults.standard의 줄임형태
let FDUserDefaults = UserDefaults.standard

class UserDefaultKey: NSObject {
    
    /// 메인화면 노출되는 수온 지역 리스트
    static let regionalSeaTempuratureList = "regionalSeaTempuratureList"
}
