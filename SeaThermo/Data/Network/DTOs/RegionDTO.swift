//
//  RegionDTO.swift
//  SeaThermo
//

import Foundation

// MARK: - API Response Wrapper
struct RegionResponseDTO: Decodable {
    let resultCode: Int
    let resultMsg: String
    let data: [RegionItemDTO]?
}

// MARK: - Individual Region DTO
struct RegionItemDTO: Decodable {
    let region_group: String
    let region_code: String
    let region_name: String
    let latitude: String
    let longitude: String
    let has_surface: Int
    let has_middle: Int
    let has_bottom: Int
    let surface_depth: String
    let middle_depth: String
    let bottom_depth: String
}

// MARK: - Domain Mapping
extension RegionItemDTO {
    func toDomain() -> Region {
        return Region(
            regionGroup: region_group,
            regionCode: region_code,
            regionName: region_name,
            latitude: latitude,
            longitude: longitude,
            hasSurface: has_surface == 1,
            hasMiddle: has_middle == 1,
            hasBottom: has_bottom == 1,
            surfaceDepth: surface_depth,
            middleDepth: middle_depth,
            bottomDepth: bottom_depth
        )
    }
}
