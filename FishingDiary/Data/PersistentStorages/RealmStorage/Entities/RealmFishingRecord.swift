import Foundation
import RealmSwift

final class RealmFishingRecord: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var sessionId: String // 낚시 1회를 구분하는 세션 ID
    @Persisted var date: Date
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var speed: Double
    @Persisted var imagePaths = List<String>() // 사진 경로 리스트
    
    convenience init(id: String = UUID().uuidString,
                     sessionId: String = "",
                     date: Date,
                     latitude: Double,
                     longitude: Double,
                     speed: Double,
                     imagePaths: [String] = []) {
        self.init()
        self.id = id
        self.sessionId = sessionId
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.speed = speed
        
        let pathList = List<String>()
        pathList.append(objectsIn: imagePaths)
        self.imagePaths = pathList
    }
    
    /// Domain Entity로 변환
    func toDomain() -> FishingRecord {
        return FishingRecord(id: id,
                             sessionId: sessionId,
                             date: date,
                             location: (latitude, longitude),
                             speed: speed,
                             imagePaths: Array(imagePaths))
    }
}

