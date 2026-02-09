//
//  SettingViewModel.swift
//  SeaThermo
//
//  Created for Figma Feature Implementation
//

import Foundation
import Combine

final class SettingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedMapType: MapType
    
    // MARK: - Properties
    
    private var appManager: FDAppManager
    
    // MARK: - Init
    
    init(appManager: FDAppManager = .shared) {
        self.appManager = appManager
        self.selectedMapType = appManager.mapTp
    }
    
    // MARK: - Methods
    
    /// 지도 타입을 변경하고 AppManager 및 UserDefaults에 저장합니다.
    func updateMapType(_ type: MapType) {
        // 이미 같은 타입이면 무시
        guard type != selectedMapType else { return }
        
        self.selectedMapType = type
        self.appManager.mapTp = type
        
        print("Map Type Updated to: \(type)")
    }
}
