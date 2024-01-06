//
//  String.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/19.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    static func DtoDM(with value: Double) -> String {
        let d = trunc(value)  // > 소수점 버림
        let tmp = value - Double(d)
        
        // > 소수점 4번째에서 반올림
        let digit: Double = pow(10, 3)
        let m = round((tmp * 60) * digit) / digit
        
        return "\(Int(d))° \(m)\'"
    }
    
    static func DtoDMS(with value: Double) -> String {
        let d = trunc(value) // > 소수점 버림
        var tmp: Double = value - Double(d)
        let m: Double = trunc(tmp * 60)
        
        tmp = (tmp * 60) - m
        // > 소수점 3번째에서 반올림
        let digit: Double = pow(10, 2)
        
        let s = round((tmp * 60) * digit) / digit
        return "\(Int(d))° \(Int(m))\' \(s)\""
    }
    
    static func DMStoD(with value: String) -> Double {
        var result: Double = 0.0
        var tempValue = value.trim()
        tempValue = tempValue.replacingOccurrences(of: "\"N", with: "")
        tempValue = tempValue.replacingOccurrences(of: "\"E", with: "")
        
        var d: Double = 0.0
        var m: Double = 0.0
        var s: Double = 0.0
        
        let firstComp = tempValue.components(separatedBy: "° ")
        
        if firstComp.count > 1 {
            if let deg = Double(firstComp[0]) {
                d = deg
            }
            
            let secondComp = firstComp[1].components(separatedBy: "\'")
            if let min = Double(secondComp[0]), let sec = secondComp[1].toDouble() {
                m = min
                s = sec
            }
        }
        
        result = d + (m / 60.0) + (s / 3600.0)
        
        // > 소수점 7번째에서 반올림
        let digit: Double = pow(10, 6)
        
        return round(result * digit) / digit
    }
    
    static func DMStoDM(with value: String) -> String {
        var result: String
        var tempValue = value.trim()
        tempValue = tempValue.replacingOccurrences(of: "\"N", with: "")
        tempValue = tempValue.replacingOccurrences(of: "\"E", with: "")
        
        var d: Double = 0.0
        var m: Double = 0.0
        var s: Double = 0.0
        
        let firstComp = tempValue.components(separatedBy: "° ")
        
        if firstComp.count > 1 {
            if let deg = Double(firstComp[0]) {
                d = deg
            }
            
            let secondComp = firstComp[1].components(separatedBy: "\'")
            if let min = Double(secondComp[0]), let sec = secondComp[1].toDouble() {
                m = min
                s = sec
            }
        }
        // > 초->분으로 변환하여 분값과 합산
        let addedM = m + (s / 60.0)
        result = "\(d)° \(addedM)\'"
        
        return result
    }
}
