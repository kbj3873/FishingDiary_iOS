import Foundation

public protocol FishingRecordUseCase {
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int, timestamp: Date)
    func savePhoto(sessionId: String, image: Data, location: (Double, Double), state: Int) -> String?
    func fetchRecords(date: Date) async throws -> [FishingRecord]
    func fetchAllRecords() async throws -> [FishingRecord]
    func deleteSession(sessionId: String)
    func deleteFishingRecord(id: String)
    func deleteFishingRecords(ids: [String])
}

// MARK: - Default Implementation for Optional Parameters
public extension FishingRecordUseCase {
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int) {
        savePoint(sessionId: sessionId, latitude: latitude, longitude: longitude, speed: speed, state: state, timestamp: Date())
    }
}

public final class DefaultFishingRecordUseCase: FishingRecordUseCase {
    private let repository: FishingRecordRepository
    
    public init(repository: FishingRecordRepository) {
        self.repository = repository
    }
    
    public func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int, timestamp: Date = Date()) {
        repository.savePoint(sessionId: sessionId, latitude: latitude, longitude: longitude, speed: speed, state: state, timestamp: timestamp)
    }
    
    public func savePhoto(sessionId: String, image: Data, location: (Double, Double), state: Int) -> String? {
        return repository.savePhoto(sessionId: sessionId, image: image, timestamp: Date(), location: location, state: state)
    }
    
    public func fetchRecords(date: Date) async throws -> [FishingRecord] {
        try await repository.fetchRecords(date: date)
    }
    
    public func fetchAllRecords() async throws -> [FishingRecord] {
        try await repository.fetchAllRecords()
    }
    
    public func deleteSession(sessionId: String) {
        repository.deleteSession(sessionId: sessionId)
    }
    
    public func deleteFishingRecord(id: String) {
        repository.deleteFishingRecord(id: id)
    }
    
    public func deleteFishingRecords(ids: [String]) {
        repository.deleteFishingRecords(ids: ids)
    }
}
