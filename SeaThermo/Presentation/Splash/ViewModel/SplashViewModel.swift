//
//  SplashViewModel.swift
//  SeaThermo
//

import Foundation
import Combine

/// 스플래시 화면 상태
enum SplashState {
    case loading
    case readyToNavigate
    case forceUpdate(message: String)   // 강제 업데이트 (취소 불가)
    case optionalUpdate(message: String) // 선택적 업데이트
}

final class SplashViewModel: ObservableObject {
    @Published var state: SplashState = .loading
    
    private let splashUseCase: SplashUseCase
    private var cancellable: Cancellable?
    
    // 최소 표시 시간 (초)
    private let minimumDisplayDuration: TimeInterval = 1.5
    
    init(splashUseCase: SplashUseCase) {
        self.splashUseCase = splashUseCase
    }
    
    func onAppear() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let startTime = Date()
        
        cancellable = splashUseCase.executeVersionCheck(appVersion: currentVersion) { [weak self] result in
            guard let self else { return }
            
            // 최소 표시 시간 보장
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = max(0, self.minimumDisplayDuration - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
                switch result {
                case .success(let status):
                    if status.forceUpdate {
                        self.state = .forceUpdate(message: status.message)
                    } else if status.needUpdate {
                        self.state = .optionalUpdate(message: status.message)
                    } else {
                        self.state = .readyToNavigate
                    }
                case .failure:
                    // API 실패 시 조용히 메인 화면으로 전환
                    self.state = .readyToNavigate
                }
            }
        }
    }
}
