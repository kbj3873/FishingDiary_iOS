//
//  AppInfoHeaders.swift
//  SeaThermo
//

import UIKit
import Darwin

/// 온바다 서버 전용 앱/디바이스 정보 HTTP 헤더를 생성하는 유틸리티
enum AppInfoHeaders {
    
    /// 온바다 서버 요청에 포함될 앱 정보 헤더 딕셔너리 반환
    static func make() -> [String: String] {
        return [
            "X-App-Version":  appVersion,
            "X-App-Build":    appBuild,
            "X-OS-Name":      "iOS",
            "X-OS-Version":   UIDevice.current.systemVersion,
            "X-Device-Model": deviceModel,
            "X-Bundle-Id":    bundleId
        ]
    }
    
    // MARK: - Private
    
    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
    private static var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }
    
    private static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }
    
    /// sysctl로 기기 하드웨어 식별자 읽기 (예: iPhone15,2)
    private static var deviceModel: String {
        var sysInfo = utsname()
        uname(&sysInfo)
        let machineMirror = Mirror(reflecting: sysInfo.machine)
        return machineMirror.children.compactMap { child -> Character? in
            guard let value = child.value as? Int8, value != 0 else { return nil }
            return Character(UnicodeScalar(UInt8(bitPattern: value)))
        }
        .map { String($0) }
        .joined()
    }
}
