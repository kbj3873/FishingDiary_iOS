//
//  UserDefaults.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/28/25.
//

import Foundation

extension UserDefaults {

    public func object(key defaultName: String) -> Any? {
        return self.object(forKey: defaultName)
    }

    public func set(_ value: Any?, key defaultName: String) {
        self.set(value, forKey: defaultName)
    }

    public func removeObject(key defaultName: String) {
        self.removeObject(forKey: defaultName)
    }

    public func string(key defaultName: String) -> String? {
        return self.string(forKey: defaultName)
    }

    public func array(key defaultName: String) -> [Any]? {
        return self.array(forKey: defaultName)
    }

    public func dictionary(key defaultName: String) -> [String: Any]? {
        return self.dictionary(forKey: defaultName)
    }

    public func data(key defaultName: String) -> Data? {
        return self.data(forKey: defaultName)
    }

    public func stringArray(key defaultName: String) -> [String]? {
        return self.stringArray(forKey: defaultName)
    }

    public func integer(key defaultName: String) -> Int {
        return self.integer(forKey: defaultName)
    }

    public func float(key defaultName: String) -> Float {
        return self.float(forKey: defaultName)
    }

    public func double(key defaultName: String) -> Double {
        return self.double(forKey: defaultName)
    }

    public func bool(key defaultName: String) -> Bool {
        return self.bool(forKey: defaultName)
    }

    public func value(key defaultName: String) -> Any? {
        return self.value(forKey: defaultName)
    }
}

/// model list -> json -> data 저장
extension UserDefaults {
    public func setToList<T: Codable>(_ values: [T]?, key defaultName: String) {
        if let data = try? JSONEncoder().encode(values) {
            self.set(data, forKey: defaultName)
        } else {
            print("setToList: model to json data encoded failed")
        }
    }
    
    public func getFromList<T: Codable>(key defaultName: String, type: T.Type) -> [T] {
        if let data = self.data(forKey: defaultName) {
            if let items = try? JSONDecoder().decode([T].self, from: data) {
                return items
            } else {
                print("getFromList: model to json data decoded failed")
                return []
            }
        } else {
            print("getFromList: empty data")
            return []
        }
    }
}
