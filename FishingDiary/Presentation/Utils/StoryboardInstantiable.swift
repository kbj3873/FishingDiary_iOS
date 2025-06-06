//
//  StoryboardInstantiable.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/05.
//

import Foundation
import UIKit

enum StoryboardType {
    case main
    case point
    case seaWaterTempurature
    
    var name: String {
        switch self {
        case .main:
            return "Main"
        case .point:
            return "Point"
        case .seaWaterTempurature:
            return "SeaWaterTemperature"
        }
    }
}

protocol StoryboardInstantiable: NSObjectProtocol {
    associatedtype T
    static var defaultFileName: String { get }
    static func instantiateViewController(boardName: StoryboardType, _ bundle: Bundle?) -> T
}

extension StoryboardInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static func instantiateViewController(boardName: StoryboardType, _ bundle: Bundle? = nil) -> Self {
        let fileName = boardName.name
        print("defaultFileName : \(defaultFileName)")
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: defaultFileName) as? Self else {
            
            fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(fileName)")
        }
        return vc
    }
}
