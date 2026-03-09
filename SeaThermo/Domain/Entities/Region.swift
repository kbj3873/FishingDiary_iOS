//
//  Region.swift
//  SeaThermo
//

import Foundation

// MARK: - Sea Enum (SeaInfo.swift 대체)

/// 해역 구분. NIFS API gruNam 코드(.id)를 제공합니다.
/// 제주는 남해(S)로 간주합니다.
enum Sea: String, CaseIterable, Identifiable {
    case none  = "선택"
    case west  = "서해"
    case east  = "동해"
    case south = "남해"

    var id: String {
        switch self {
        case .none:  return ""
        case .west:  return "W"
        case .east:  return "E"
        case .south: return "S"
        }
    }
}

// MARK: - Region Entity

/// 공통 지역 데이터 엔티티 (해역 그룹, 지역 코드, 위/경도, 수심 등 속성 포함)
public struct Region: Equatable, Codable {
    public let regionGroup: String
    public let regionCode: String
    public let regionName: String
    public let latitude: String
    public let longitude: String
    public let hasSurface: Bool
    public let hasMiddle: Bool
    public let hasBottom: Bool
    public let surfaceDepth: String
    public let middleDepth: String
    public let bottomDepth: String

    public init(regionGroup: String, regionCode: String, regionName: String,
                latitude: String, longitude: String,
                hasSurface: Bool, hasMiddle: Bool, hasBottom: Bool,
                surfaceDepth: String, middleDepth: String, bottomDepth: String) {
        self.regionGroup = regionGroup
        self.regionCode = regionCode
        self.regionName = regionName
        self.latitude = latitude
        self.longitude = longitude
        self.hasSurface = hasSurface
        self.hasMiddle = hasMiddle
        self.hasBottom = hasBottom
        self.surfaceDepth = surfaceDepth
        self.middleDepth = middleDepth
        self.bottomDepth = bottomDepth
    }

    /// regionGroup(한글) → Sea enum 변환. "제주"는 남해(.south)로 간주.
    func toSea() -> Sea {
        switch regionGroup {
        case "서해":        return .west
        case "동해":        return .east
        case "남해", "제주": return .south
        default:            return .none
        }
    }
}
