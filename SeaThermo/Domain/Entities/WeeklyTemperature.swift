//
//  WeeklyTemperature.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/14.
//

import Foundation

struct SeaAnalysisQuery: Equatable {
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

struct WeeklyTemperature: Equatable {
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
