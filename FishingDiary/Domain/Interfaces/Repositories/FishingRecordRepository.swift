import Foundation

public protocol FishingRecordRepository {
    /// 위치 정보 및 속도를 저장합니다.
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int, timestamp: Date) -> Cancellable?
    
    /// 사진을 저장하고 저장된 경로를 반환합니다.
    func savePhoto(sessionId: String, image: Data, timestamp: Date, location: (Double, Double), state: Int) -> String?
    
    /// 특정 날짜의 낚시 기록을 불러옵니다.
    func fetchRecords(date: Date, completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable?
    
    /// 모든 낚시 기록을 불러옵니다 (히스토리용).
    func fetchAllRecords(completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable?
}


