//
//  CurrentTemperature.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

struct CurrentTemperatureQuery: Equatable {
    var key: String
    var id: String
    var gruNam: String
}

struct CurrentTemperature: Equatable {
    var gruNam: String
    var staCde: String
    var obsLay: String
    var staNamKor: String
    var wtrTmp: String
}

struct CombinedCurrentTemperature: Codable, Hashable {
    var stationCode: String
    var stationName: String
    var surTempurature: String
    var midTempurature: String
    var botTempurature: String
    var seaName: String = ""
    var isChecked: Bool = false
}
