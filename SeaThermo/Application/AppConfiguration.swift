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
    
    lazy var apiNifsURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiNifsURL") as? String else {
            fatalError("ApiNifsURL must not be empty in plist")
        }
        return apiBaseURL
    }()
    
    lazy var apiOnbadaURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiOnbadaURL") as? String else {
            fatalError("ApiOnbadaURL must not be empty in plist")
        }
        return apiBaseURL
    }()
}

