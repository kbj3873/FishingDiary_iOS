//
//  DefaultSplashRepository.swift
//  SeaThermo
//

import Foundation

final class DefaultSplashRepository: SplashRepository {
    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    
    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }
    
    @discardableResult
    func checkVersion(appVersion: String,
                      completion: @escaping (Result<VersionStatus, Error>) -> Void) -> Cancellable? {
        let requestDTO = VersionCheckRequestDTO(app_version: appVersion)
        let task = RepositoryTask()
        
        let endpoint = APIEndpoints.postVersionCheck(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint, on: backgroundQueue) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
