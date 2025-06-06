//
//  OceanResponseDTO+Mapping.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

struct HeaderDTO: Decodable {
    let resultCode: String
    let resultMsg: String
    
    func toDomain() -> Header {
        return .init(resultCode: resultCode,
                     resultMsg: resultMsg)
    }
}

// > id=risaList
struct RisaListResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case header
        case body
    }
    
    var header: HeaderDTO
    var body: RisaListBodyDTO
    
    func toDomain() -> RisaResponse {
        return .init(header: header.toDomain(),
                     body: body.toDomain())
    }
}

extension RisaListResponseDTO {
    
    struct RisaListBodyDTO: Decodable {
        
        private enum CodingKeys: String, CodingKey {
            case item
        }
        
        let item: [RisaListItemDTO]
        
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
            
            func toDomain() -> RisaList {
                return .init(gruNam: gruNam ?? "",
                             staCde: staCde ?? "",
                             obsLay: obsLay ?? "",
                             staNamKor: staNamKor ?? "",
                             wtrTmp: wtrTmp ?? "")
            }
        }
        
        func toDomain() -> RisaBody<Any> {
            return .init(item: item.map{ ($0.toDomain()) })
        }
    }
}

// > id=risaCode
struct RisaCodeResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case header
        case body
    }
    
    var header: HeaderDTO
    var body: RisaCodeBodyDTO
    
    func toDomain() -> RisaResponse {
        return .init(header: header.toDomain(),
                     body: body.toDomain())
    }
}

extension RisaCodeResponseDTO {
    
    struct RisaCodeBodyDTO: Decodable {
        
        private enum CodingKeys: String, CodingKey {
            case item
        }
        
        let item: [RisaCodeItemDTO]
        
        func toDomain() -> RisaBody<Any> {
            return .init(item: item.map{ ($0.toDomain()) })
        }
    }
    
    struct RisaCodeItemDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case gruNam     = "gru_nam"
            case staCde     = "sta_cde"
            case staNamKor  = "sta_nam_kor"
        }
        
        var gruNam: String?
        var staCde: String?
        var staNamKor: String?
        
        func toDomain() -> RisaCode {
            return .init(gruNam: gruNam ?? "",
                         staCde: staCde ?? "",
                         staNamKor: staNamKor ?? "")
        }
    }
}

// > id=cooList
struct CooListResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case header
        case body
    }
    
    var header: HeaderDTO
    var body: CooListBodyDTO
    
    func toDomain() -> RisaResponse {
        return .init(header: header.toDomain(),
                     body: body.toDomain())
    }
}

extension CooListResponseDTO {
    
    struct CooListBodyDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case item
        }
        
        let item: [CooListItemDTO]
        
        func toDomain() -> RisaBody<Any> {
            return .init(item: item.map{ ($0.toDomain()) })
        }
    }
    
    struct CooListItemDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case gruNam     = "gru_nam"
            case staCde     = "sta_cde"
            case staNamKor  = "sta_nam_kor"
            case obsDate  = "obs_dat"
            case wtrTmp  = "wtr_tmp"
        }
        
        let gruNam: String?
        let staCde: String?
        let staNamKor: String?
        let obsDate: String?
        let wtrTmp: String?
        
        func toDomain() -> RisaCoo {
            return .init(gruNam: gruNam ?? "",
                         staCde: staCde ?? "",
                         staNamKor: staNamKor ?? "",
                         obsDate: obsDate ?? "",
                         wtrTmp: wtrTmp ?? "")
        }
    }
}



struct OceanResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case list
    }
    
    let list: [OceanDTO]
    
    func toDomain() -> OceanResponse {
        return .init(list: list.map{ ($0.toDomain()) })
    }
}

extension OceanResponseDTO {
    struct OceanDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case staCde     = "STA_CDE"         //관측소 코드
            case staNamKor  = "STA_NAM_KOR"     //관측소명
            case staNam     = "STA_NAM"         //수온
            case obsDtm     = "OBS_DTM"         //염분
            case wtrTempS   = "WTR_TEMP_S"      //표층수온
            case surDep     = "SUR_DEP"         //표층수심
            case wtrTempM   = "WTR_TEMP_M"      //중층수온
            case midDep     = "MID_DEP"         //중층수심
            case wtrTempB   = "WTR_TEMP_B"      //저층수온
            case botDep     = "BOT_DEP"         //저층수심
            case lon        = "LON"             //경도
            case lat        = "LAT"             //위도
        }
        
        let staCde: String?
        let staNamKor: String?
        let staNam: String?
        let obsDtm: String?
        let wtrTempS: Float
        let surDep: Float
        let wtrTempM: Float
        let midDep: Float
        let wtrTempB: Float
        let botDep: Float
        let lon: Float
        let lat: Float
        
        var dateT: Int {
            let str = self.obsDtm!.filter{ $0.isNumber }
            return Int(str) ?? -1
        }
        
        func toDomain() -> Ocean {
            return .init(staCde: staCde ?? "",
                         staNamKor: staNamKor ?? "",
                         staNam: staNam ?? "",
                         obsDtm: obsDtm ?? "",
                         wtrTempS: wtrTempS,
                         surDep: surDep,
                         wtrTempM: wtrTempM,
                         midDep: midDep,
                         wtrTempB: wtrTempB,
                         botDep: botDep,
                         lon: lon,
                         lat: lat,
                         dateT: dateT)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            staCde = (try? container.decode(String.self, forKey: .staCde)) ?? ""
            staNamKor = (try? container.decode(String.self, forKey: .staNamKor)) ?? ""
            staNam = (try? container.decode(String.self, forKey: .staNam)) ?? ""
            obsDtm = (try? container.decode(String.self, forKey: .obsDtm)) ?? ""
            wtrTempS = (try? container.decode(Float.self, forKey: .wtrTempS)) ?? -99
            surDep = (try? container.decode(Float.self, forKey: .surDep)) ?? -99
            wtrTempM = (try? container.decode(Float.self, forKey: .wtrTempM)) ?? -99
            midDep = (try? container.decode(Float.self, forKey: .midDep)) ?? -99
            wtrTempB = (try? container.decode(Float.self, forKey: .wtrTempB)) ?? -99
            botDep = (try? container.decode(Float.self, forKey: .botDep)) ?? -99
            lon = (try? container.decode(Float.self, forKey: .lon)) ?? -99
            lat = (try? container.decode(Float.self, forKey: .lat)) ?? -99
        }
    }
}

