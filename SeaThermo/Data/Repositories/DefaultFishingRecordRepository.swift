import Foundation

final class DefaultFishingRecordRepository: FishingRecordRepository {
    private let realmManager = RealmManager.shared
    
    // MARK: - Save Point
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int, timestamp: Date) -> Cancellable? {
        let record = RealmFishingRecord(sessionId: sessionId,
                                        date: timestamp,
                                        latitude: latitude,
                                        longitude: longitude,
                                        speed: speed,
                                        state: state)
        realmManager.add(record)
        return nil // Realm 작업은 동기적으로 처리되므로 Cancellable 불필요하지만 프로토콜 준수를 위해 nil 반환
    }
    
    // MARK: - Save Photo
    func savePhoto(sessionId: String, image: Data, timestamp: Date, location: (Double, Double), state: Int) -> String? {
        // 1. 파일 저장
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try image.write(to: fileURL)
            let imagePath = fileName // 파일명만 저장하거나 전체 경로 저장. 여기선 파일명만 저장하고 불러올 때 경로 조합 권장.
            
            // 2. DB 저장 (사진 정보가 포함된 Record 생성)
            let record = RealmFishingRecord(sessionId: sessionId,
                                            date: timestamp,
                                            latitude: location.0,
                                            longitude: location.1,
                                            speed: 0, // 사진 촬영 시 속도는 0 또는 현재 속도를 받아야 하지만, 여기선 0으로 처리하거나 인자 추가 고려
                                            state: state,
                                            imagePaths: [imagePath])
            
            realmManager.add(record)
            
            return imagePath
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Records
    func fetchRecords(date: Date, completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable? {
        // 해당 날짜의 시작과 끝 계산
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.failure(NSError(domain: "DateError", code: -1, userInfo: nil)))
            return nil
        }
        
        guard let realm = realmManager.realm else {
            completion(.failure(NSError(domain: "RealmError", code: -1, userInfo: nil)))
            return nil
        }
        
        // Realm 객체는 Thread-safe하지 않으므로, 메인 스레드나 호출 스레드에서 바로 변환하여 내보내는 것이 안전
        // 지금은 간단히 동기적으로 처리
        let results = realm.objects(RealmFishingRecord.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
            .sorted(byKeyPath: "date", ascending: true)
            
        let records = results.map { $0.toDomain() }
        completion(.success(Array(records)))
        
        return nil
    }
    
    // MARK: - Fetch All Records (History)
    func fetchAllRecords(completion: @escaping (Result<[FishingRecord], Error>) -> Void) -> Cancellable? {
        guard let realm = realmManager.realm else {
            completion(.failure(NSError(domain: "RealmError", code: -1, userInfo: nil)))
            return nil
        }
        
        // 모든 기록을 날짜 내림차순으로 정렬 (최신순)
        let results = realm.objects(RealmFishingRecord.self)
            .sorted(byKeyPath: "date", ascending: false)
        
        let records = results.map { $0.toDomain() }
        completion(.success(Array(records)))
        
        return nil
    }
    
    // MARK: - Delete Session
    func deleteSession(sessionId: String) -> Cancellable? {
        guard let realm = realmManager.realm else { return nil }
        
        let objectsToDelete = realm.objects(RealmFishingRecord.self).filter("sessionId == %@", sessionId)
        
        if !objectsToDelete.isEmpty {
            // 이미지 파일 삭제 (선택 사항: 필요 시 구현)
            // Realm 객체 삭제
            realmManager.delete(objectsToDelete)
        }
        
        return nil
    }
    
    // MARK: - Delete Single Record
    func deleteFishingRecord(id: String) -> Cancellable? {
        guard let realm = realmManager.realm else { return nil }
        
        if let objectToDelete = realm.object(ofType: RealmFishingRecord.self, forPrimaryKey: id) {
            // 이미지 파일 삭제 로직은 여기에 추가 가능 (FileManager 사용)
            // Realm 객체 삭제
            realmManager.delete(objectToDelete)
        }
        
        return nil
    }
    
    func deleteFishingRecords(ids: [String]) -> Cancellable? {
        guard let realm = realmManager.realm else { return nil }
        
        let objectsToDelete = realm.objects(RealmFishingRecord.self).filter("id IN %@", ids)
        
        if !objectsToDelete.isEmpty {
            realmManager.delete(objectsToDelete)
        }
        
        return nil
    }
}
