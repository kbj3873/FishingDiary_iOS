//
//  SplashUseCase.swift
//  SeaThermo
//

import Foundation

protocol SplashUseCase {
    func checkVersion(appVersion: String) async throws -> VersionStatus
    func fetchRegions() async throws -> [Region]
}

/// 스플래시 화면 비즈니스 로직 UseCase
/// 버전 체크 외 향후 스플래시 시 필요한 다른 동작(공지 조회 등) 추가 가능
final class DefaultSplashUseCase: SplashUseCase {
    private let repository: SplashRepository
    
    init(repository: SplashRepository) {
        self.repository = repository
    }
    
    /// 앱 버전을 받아 서버에 버전 체크 요청
    func checkVersion(appVersion: String) async throws -> VersionStatus {
        try await repository.checkVersion(appVersion: appVersion)
    }
    
    /// 서버에서 활성 지역 리스트 조회
    func fetchRegions() async throws -> [Region] {
        try await repository.fetchRegions()
    }
}
