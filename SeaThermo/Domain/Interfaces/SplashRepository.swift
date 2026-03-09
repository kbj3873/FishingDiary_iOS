//
//  SplashRepository.swift
//  SeaThermo
//

import Foundation

/// 스플래시 화면 시작 시 필요한 API 호출을 담당하는 Repository 프로토콜
protocol SplashRepository {
    /// 앱 버전 체크 API 호출
    func checkVersion(appVersion: String) async throws -> VersionStatus
    
    /// 전체 지역(관측소) 목록 API 호출
    func fetchRegions() async throws -> [Region]
}
