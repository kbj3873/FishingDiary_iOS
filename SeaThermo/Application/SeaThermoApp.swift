//
//  SeaThermoApp.swift
//  SeaThermo
//
//  Created by Kim Byeong Joon on 3/5/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        MetricKitManager.shared.subscribe()

        // 이전 세션 비정상 종료 감지 로그
        if MetricKitManager.shared.didPreviousSessionTerminateAbnormally {
            let date = MetricKitManager.shared.lastAbnormalTerminationDate.map { "\($0)" } ?? "알 수 없음"
            print("⚠️ [MetricKit] 이전 세션 비정상 종료 감지 - 날짜: \(date)")
        }

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        MetricKitManager.shared.markSessionEnd()
    }
}

enum AppStep {
    case splash
    case onboarding
    case main
}

@main
struct SeaThermoApp: App {
    // MARK: - App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // MARK: - Global Dependencies
    private let applicationDIContainer: ApplicationDIContainer
    
    // MARK: - App State
    @State private var currentStep: AppStep = .splash
    
    init() {
        // DI Container 셋업
        self.applicationDIContainer = ApplicationDIContainer()
        AppDIContainer.shared.register(applicationDIContainer)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch currentStep {
                case .splash:
                    SplashView(viewModel: applicationDIContainer.makeSplashViewModel()) {
                        // 스플래시 종료 후 온보딩 유무 분기
                        let hasCompletedOnboarding = FDUserDefaults.bool(forKey: UserDefaultKey.hasCompletedOnboarding)
                        withAnimation {
                            if hasCompletedOnboarding {
                                currentStep = .main
                            } else {
                                currentStep = .onboarding
                            }
                        }
                    }
                    
                case .onboarding:
                    OnboardingView(viewModel: OnboardingViewModel()) {
                        withAnimation {
                            currentStep = .main
                        }
                    }
                    
                case .main:
                    MainTabView()
                        .environmentObject(applicationDIContainer) // 하위 뷰에 EnvironmentObject 형태로 주입 가능
                }
            }
            .onAppear {
                // 추가 초기화가 필요한 경우 여기서 수행
            }
        }
    }
}


