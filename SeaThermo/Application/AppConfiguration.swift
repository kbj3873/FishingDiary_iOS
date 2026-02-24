//
//  AppConfiguration.swift
//  SeaThermo
//
//  Created by Y0000591 on 2024/03/08.
//

import Foundation

final class AppConfiguration {
    lazy var apiKeyRisa: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKeyRisa") as? String else {
            fatalError("ApiKey must not be empty In plist")
        }
        return apiKey
    }()
    
    lazy var apiKeyCoo: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKeyCoo") as? String else {
            fatalError("ApiKey must not be empty In plist")
        }
        return apiKey
    }()
    
    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            fatalError("ApiBaseURL must not be empty in plist")
        }
        return apiBaseURL
    }()
    
    // 온바다 자체 서버 Base URL
    let seaThermoBaseURL: String = "http://3.35.210.133:3000"
}

