//
//  RisaInfoDTO.swift
//  SeaThermo
//

import Foundation

// MARK: - Request DTO

struct RisaInfoListRequestDTO: Encodable {
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
    
    init(_ query: SeaAnalysisQuery) {
        self.obsrvnGroupNm = query.gruNam
        self.obsvtrCd = query.staCde
        self.obsFrom = query.obsFrom
        self.obsTo = query.obsTo
        self.ord = query.ord
        self.ordType = query.ordType
    }
}

// MARK: - Response DTO

struct RisaInfoResponseDTO: Decodable {
    let retList: [RisaInfoItemDTO]
}

struct RisaInfoItemDTO: Decodable {
    let obsrvnDt: String      // "2026-02-21 10:00"
    let wtrTempS: String      // 표층
    let wtrTempM: String      // 중층
    let wtrTempB: String      // 저층
    let obsvtrKornNm: String  // 관측소 이름 (실제 API 필드명에 n 포함)
    let obsvtrNm: String?     // "관측소명(코드)" 형식 (옵셔널)
    let obsvtrCd: String?     // 관측소 코드 (옵셔널)
    let lat: String?          // 위도
    let lot: String?          // 경도
    let sfclyrDpwt: Int?      // 표층 수심(m)
    let mlyrDpwt: String?     // 중층 수심 (문자열 혹은 빈문자열 가능성)
    let btmlyrDpwt: String?   // 저층 수심
    
    enum CodingKeys: String, CodingKey {
        case obsrvnDt, wtrTempS, wtrTempM, wtrTempB, obsvtrKornNm, obsvtrNm, obsvtrCd, lat, lot, sfclyrDpwt, mlyrDpwt, btmlyrDpwt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        obsrvnDt = try container.decodeIfPresent(String.self, forKey: .obsrvnDt) ?? ""
        
        if let temp = try? container.decodeIfPresent(String.self, forKey: .wtrTempS) { wtrTempS = temp }
        else if let tempD = try? container.decodeIfPresent(Double.self, forKey: .wtrTempS) { wtrTempS = String(tempD) }
        else { wtrTempS = "" }
        
        if let temp = try? container.decodeIfPresent(String.self, forKey: .wtrTempM) { wtrTempM = temp }
        else if let tempD = try? container.decodeIfPresent(Double.self, forKey: .wtrTempM) { wtrTempM = String(tempD) }
        else { wtrTempM = "" }
        
        if let temp = try? container.decodeIfPresent(String.self, forKey: .wtrTempB) { wtrTempB = temp }
        else if let tempD = try? container.decodeIfPresent(Double.self, forKey: .wtrTempB) { wtrTempB = String(tempD) }
        else { wtrTempB = "" }
        
        obsvtrKornNm = try container.decodeIfPresent(String.self, forKey: .obsvtrKornNm) ?? ""
        obsvtrNm = try container.decodeIfPresent(String.self, forKey: .obsvtrNm)
        obsvtrCd = try container.decodeIfPresent(String.self, forKey: .obsvtrCd)
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .lat) { lat = val }
        else if let val = try? container.decodeIfPresent(Double.self, forKey: .lat) { lat = String(val) }
        else { lat = nil }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .lot) { lot = val }
        else if let val = try? container.decodeIfPresent(Double.self, forKey: .lot) { lot = String(val) }
        else { lot = nil }
        
        // 핵심: Int로 디코딩 후 안되면 String으로 파싱 시도 (""와 같은 예외 대응)
        if let val = try? container.decodeIfPresent(Int.self, forKey: .sfclyrDpwt) { sfclyrDpwt = val }
        else if let val = try? container.decodeIfPresent(String.self, forKey: .sfclyrDpwt) { sfclyrDpwt = Int(val) }
        else { sfclyrDpwt = nil }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .mlyrDpwt) { mlyrDpwt = val }
        else if let val = try? container.decodeIfPresent(Double.self, forKey: .mlyrDpwt) { mlyrDpwt = String(val) }
        else { mlyrDpwt = nil }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .btmlyrDpwt) { btmlyrDpwt = val }
        else if let val = try? container.decodeIfPresent(Double.self, forKey: .btmlyrDpwt) { btmlyrDpwt = String(val) }
        else { btmlyrDpwt = nil }
    }
    
    func toDomain() -> WeeklyTemperature {
        // 날짜 포맷팅: yyyy-MM-dd HH:mm -> yyyyMMddHHmm 형식의 Int로 변환 (Int 오버플로우 대비 Int 통일)
        let cleanDate = obsrvnDt.filter { $0.isNumber } // "202602211000"
        let dateT = Int(cleanDate) ?? 0
        
        let floatS = Float(wtrTempS) ?? -99.0
        let floatM = Float(wtrTempM) ?? -99.0
        let floatB = Float(wtrTempB) ?? -99.0
        
        let floatLat = Float(lat ?? "") ?? -99.0
        let floatLon = Float(lot ?? "") ?? -99.0
        
        let sDepth = Float(sfclyrDpwt ?? 0) > 0 ? Float(sfclyrDpwt!) : -99.0
        let mDepth = Float(mlyrDpwt ?? "") ?? -99.0
        let bDepth = Float(btmlyrDpwt ?? "") ?? -99.0
        
        return WeeklyTemperature(
            staCde: obsvtrCd ?? "",
            staNamKor: obsvtrKornNm,
            staNam: obsvtrNm ?? "",
            obsDtm: obsrvnDt,
            wtrTempS: floatS > 90 ? -99.0 : floatS, // 99.9 같은 에러 처리값인지 한번 더 체크
            surDep: sDepth,
            wtrTempM: floatM > 90 ? -99.0 : floatM,
            midDep: mDepth,
            wtrTempB: floatB > 90 ? -99.0 : floatB,
            botDep: bDepth,
            lon: floatLon,
            lat: floatLat,
            dateT: dateT
        )
    }
}

