//
//  SplashRepository.swift
//  SeaThermo
//

import Foundation

/// 스플래시 화면 시작 시 필요한 API 호출을 담당하는 Repository 프로토콜
/// 향후 공지사항, 온보딩 데이터 등 스플래시 관련 API 추가 시 이 프로토콜을 확장
protocol SplashRepository {
    /// 앱 버전 체크 API 호출
    @discardableResult
    func checkVersion(appVersion: String,
                      completion: @escaping (Result<VersionStatus, Error>) -> Void) -> Cancellable?
}
