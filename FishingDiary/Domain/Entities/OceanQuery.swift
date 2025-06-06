//
//  OceanQuery.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/14.
//

import Foundation

protocol RisaQuery: Equatable {
    var key: String { set get }
    var id: String { get }
}

struct RisaListQuery: RisaQuery {
    var key: String
    var id: String
    var gruNam: String
}

struct RisaCodeQuery: RisaQuery {
    var key: String
    var id: String
    var gruNam: String
    var useYn: String
}

struct RisaCooQuery: RisaQuery {
    var key: String
    var id: String
    var sDate: String
    var eDate: String
}

struct OceanQuery: Equatable {
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
