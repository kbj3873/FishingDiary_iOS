//
//  RisaListDTO.swift
//  SeaThermo
//

import Foundation

// MARK: - Request DTO

struct RisaListRequestDTO: Encodable {
    private enum CodingKeys: String, CodingKey {
        case key
        case id
        case gruNam = "gru_nam"
    }
    let key: String
    let id: String
    let gruNam: String
    
    init(_ query: CurrentTemperatureQuery) {
        self.key = query.key
        self.id = query.id
        self.gruNam = query.gruNam
    }
}


// MARK: - Response DTO

struct RisaListResponseDTO: Decodable {
    let header: RisaListHeaderDTO
    let body: RisaListBodyDTO
}

struct RisaListHeaderDTO: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct RisaListBodyDTO: Decodable {
    var item: [RisaListItemDTO]?
}

struct RisaListItemDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case gruNam     = "gru_nam"
        case staCde     = "sta_cde"
        case obsLay     = "obs_lay"
        case staNamKor  = "sta_nam_kor"
        case wtrTmp     = "wtr_tmp"
    }
    
    var gruNam: String?
    var staCde: String?
    var obsLay: String?
    var staNamKor: String?
    var wtrTmp: String?
    
    func toDomain() -> CurrentTemperature {
        return .init(gruNam: gruNam ?? "",
                     staCde: staCde ?? "",
                     obsLay: obsLay ?? "",
                     staNamKor: staNamKor ?? "",
                     wtrTmp: wtrTmp ?? "")
    }
}
