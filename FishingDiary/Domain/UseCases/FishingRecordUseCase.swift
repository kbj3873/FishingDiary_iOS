import Foundation

public protocol FishingRecordUseCase {
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int, timestamp: Date)
    func savePhoto(sessionId: String, image: Data, location: (Double, Double), state: Int) -> String?
    func fetchRecords(date: Date, completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable?
    func fetchAllRecords(completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable?
    func deleteSession(sessionId: String) -> Cancellable?
    func deleteFishingRecord(id: String) -> Cancellable?
    func deleteFishingRecords(ids: [String]) -> Cancellable?
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
        _ = repository.savePoint(sessionId: sessionId, latitude: latitude, longitude: longitude, speed: speed, state: state, timestamp: timestamp)
    }
    
    public func savePhoto(sessionId: String, image: Data, location: (Double, Double), state: Int) -> String? {
        return repository.savePhoto(sessionId: sessionId, image: image, timestamp: Date(), location: location, state: state)
    }
    
    public func fetchRecords(date: Date, completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable? {
        return repository.fetchRecords(date: date, completion: completion)
    }
    
    public func fetchAllRecords(completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable? {
        return repository.fetchAllRecords(completion: completion)
    }
    
    public func deleteSession(sessionId: String) -> Cancellable? {
        return repository.deleteSession(sessionId: sessionId)
    }
    
    public func deleteFishingRecord(id: String) -> Cancellable? {
        return repository.deleteFishingRecord(id: id)
    }
    
    public func deleteFishingRecords(ids: [String]) -> Cancellable? {
        return repository.deleteFishingRecords(ids: ids)
    }
}


