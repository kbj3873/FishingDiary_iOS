//
//  OnboardingView.swift
//  SeaThermo
//

import SwiftUI

// MARK: - 온보딩 페이지 데이터 모델
struct OnboardingPage {
    let iconName: String        // SF Symbol 이름
    let title: String
    let description: String
    let previewContent: AnyView // 각 페이지별 미리보기 카드
}

// MARK: - 메인 온보딩 View
struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    var onComplete: () -> Void
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "ic_onboarding_thermometer",
            title: "실시간 수온 확인",
            description: "즐겨찾기한 지역의 표층, 중층, 저층\n수온을 실시간으로 확인하세요",
            previewContent: AnyView(ImageCard(imageName: "ic_onboarding_guide1"))
        ),
        OnboardingPage(
            iconName: "ic_onboarding_trending",
            title: "수온 변화 분석",
            description: "서해, 동해, 남해 지역별로 최근 일주일\n간의 수온 변화를 분석하세요",
            previewContent: AnyView(ImageCard(imageName: "ic_onboarding_guide2"))
        ),
        OnboardingPage(
            iconName: "ic_onboarding_mappin",
            title: "GPS 낚시 기록",
            description: "이동 경로와 속도를 자동으로 추적하\n고 조과물 사진과 함께 기록하세요",
            previewContent: AnyView(ImageCard(imageName: "ic_onboarding_guide3"))
        ),
        OnboardingPage(
            iconName: "ic_onboarding_history",
            title: "낚시 히스토리",
            description: "과거 기록을 확인하고 최고의 낚시 포\n인트를 다시 찾아보세요",
            previewContent: AnyView(ImageCard(imageName: "ic_onboarding_guide4"))
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "f2f2f7")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 페이지 콘텐츠
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                
                // 하단 영역: 인디케이터 + 버튼
                bottomSection
            }
        }
    }
    
    // MARK: - 하단 섹션
    private var bottomSection: some View {
        VStack(spacing: 24) {
            // 페이지 인디케이터
            pageIndicator
            
            // 다음/시작하기 버튼
            actionButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    // MARK: - 커스텀 페이지 인디케이터
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentPage
                          ? Color(hex: "2563eb")
                          : Color(hex: "c7c7cc"))
                    .frame(
                        width: index == viewModel.currentPage ? 24 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
            }
        }
    }
    
    // MARK: - 액션 버튼
    private var actionButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.nextPage(onComplete: onComplete)
            }
        } label: {
            Text(viewModel.currentPage == pages.count - 1 ? "시작하기" : "다음")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 57)
                .background(Color(hex: "2563eb"))
                .cornerRadius(16)
                .shadow(color: Color(hex: "2563eb").opacity(0.3), radius: 10, x: 0, y: 4)
        }
    }
}

// MARK: - 개별 온보딩 페이지
private struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 콘텐츠 블록 (간격 고정)
            VStack(spacing: 0) {
                Spacer()
                
                // 아이콘 원형 배경
                ZStack {
                    Circle()
                        .fill(Color(hex: "2563eb"))
                        .frame(width: 128, height: 128)
                    
                    Image(page.iconName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                }
                
                // 미리보기 카드 (이미지 비율에 따라 높이 자동 적용)
                page.previewContent
                
                // 타이틀
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
                    .tracking(0.38)
                    .multilineTextAlignment(.center)
                    .frame(height: 42)
                
                // 설명
                Text(page.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "8e8e93"))
                    .tracking(-0.23)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .frame(width: 249, height: 48)
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

// MARK: - 이미지 카드 (가이드 1, 2, 3, 4 공통)
private struct ImageCard: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
}
