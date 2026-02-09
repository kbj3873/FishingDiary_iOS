import Foundation

/// 낚시 기록 엔티티
public struct FishingRecord: Identifiable, Equatable, Codable {
    public let id: String
    public let sessionId: String // 낚시 1회를 구분하는 세션 ID
    public let date: Date
    public let location: (latitude: Double, longitude: Double)
    public let speed: Double
    public let state: Int // 0: 이동, 1: 탐색, 2: 낚시
    public let imagePaths: [String]
    
    public init(id: String = UUID().uuidString,
                sessionId: String = "",
                date: Date,
                location: (Double, Double),
                speed: Double,
                state: Int = 0,
                imagePaths: [String] = []) {
        self.id = id
        self.sessionId = sessionId
        self.date = date
        self.location = location
        self.speed = speed
        self.state = state
        self.imagePaths = imagePaths
    }
    
    public static func == (lhs: FishingRecord, rhs: FishingRecord) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Codable (Tuple Handling)
    enum CodingKeys: String, CodingKey {
        case id, sessionId, date, latitude, longitude, speed, state, imagePaths
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId) ?? ""
        date = try container.decode(Date.self, forKey: .date)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        location = (lat, lon)
        speed = try container.decode(Double.self, forKey: .speed)
        state = try container.decodeIfPresent(Int.self, forKey: .state) ?? 0
        imagePaths = try container.decode([String].self, forKey: .imagePaths)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(date, forKey: .date)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
        try container.encode(speed, forKey: .speed)
        try container.encode(state, forKey: .state)
        try container.encode(imagePaths, forKey: .imagePaths)
    }
}

