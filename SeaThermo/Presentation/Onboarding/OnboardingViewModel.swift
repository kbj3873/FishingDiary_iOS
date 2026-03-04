//
//  OnboardingViewModel.swift
//  SeaThermo
//

import Foundation

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let totalPages = 4
    
    /// 다음 페이지로 이동하거나, 마지막 페이지면 온보딩 완료 처리
    func nextPage(onComplete: () -> Void) {
        if currentPage < totalPages - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
            onComplete()
        }
    }
    
    /// 온보딩 완료 플래그를 UserDefaults에 저장
    private func completeOnboarding() {
        FDUserDefaults.set(true, forKey: UserDefaultKey.hasCompletedOnboarding)
    }
}
