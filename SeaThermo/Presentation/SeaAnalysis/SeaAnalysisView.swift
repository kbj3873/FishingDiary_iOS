//
//  SeaAnalysisView.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct SeaAnalysisView: View {
    // Navigation State
    @State private var selectedSea: Sea?
    @State private var selectedStation: ObservatoryInfo?
    @State private var showDetailView: Bool = false

    // DI
    private let applicationDIContainer: ApplicationDIContainer = AppDIContainer.shared.resolve()

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()

                NavigationLink(
                    destination: detailViewDestination,
                    isActive: $showDetailView
                ) {
                    EmptyView()
                }

                VStack(spacing: 0) {
                    headerSection

                    ScrollView {
                        cardsSection
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedSea) { sea in
            SeaRegionListView(sea: sea) { station in
                self.selectedStation = station
                self.selectedSea = nil
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    await MainActor.run {
                        self.showDetailView = true
                    }
                }
            }
            .presentationDetents([.fraction(0.9)])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var detailViewDestination: some View {
        if let station = selectedStation {
            SeaAnalysisDetailView(viewModel: applicationDIContainer.makeSeaAnalysisDetailViewModel(station: station))
        } else {
            EmptyView()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("수온 분석")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)
                .tracking(-0.355)

            Text("주간 수온 데이터를 확인하세요")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "8E8E93"))
                .tracking(-0.15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 48)
        .padding(.bottom, 12)
        .background(Color.white.ignoresSafeArea(edges: .top))
        .overlay(
            Rectangle()
                .fill(Color(hex: "E5E5EA"))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        VStack(spacing: 8) {
            ForEach(seaRegions, id: \.id) { region in
                SeaRegionCardView(region: region) {
                    self.selectedSea = region.sea
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }

    // MARK: - Sea Regions (allRegionList 기반 동적 생성)

    /// 서버에서 캐싱된 allRegionList를 기반으로 해역별 카드 정보 생성.
    /// stationCount는 실제 관측소 수로 표시됩니다.
    private var seaRegions: [SeaRegionInfo] {
        let allRegions = FDUserDefaults.getFromList(key: UserDefaultKey.allRegionList, type: Region.self)

        let westCount  = allRegions.filter { $0.toSea() == .west  }.count
        let eastCount  = allRegions.filter { $0.toSea() == .east  }.count
        let southCount = allRegions.filter { $0.toSea() == .south }.count // 제주 포함

        return [
            SeaRegionInfo(
                id: Sea.west.id,
                sea: .west,
                title: "서해",
                subtitle: "황해 연안 지역",
                imageName: "sea_west",
                stationCount: westCount
            ),
            SeaRegionInfo(
                id: Sea.east.id,
                sea: .east,
                title: "동해",
                subtitle: "동해안 지역",
                imageName: "sea_east",
                stationCount: eastCount
            ),
            SeaRegionInfo(
                id: Sea.south.id,
                sea: .south,
                title: "남해",
                subtitle: "남해안 지역",
                imageName: "sea_south",
                stationCount: southCount
            )
        ]
    }
}

#Preview {
    SeaAnalysisView()
}
