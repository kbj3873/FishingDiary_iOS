//
//  APIEndpoints.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

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
    
    // MARK: - 온바다 서버 API
    static func postVersionCheck(with requestDTO: VersionCheckRequestDTO) -> Endpoint<VersionCheckResponseDTO> {
        return Endpoint(path: "api/version/check",
                        method: .post,
                        bodyParametersEncodable: requestDTO)
    }
}
