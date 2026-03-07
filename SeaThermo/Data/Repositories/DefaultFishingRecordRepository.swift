//
//  DefaultFishingRecordRepository.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

final class DefaultFishingRecordRepository: FishingRecordRepository {
    private let realmManager = RealmManager.shared
    
    // MARK: - Save Point
    func savePoint(sessionId: String, latitude: Double, longitude: Double, speed: Double, state: Int, timestamp: Date) {
        let record = RealmFishingRecord(sessionId: sessionId,
                                        date: timestamp,
                                        latitude: latitude,
                                        longitude: longitude,
                                        speed: speed,
                                        state: state)
        realmManager.add(record)
    }
    
    // MARK: - Save Photo
    func savePhoto(sessionId: String, image: Data, timestamp: Date, location: (Double, Double), state: Int) -> String? {
        // 1. 파일 저장
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try image.write(to: fileURL)
            let imagePath = fileName
            
            // 2. DB 저장 (사진 정보가 포함된 Record 생성)
            let record = RealmFishingRecord(sessionId: sessionId,
                                            date: timestamp,
                                            latitude: location.0,
                                            longitude: location.1,
                                            speed: 0,
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
    func fetchRecords(date: Date) async throws -> [FishingRecord] {
        // 해당 날짜의 시작과 끝 계산
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw NSError(domain: "DateError", code: -1, userInfo: nil)
        }
        
        guard let realm = realmManager.realm else {
            throw NSError(domain: "RealmError", code: -1, userInfo: nil)
        }
        
        let results = realm.objects(RealmFishingRecord.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
            .sorted(byKeyPath: "date", ascending: true)
            
        return Array(results.map { $0.toDomain() })
    }
    
    // MARK: - Fetch All Records (History)
    func fetchAllRecords() async throws -> [FishingRecord] {
        guard let realm = realmManager.realm else {
            throw NSError(domain: "RealmError", code: -1, userInfo: nil)
        }
        
        // 모든 기록을 날짜 내림차순으로 정렬 (최신순)
        let results = realm.objects(RealmFishingRecord.self)
            .sorted(byKeyPath: "date", ascending: false)
        
        return Array(results.map { $0.toDomain() })
    }
    
    // MARK: - Delete Session
    func deleteSession(sessionId: String) {
        guard let realm = realmManager.realm else { return }
        
        let objectsToDelete = realm.objects(RealmFishingRecord.self).filter("sessionId == %@", sessionId)
        
        if !objectsToDelete.isEmpty {
            realmManager.delete(objectsToDelete)
        }
    }
    
    // MARK: - Delete Single Record
    func deleteFishingRecord(id: String) {
        guard let realm = realmManager.realm else { return }
        
        if let objectToDelete = realm.object(ofType: RealmFishingRecord.self, forPrimaryKey: id) {
            realmManager.delete(objectToDelete)
        }
    }
    
    func deleteFishingRecords(ids: [String]) {
        guard let realm = realmManager.realm else { return }
        
        let objectsToDelete = realm.objects(RealmFishingRecord.self).filter("id IN %@", ids)
        
        if !objectsToDelete.isEmpty {
            realmManager.delete(objectsToDelete)
        }
    }
}
