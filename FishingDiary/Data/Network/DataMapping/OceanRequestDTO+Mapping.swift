//
//  OceanRequestDTO+Mapping.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

struct RisaListRequestDTO: Encodable {
    private enum CodingKeys: String, CodingKey {
        case key
        case id
        case gruNam = "gru_nam"
    }
    let key: String
    let id: String
    let gruNam: String
    
    init(query: RisaListQuery) {
        self.key = query.key
        self.id = query.id
        self.gruNam = query.gruNam
    }
}

struct RisaCodeRequestDTO: Encodable {
    private enum CodingKeys: String, CodingKey {
        case key
        case id
        case gruNam = "gru_nam"
        case useYn = "use_yn"
    }
    let key: String
    let id: String
    let gruNam: String
    let useYn: String
    
    init(query: RisaCodeQuery) {
        self.key = query.key
        self.id = query.id
        self.gruNam = query.gruNam
        self.useYn = query.useYn
    }
}


struct RisaCooRequestDTO: Encodable {
    private enum CodingKeys: String, CodingKey {
        case key
        case id
        case sDate = "sdate"
        case eDate = "edate"
    }
    let key: String
    let id: String
    let sDate: String
    let eDate: String
    
    init(query: RisaCooQuery) {
        self.key = query.key
        self.id = query.id
        self.sDate = query.sDate
        self.eDate = query.eDate
    }
}

struct OceanRequestDTO: Encodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case gruNam = "gru_nam"
        case useYn = "use_yn"
        case staCde = "sta_cde"
        case dataCnt = "data_cnt"
        case ord
        case ordType = "ord_type"
        case obsFrom = "obs_from"
        case obsTo = "obs_to"
    }
    let id: String
    let gruNam: String
    let useYn: String
    let staCde: String
    let dataCnt: String
    let ord: String
    let ordType: String
    let obsFrom: String
    let obsTo: String
}
