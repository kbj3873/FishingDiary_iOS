//
//  DefaultSplashRepository.swift
//  SeaThermo
//

import Foundation

final class DefaultSplashRepository: SplashRepository {
    private let apiNetworkService: NetworkService
    
    init(apiNetworkService: NetworkService) {
        self.apiNetworkService = apiNetworkService
    }
    
    func checkVersion(appVersion: String) async throws -> VersionStatus {
        let requestDTO = VersionCheckRequestDTO(app_version: appVersion)
        let endpoint = APIEndpoints.postVersionCheck(baseURL: apiNetworkService.baseURL, with: requestDTO)
        let responseDTO: VersionCheckResponseDTO = try await apiNetworkService.request(with: endpoint)
        return responseDTO.toDomain()
    }
}
