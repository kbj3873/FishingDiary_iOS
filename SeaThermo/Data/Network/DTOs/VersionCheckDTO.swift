//
//  VersionCheckDTO.swift
//  SeaThermo
//

import Foundation

// MARK: - Request DTO
struct VersionCheckRequestDTO: Encodable {
    let app_version: String
}

// MARK: - Response DTO (API 공통 래퍼 구조)
struct VersionCheckResponseDTO: Decodable {
    let resultCode: Int
    let resultMsg: String
    let data: VersionCheckDataDTO?
}

struct VersionCheckDataDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case minimumVersion = "minimum_version"
        case latestVersion  = "latest_version"
        case forceUpdate    = "force_update"
        case needUpdate     = "need_update"
        case message
    }
    
    let minimumVersion: String
    let latestVersion:  String
    let forceUpdate:    Bool
    let needUpdate:     Bool
    let message:        String
}

// MARK: - Domain 변환
extension VersionCheckResponseDTO {
    func toDomain() -> VersionStatus {
        guard let data = data else {
            return VersionStatus(minimumVersion: "", latestVersion: "", forceUpdate: false, needUpdate: false, message: "")
        }
        return VersionStatus(
            minimumVersion: data.minimumVersion,
            latestVersion:  data.latestVersion,
            forceUpdate:    data.forceUpdate,
            needUpdate:     data.needUpdate,
            message:        data.message
        )
    }
}

