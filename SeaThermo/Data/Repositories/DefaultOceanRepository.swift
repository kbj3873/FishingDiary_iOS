//
//  DefaultOceanRepository.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

final class DefaultOceanRepository {
    private let apiDataTransferService: DataTransferService
    
    init(apiDataTransferService: DataTransferService) {
        self.apiDataTransferService = apiDataTransferService
    }
}

extension DefaultOceanRepository: OceanRepository {
    
    func fetchRisaList(query: RisaListQuery) async throws -> RisaResponse {
        let requestDTO = RisaListRequestDTO(query: query)
        let endpoint = APIEndpoints.getRisaJson(with: requestDTO) as Endpoint<RisaListResponseDTO>
        let responseDTO: RisaListResponseDTO = try await apiDataTransferService.request(with: endpoint)
        return responseDTO.toDomain()
    }
    
    func fetchStationCode(query: RisaCodeQuery) async throws -> RisaResponse {
        let requestDTO = RisaCodeRequestDTO(query: query)
        let endpoint = APIEndpoints.getRisaJson(with: requestDTO) as Endpoint<RisaCodeResponseDTO>
        let responseDTO: RisaCodeResponseDTO = try await apiDataTransferService.request(with: endpoint)
        return responseDTO.toDomain()
    }
    
    func fetchRisaCoo(query: RisaCooQuery) async throws -> RisaResponse {
        let requestDTO = RisaCooRequestDTO(query: query)
        let endpoint = APIEndpoints.getRisaJson(with: requestDTO) as Endpoint<CooListResponseDTO>
        let responseDTO: CooListResponseDTO = try await apiDataTransferService.request(with: endpoint)
        return responseDTO.toDomain()
    }
    
    func fetchTemperature(query: OceanQuery) async throws -> OceanResponse {
        // 신규 API 스펙에 맞는 RequestDTO 변환
        let requestDTO = query.toOceanInfoRequestDTO()
        
        // 신규 JSON 엔드포인트 생성
        let endpoint = APIEndpoints.searchRisaInfoList(with: requestDTO) as Endpoint<OceanInfoResponseDTO>
        
        let responseDTO: OceanInfoResponseDTO = try await apiDataTransferService.request(with: endpoint)
        print("OceanInfo API task success")
        // DTO -> Domain Entity 반환
        return responseDTO.toDomain()
    }
}
