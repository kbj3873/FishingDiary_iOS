//
//  VersionStatus.swift
//  SeaThermo
//

import Foundation

/// 버전 체크 결과 엔티티
struct VersionStatus {
    /// 최소 지원 버전 (이 버전 미만은 강제 업데이트)
    let minimumVersion: String
    /// App Store 최신 버전
    let latestVersion: String
    /// 강제 업데이트 여부 (true면 취소 불가)
    let forceUpdate: Bool
    /// 업데이트 필요 여부
    let needUpdate: Bool
    /// 서버 메시지
    let message: String
}
