import Foundation

public protocol FishingRecordRepository {
    /// 위치 정보 및 속도를 저장합니다.
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int, timestamp: Date)
    
    /// 사진을 저장하고 저장된 경로를 반환합니다.
    func savePhoto(sessionId: String, image: Data, timestamp: Date, location: (Double, Double), state: Int) -> String?
    
    /// 특정 날짜의 낚시 기록을 불러옵니다.
    func fetchRecords(date: Date) async throws -> [FishingRecord]
    
    /// 모든 낚시 기록을 불러옵니다 (히스토리용).
    func fetchAllRecords() async throws -> [FishingRecord]
    
    /// 특정 세션의 기록을 삭제합니다.
    func deleteSession(sessionId: String)
    func deleteFishingRecords(ids: [String])
    
    /// 특정 낚시 기록(ID)을 삭제합니다. (사진 마커 삭제용)
    func deleteFishingRecord(id: String)
}
