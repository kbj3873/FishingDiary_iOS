//
//  APIEndpoints.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation
import UIKit

struct APIEndpoints {
    static func getRisaJson<T: Encodable, R>(with requestDTO: T) -> Endpoint<R> {
        
        return Endpoint(path: "OpenAPI_json",
                        method: .post,
                        queryParametersEncodable: requestDTO
        )
    }
    
    static func getRisaXml<T: Encodable, R>(with requestDTO: T) -> Endpoint<R> {
        
        return Endpoint(path: "risa/risaInfo.risa",
                        method: .post,
                        queryParametersEncodable: requestDTO
        )
    }
    
    // MARK: - 신규 온바다/RISA API (JSON Type)
    static func searchRisaInfoList<R>(with requestDTO: OceanInfoRequestDTO) -> Endpoint<R> {
        // WAF 우회 필수 헤더
        var headers: [String: String] = [:]
        headers["Referer"] = "https://www.nifs.go.kr/risa/risa/risaA/actionRisaInfo.do"
        headers["X-Requested-With"] = "XMLHttpRequest"
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        // User-Agent: URLSession 기본값을 쓰거나, Endpoint 내부 생성 시점에 추가 가능
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        headers["User-Agent"] = "SeaThermo/\(appVersion) (iPhone; iOS \(UIDevice.current.systemVersion))"
        
        let bodyParams: [String: Any] = [
            "obsrvnGroupNm": requestDTO.obsrvnGroupNm,
            "obsvtrCd": requestDTO.obsvtrCd,
            "obsFrom": requestDTO.obsFrom,
            "obsTo": requestDTO.obsTo,
            "ord": requestDTO.ord,
            "ordType": requestDTO.ordType,
            "rst-sel": requestDTO.rstSel,
            "obsTimeFrom": requestDTO.obsTimeFrom,
            "obsTimeTo": requestDTO.obsTimeTo,
            "obsTimeDefault": requestDTO.obsTimeDefault,
            "selectPage": requestDTO.selectPage,
            "rowCountPage": requestDTO.rowCountPage
        ]
        
        return Endpoint(path: "risa/risa/risaA/searchRisaInfoList.do",
                        method: .post,
                        headerParameters: headers,
                        bodyParameters: bodyParams,
                        bodyEncoder: AsciiBodyEncoder())
    }
    
    // MARK: - 온바다 서버 API
    static func postVersionCheck(with requestDTO: VersionCheckRequestDTO) -> Endpoint<VersionCheckResponseDTO> {
        return Endpoint(path: "api/version/check",
                        method: .post,
                        bodyParametersEncodable: requestDTO)
    }
}
