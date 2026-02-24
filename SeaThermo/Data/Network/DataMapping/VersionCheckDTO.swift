//
//  VersionCheckDTO.swift
//  SeaThermo
//

import Foundation

// MARK: - Request DTO
struct VersionCheckRequestDTO: Encodable {
    let app_version: String
}

// MARK: - Response DTO
struct VersionCheckResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case minimumVersion = "minimum_version"
        case latestVersion = "latest_version"
        case forceUpdate = "force_update"
        case needUpdate = "need_update"
        case message
    }
    
    let minimumVersion: String
    let latestVersion: String
    let forceUpdate: Bool
    let needUpdate: Bool
    let message: String
}

// MARK: - Domain 변환
extension VersionCheckResponseDTO {
    func toDomain() -> VersionStatus {
        return VersionStatus(
            minimumVersion: minimumVersion,
            latestVersion: latestVersion,
            forceUpdate: forceUpdate,
            needUpdate: needUpdate,
            message: message
        )
    }
}
