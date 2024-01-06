//
//  AppDIContainer.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/11/30.
//

import Foundation

protocol DIContainer {
    func register<T>(_ dependency: T)
    func resolve<T>() -> T
}

final class AppDIContainer: DIContainer {
    static let shared = AppDIContainer()
    
    private var dependencies = [String: Any]()
    
    private init() {}
    
    func register<T>(_ dependency: T) {
        let key = String(describing: type(of: T.self))
        dependencies[key] = dependency
    }
    
    func resolve<T>() -> T {
        let key = String(describing: type(of: T.self))
        let dependency = dependencies[key]
        
        precondition(dependency != nil, "\(key) not registerd")
        
        return dependency as! T
    }
}
