//
//  FDUserDefault.swift
//  SeaThermo
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
    
    /// 지도 종류 (0: Apple, 1: Kakao)
    static let mapType = "mapType"
    
    /// 온보딩 가이드 완료 여부
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    
    /// 서버에서 내려받은 전체 지역(관측소) 리스트 캐싱
    static let allRegionList = "allRegionList"

    /// 크롤링 기반 현재수온 탭 즐겨찾기 지역 리스트 (Region 타입, 최대 7개)
    static let crawlingFavoriteRegions = "crawlingFavoriteRegions"

    /// 낚시기록 탭 안내 팝업 다시 보지 않기 여부
    static let hideFishingRecordGuidePopup = "hideFishingRecordGuidePopup"
}
