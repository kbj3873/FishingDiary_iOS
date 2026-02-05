//
//  MainTabView.swift
//  FishingDiary
//
//  Created by Claude on 1/29/26.
//

import SwiftUI

enum TabItem: Int, CaseIterable {
    case currentTemperature = 0
    case analysis
    case fishingRecord
    case history
    case settings

    var title: String {
        switch self {
        case .currentTemperature: return "현재수온"
        case .analysis: return "수온분석"
        case .fishingRecord: return "낚시기록"
        case .history: return "히스토리"
        case .settings: return "설정"
        }
    }

    var iconName: String {
        switch self {
        case .currentTemperature: return "tab_temperature"
        case .analysis: return "tab_analysis"
        case .fishingRecord: return "tab_fishing"
        case .history: return "tab_history"
        case .settings: return "tab_settings"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: TabItem = .currentTemperature

    private let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()

    init() {
        configureTabBarAppearance()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // 현재수온
            CurrentTemperatureView(viewModel: pointSceneDIContainer.makeCurrentTemperatureViewModel())
                .tabItem {
                    tabLabel(for: .currentTemperature)
                }
                .tag(TabItem.currentTemperature)

            // 수온분석
            SeaAnalysisView()
                .tabItem {
                    tabLabel(for: .analysis)
                }
                .tag(TabItem.analysis)

            // 낚시기록
            FishingRecordCompositionLayer()
                .tabItem {
                    tabLabel(for: .fishingRecord)
                }
                .tag(TabItem.fishingRecord)

            // 히스토리
            HistoryCompositionLayer()
                .tabItem {
                    tabLabel(for: .history)
                }
                .tag(TabItem.history)

            // 설정
            SettingView(viewModel: pointSceneDIContainer.makeSettingViewModel())
                .tabItem {
                    tabLabel(for: .settings)
                }
                .tag(TabItem.settings)
        }
        .accentColor(Color(hex: "2563EB"))
    }

    @ViewBuilder
    private func tabLabel(for tab: TabItem) -> some View {
        VStack(spacing: 4) {
            Image(tab.iconName)
                .renderingMode(.template)
            Text(tab.title)
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.8)

        // 상단 보더
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)

        // 비활성 탭 색상
        let inactiveColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1) // #8E8E93
        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: inactiveColor,
            .font: UIFont.systemFont(ofSize: 10)
        ]

        // 활성 탭 색상
        let activeColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1) // #2563EB
        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: activeColor,
            .font: UIFont.systemFont(ofSize: 10)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Composition Layers
struct FishingRecordCompositionLayer: View {
    @StateObject private var viewModel: FishingRecordViewModel
    
    init() {
        let repository = DefaultFishingRecordRepository()
        let useCase = DefaultFishingRecordUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: FishingRecordViewModel(useCase: useCase))
    }
    
    var body: some View {
        FishingRecordView(viewModel: viewModel)
    }
}

struct HistoryCompositionLayer: View {
    @StateObject private var viewModel: HistoryViewModel
    
    init() {
        let repository = DefaultFishingRecordRepository()
        let useCase = DefaultFishingRecordUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: HistoryViewModel(useCase: useCase))
    }
    
    var body: some View {
        HistoryView(viewModel: viewModel)
    }
}

// MARK: - Placeholder Views

struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.title)
            Text("구현 예정")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "F2F2F7"))
    }
}


#Preview {
    MainTabView()
}
