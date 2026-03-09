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

@MainActor
final class SplashViewModel: ObservableObject {
    @Published var state: SplashState = .loading
    
    private let splashUseCase: SplashUseCase
    private var versionCheckTask: Task<Void, Never>?
    
    // 최소 표시 시간 (초)
    private let minimumDisplayDuration: TimeInterval = 1.5
    
    init(splashUseCase: SplashUseCase) {
        self.splashUseCase = splashUseCase
    }
    
    func onAppear() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let startTime = Date()
        
        versionCheckTask = Task {
            // 최소 표시 시간 보장 및 병렬 API 호출
            async let versionResult: VersionStatus = splashUseCase.checkVersion(appVersion: currentVersion)
            async let minimumDelay: Void = Task.sleep(nanoseconds: UInt64(minimumDisplayDuration * 1_000_000_000))

            // 관측소 목록은 버전 체크와 독립적으로 저장 (버전 체크 실패 시에도 캐싱)
            do {
                let regions = try await splashUseCase.fetchRegions()
                FDUserDefaults.setToList(regions, key: UserDefaultKey.allRegionList)
                print("[Splash] 관측소 목록 캐싱 완료: \(regions.count)개")
            } catch {
                print("[Splash] 관측소 목록 fetch 실패: \(error)")
            }

            do {
                let status = try await versionResult
                _ = try? await minimumDelay

                if status.forceUpdate {
                    self.state = .forceUpdate(message: status.message)
                } else if status.needUpdate {
                    self.state = .optionalUpdate(message: status.message)
                } else {
                    self.state = .readyToNavigate
                }
            } catch {
                _ = try? await minimumDelay
                // 버전 체크 실패 시 조용히 메인 화면으로 전환
                print("[Splash] 버전 체크 실패: \(error)")
                self.state = .readyToNavigate
            }
        }
    }
}
