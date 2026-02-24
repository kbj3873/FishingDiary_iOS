//
//  SplashView.swift
//  SeaThermo
//

import SwiftUI

struct SplashView: View {
    @StateObject var viewModel: SplashViewModel
    
    // 메인 화면 표시 여부를 외부에서 제어
    var onComplete: () -> Void
    
    // App Store 링크 (향후 실제 앱 ID로 교체)
    private let appStoreURL = URL(string: "https://apps.apple.com/app/id0000000000")!
    
    @State private var showForceUpdateAlert = false
    @State private var showOptionalUpdateAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // 배경 이미지 — LaunchScreen과 동일
            Image("launchBackground")
                .resizable()
                .scaledToFill()
            
            // 중앙 아이콘 — LaunchScreen의 superview center 기준과 동일
            Image("launchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
        }
        .ignoresSafeArea()  // 전체 화면(non-safe area) 기준으로 center 정렬
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.state) { newState in
            handleStateChange(newState)
        }
        // 강제 업데이트 Alert (취소 불가)
        .alert("업데이트 필요", isPresented: $showForceUpdateAlert) {
            Button("App Store로 이동") {
                UIApplication.shared.open(appStoreURL)
                // 앱이 포그라운드로 돌아와도 재표시
                showForceUpdateAlert = true
            }
        } message: {
            Text(alertMessage)
        }
        // 선택적 업데이트 Alert
        .alert("업데이트 알림", isPresented: $showOptionalUpdateAlert) {
            Button("업데이트") {
                UIApplication.shared.open(appStoreURL)
            }
            Button("나중에") {
                onComplete()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleStateChange(_ state: SplashState) {
        switch state {
        case .loading:
            break
        case .readyToNavigate:
            onComplete()
        case .forceUpdate(let message):
            alertMessage = message
            showForceUpdateAlert = true
        case .optionalUpdate(let message):
            alertMessage = message
            showOptionalUpdateAlert = true
        }
    }
}

// MARK: - SplashState Equatable
extension SplashState: Equatable {
    static func == (lhs: SplashState, rhs: SplashState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.readyToNavigate, .readyToNavigate):
            return true
        case (.forceUpdate(let a), .forceUpdate(let b)):
            return a == b
        case (.optionalUpdate(let a), .optionalUpdate(let b)):
            return a == b
        default:
            return false
        }
    }
}
