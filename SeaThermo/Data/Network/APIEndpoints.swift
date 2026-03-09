//
//  APIEndpoints.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation
import UIKit

struct APIEndpoints {
    // MARK: - Open API (NIFS)
    static func getRisaJson<T: Encodable, R>(baseURL: String, with requestDTO: T) -> Endpoint<R> {
        
        return Endpoint(baseURL: baseURL,
                        path: "OpenAPI_json",
                        method: .post,
                        headerParameters: Headers.forOpenAPI(isJson: true),
                        queryParametersEncodable: requestDTO
        )
    }
    
    static func getRisaXml<T: Encodable, R>(baseURL: String, with requestDTO: T) -> Endpoint<R> {
        
        return Endpoint(baseURL: baseURL,
                        path: "risa/risaInfo.risa",
                        method: .post,
                        headerParameters: Headers.forOpenAPI(isJson: false),
                        queryParametersEncodable: requestDTO
        )
    }
    
    // MARK: - 신규 온바다/RISA API (JSON Type - 웹 크롤링 우회)
    static func searchRisaInfoList<R>(baseURL: String, with requestDTO: RisaInfoListRequestDTO) -> Endpoint<R> {
        
        return Endpoint(baseURL: baseURL,
                        path: "risa/risa/risaA/searchRisaInfoList.do",
                        method: .post,
                        headerParameters: Headers.forWebCrawling(),
                        bodyParametersEncodable: requestDTO,
                        bodyEncoder: AsciiBodyEncoder())
    }
    
    // MARK: - 온바다 서버 API
    static func postVersionCheck(baseURL: String, with requestDTO: VersionCheckRequestDTO) -> Endpoint<VersionCheckResponseDTO> {
        return Endpoint(baseURL: baseURL,
                        path: "api/version/check",
                        method: .post,
                        headerParameters: Headers.forSeaThermoAPI(),
                        bodyParametersEncodable: requestDTO)
    }
    
    static func postRegions(baseURL: String) -> Endpoint<RegionResponseDTO> {
        return Endpoint(baseURL: baseURL,
                        path: "api/regions",
                        method: .post,
                        headerParameters: Headers.forSeaThermoAPI())
    }
}

extension APIEndpoints {
    // MARK: - Headers
    struct Headers {
        static let defaultUserAgent: String = {
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            return "SeaThermo/\(appVersion) (iPhone; iOS \(UIDevice.current.systemVersion))"
        }()
        
        static func forOpenAPI(isJson: Bool = true) -> [String: String] {
            return [
                "Accept-Language": "ko-KR,ko;q=0.9",
                "Content-Type": isJson ? "application/json;utf-8" : "application/x-www-form-urlencoded",
            ]
        }
        
        static func forWebCrawling() -> [String: String] {
            return [
                "Referer": "https://www.nifs.go.kr/risa/risa/risaA/actionRisaInfo.do",
                "X-Requested-With": "XMLHttpRequest",
                "Content-Type": "application/x-www-form-urlencoded",
                // WAF(보안장비) 우회를 위해 모바일 사파리 등 표준 브라우저의 User-Agent를 명시적으로 사용
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
            ]
        }
        
        static func forSeaThermoAPI() -> [String: String] {
            var headers: [String: String] = [
                "Content-Type": "application/json",
                "Accept-Language": "ko-KR,ko;q=0.9",
                "User-Agent": defaultUserAgent
            ]
            // 앱 정보 헤더 병합
            headers.merge(appInfo()) { _, new in new }
            return headers
        }
        
        /// 온바다 서버 전용 앱/디바이스 정보 헤더 딕셔너리 반환
        static func appInfo() -> [String: String] {
            return [
                "X-App-Version":  appVersion,
                "X-App-Build":    appBuild,
                "X-OS-Name":      "iOS",
                "X-OS-Version":   UIDevice.current.systemVersion,
                "X-Device-Model": deviceModel,
                "X-Bundle-Id":    bundleId
            ]
        }
        
        // MARK: - AppInfo Private
        
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
}
