//
//  SplashUseCase.swift
//  SeaThermo
//

import Foundation

/// 스플래시 화면 비즈니스 로직 UseCase
/// 버전 체크 외 향후 스플래시 시 필요한 다른 동작(공지 조회 등) 추가 가능
final class SplashUseCase {
    private let repository: SplashRepository
    
    init(repository: SplashRepository) {
        self.repository = repository
    }
    
    /// 앱 버전을 받아 서버에 버전 체크 요청
    @discardableResult
    func executeVersionCheck(appVersion: String,
                             completion: @escaping (Result<VersionStatus, Error>) -> Void) -> Cancellable? {
        return repository.checkVersion(appVersion: appVersion, completion: completion)
    }
}
