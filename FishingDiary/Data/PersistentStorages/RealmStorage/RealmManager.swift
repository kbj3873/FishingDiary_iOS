import Foundation
import RealmSwift

final class RealmManager {
    static let shared = RealmManager()
    
    private let databaseVersion: UInt64 = 2  // sessionId 필드 추가로 인한 버전 업
    
    private init() {}
    
    /// Realm 인스턴스 반환
    var realm: Realm? {
        do {
            let config = Realm.Configuration(
                schemaVersion: databaseVersion,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 2 {
                        // sessionId 필드 추가 마이그레이션
                        // 새 필드는 기본값("")으로 자동 설정됨
                        migration.enumerateObjects(ofType: RealmFishingRecord.className()) { oldObject, newObject in
                            newObject?["sessionId"] = ""
                        }
                    }
                }
            )
            return try Realm(configuration: config)
        } catch {
            print("Realm initialization error: \(error)")
            return nil
        }
    }
    
    /// 데이터 추가
    func add<T: Object>(_ object: T) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Realm write error: \(error)")
        }
    }
    
    /// 데이터 삭제
    func delete<T: Object>(_ object: T) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Realm delete error: \(error)")
        }
    }
    
    /// 데이터 조회
    func fetch<T: Object>(_ type: T.Type) -> Results<T>? {
        return realm?.objects(type)
    }
}
