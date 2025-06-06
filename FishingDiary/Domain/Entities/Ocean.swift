//
//  Ocean.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

struct Header: Equatable {
    let resultCode: String
    let resultMsg: String
}

struct RisaResponse {
    let header: Header
    let body: RisaBody<Any>?
}

struct RisaBody<T> {
    let item: [T]
}

// > id=risaList 응답 item
struct RisaList: Equatable {
    var gruNam: String
    var staCde: String
    var obsLay: String
    var staNamKor: String
    var wtrTmp: String
}

// > id=risaCode 응답 item
struct RisaCode: Equatable {
    var gruNam: String
    var staCde: String
    var staNamKor: String
}

// > id=cooList 응답 item
struct RisaCoo: Equatable {
    let gruNam: String
    let staCde: String
    let staNamKor: String
    let obsDate: String
    let wtrTmp: String
}

struct OceanResponse: Equatable {
    private enum CodingKeys: String, CodingKey {
        case list
    }
    
    let list: [Ocean]
}

struct Ocean: Equatable {
    let staCde: String
    let staNamKor: String
    let staNam: String
    let obsDtm: String
    let wtrTempS: Float
    let surDep: Float
    let wtrTempM: Float
    let midDep: Float
    let wtrTempB: Float
    let botDep: Float
    let lon: Float
    let lat: Float
    
    var dateT: Int
}

struct OceanStationModel: Codable {
    var stationCode: String
    var stationName: String
    var surTempurature: String
    var midTempurature: String
    var botTempurature: String
    var isChecked: Bool = false
}
