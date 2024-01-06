//
//  Date.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/08.
//

extension Date {
    static func todayString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func todayStringForSave(format: String = "yyyyMMdd-HHmmss") -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func todayStringForPath(format: String = "yyyyMMdd") -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
