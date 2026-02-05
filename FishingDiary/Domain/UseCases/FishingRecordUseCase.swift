import Foundation

public protocol FishingRecordUseCase {
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int)
    func savePhoto(sessionId: String, image: Data, location: (Double, Double), state: Int) -> String?
    func fetchRecords(date: Date, completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable?
    func fetchAllRecords(completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable?
}

public final class DefaultFishingRecordUseCase: FishingRecordUseCase {
    private let repository: FishingRecordRepository
    
    public init(repository: FishingRecordRepository) {
        self.repository = repository
    }
    
    public func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int) {
        _ = repository.savePoint(sessionId: sessionId, latitude: latitude, longitude: longitude, speed: speed, state: state, timestamp: Date())
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
}


