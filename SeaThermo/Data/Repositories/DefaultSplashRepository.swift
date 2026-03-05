//
//  DefaultSplashRepository.swift
//  SeaThermo
//

import Foundation

final class DefaultSplashRepository: SplashRepository {
    private let dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    func checkVersion(appVersion: String) async throws -> VersionStatus {
        let requestDTO = VersionCheckRequestDTO(app_version: appVersion)
        let endpoint = APIEndpoints.postVersionCheck(with: requestDTO)
        let responseDTO: VersionCheckResponseDTO = try await dataTransferService.request(with: endpoint)
        return responseDTO.toDomain()
    }
}
