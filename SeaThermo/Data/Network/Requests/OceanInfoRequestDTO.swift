//
//  OceanInfoRequestDTO.swift
//  SeaThermo
//

import Foundation

struct OceanInfoRequestDTO: Encodable {
    let obsrvnGroupNm: String // E, S, W
    let obsvtrCd: String      // bsc87 등
    let obsFrom: String       // 2026-02-21
    let obsTo: String         // 2026-02-27
    let ord: String           // "1"
    let ordType: String       // "A"
    
    // 추가 파라미터 (디폴트 값 고정)
    let rstSel: String = "on"
    let obsTimeFrom: String = "0000"
    let obsTimeTo: String = "2330"
    let obsTimeDefault: String = "N"
    let selectPage: String = "1"
    let rowCountPage: String = "1000" // 7일 데이터 전체를 가져오기 위해 넉넉한 수를 지정 (ex: 20 -> 1000)
    
    enum CodingKeys: String, CodingKey {
        case obsrvnGroupNm
        case obsvtrCd
        case obsFrom
        case obsTo
        case ord
        case ordType
        case rstSel = "rst-sel" // 캡처 화면 참고 (파라미터 키에 하이픈 존재)
        case obsTimeFrom
        case obsTimeTo
        case obsTimeDefault
        case selectPage
        case rowCountPage
    }
}
