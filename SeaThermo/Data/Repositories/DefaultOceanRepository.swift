//
//  DefaultOceanRepository.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

final class DefaultOceanRepository {
    private let apiNetworkService: NetworkService
    
    init(apiNetworkService: NetworkService) {
        self.apiNetworkService = apiNetworkService
    }
}

extension DefaultOceanRepository: OceanRepository {
    // 현재수온 가져오기
    func fetchRisaList(_ query: CurrentTemperatureQuery) async throws -> [CurrentTemperature] {
        let requestDTO = RisaListRequestDTO(query)
        let endpoint = APIEndpoints.getRisaJson(baseURL: apiNetworkService.baseURL, with: requestDTO) as Endpoint<RisaListResponseDTO>
        let responseDTO: RisaListResponseDTO = try await apiNetworkService.request(with: endpoint)
        
        // resultCode가 정상("00")이 아닌 경우 에러를 반환
        if responseDTO.header.resultCode != "00" {
            let userFriendlyMessage = "해양 관측 데이터를 불러오는 데 실패했습니다."
            throw NetworkError.apiError(code: responseDTO.header.resultCode, message: userFriendlyMessage)
        }
        
        return responseDTO.body.item?.map { $0.toDomain() } ?? []
    }
    // 지난 7일간 수온 가져오기
    func fetchTemperature(_ query: SeaAnalysisQuery) async throws -> [WeeklyTemperature] {
        // 신규 API 스펙에 맞는 RequestDTO 변환
        let requestDTO = RisaInfoListRequestDTO(query)
        
        // 신규 JSON 엔드포인트 생성
        let endpoint = APIEndpoints.searchRisaInfoList(baseURL: apiNetworkService.baseURL, with: requestDTO) as Endpoint<RisaInfoResponseDTO>
        
        let responseDTO: RisaInfoResponseDTO = try await apiNetworkService.request(with: endpoint)
        print("RisaInfo API task success")
        // DTO -> Domain Entity 반환
        return responseDTO.retList.map { $0.toDomain() }
    }
}
