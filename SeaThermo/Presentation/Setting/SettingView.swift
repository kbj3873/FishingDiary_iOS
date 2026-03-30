//
//  SettingView.swift
//  SeaThermo
//
//  Created for Figma Feature Implementation
//

import SwiftUI

struct SettingView: View {
    @StateObject var viewModel: SettingViewModel
    @EnvironmentObject private var applicationDIContainer: ApplicationDIContainer
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Background
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // Notice Section
                            notificationSection
                            
                            // Map Setting Section
                            mapSettingSection
                            
                            // Info Section
                            infoSection
                            
                            // Copyright
                            copyrightSection

                            Spacer()
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay {
                if viewModel.showRecordingBlockedPopup {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        CommonPopupView(
                            title: "지도 변경 불가",
                            message: "낚시 기록 중에는 지도 타입을 변경할 수 없습니다.\n기록을 종료한 후 변경해 주세요.",
                            layoutType: .horizontal,
                            primaryButtonText: "확인",
                            primaryAction: {
                                viewModel.dismissRecordingBlockedPopup()
                            }
                        )
                    }
                }
            }
            .navigationDestination(for: WebPage.self) { page in
                let urlString = applicationDIContainer.appConfiguration.apiOnbadaURL + page.path
                if let url = URL(string: urlString) {
                    SeaThermoWebView(url: url)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("설정")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
            
            Text("앱 설정 및 정보")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8E8E93"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 48) // Safe Area 고려
        .padding(.bottom, 10)
        .padding(.bottom, 10)
        .background(Color.white) // 헤더 배경 흰색
    }
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("공지")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "6D6D72"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                commonRow(
                    icon: "bell",
                    title: "공지사항",
                    isLast: true
                ) {
                    path.append(WebPage.notices)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }

    private var mapSettingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("지도")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "6D6D72"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                // Apple Map Row
                mapSelectionRow(
                    icon: "map",
                    title: "애플 지도",
                    type: .AppleMap,
                    isSelected: viewModel.selectedMapType == .AppleMap,
                    isLast: false
                )
                
                // Kakao Map Row
                mapSelectionRow(
                    icon: "map", // Using generic map icon for both as per screenshot style
                    title: "카카오맵",
                    type: .KakaoMap,
                    isSelected: viewModel.selectedMapType == .KakaoMap,
                    isLast: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("정보")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "6D6D72"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                commonRow(
                    icon: "info.circle",
                    title: "앱 정보",
                    detail: "버전 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")",
                    isLast: false
                ) { }
                
                commonRow(
                    icon: "doc.text",
                    title: "오픈소스 라이선스",
                    isLast: true
                ) {
                    path.append(WebPage.licenses)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
    
    private var copyrightSection: some View {
        VStack(spacing: 4) {
            Text("© 2026 바다의 온도 시스템")
            Text("All rights reserved")
        }
        .font(.system(size: 12, weight: .regular))
        .foregroundColor(Color(hex: "8E8E93"))
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
    
    private func mapSelectionRow(icon: String, title: String, type: MapType, isSelected: Bool, isLast: Bool) -> some View {
        Button {
            withAnimation {
                viewModel.updateMapType(type)
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "2563EB"))
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .contentShape(Rectangle()) // 터치 영역 확장
                
                if !isLast {
                    Rectangle()
                        .fill(Color.black.opacity(0.08)) // Figma 일치: rgba(0,0,0,0.08)
                        .frame(height: 0.5)
                        .padding(.leading, 52)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func commonRow(icon: String, title: String, detail: String? = nil, isLast: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if let detail = detail {
                        Text(detail)
                            .font(.system(size: 17))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .padding(.trailing, 4)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.2)) // Chevron Color Adjusted slightly or keep C6C6C8? Sticking to C6C6C8 for chevron as per request only regarding separator, but let's check. Actually user only asked about separator line. Keep chevron as C6C6C8 or similar.
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .contentShape(Rectangle()) // 터치 영역 확장
                
                if !isLast {
                    Rectangle()
                        .fill(Color.black.opacity(0.08)) // Figma 일치: rgba(0,0,0,0.08)
                        .frame(height: 0.5)
                        .padding(.leading, 52)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
