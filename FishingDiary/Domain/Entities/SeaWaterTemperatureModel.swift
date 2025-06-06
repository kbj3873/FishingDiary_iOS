//
//  SeaWaterTemperatureModel.swift
//  FishingDiary
//
//  Created by Y0000591 on 12/17/24.
//

import Foundation

struct SeaWaterTemperatureRequestModel: Encodable {
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

struct SeaWaterTempuratureSet: Equatable {
    let surTemp: CGFloat
    let midTemp: CGFloat
    let botTemp: CGFloat
    let surDep: Float
    let midDep: Float
    let botDep: Float
    let dateTime: Int
}

