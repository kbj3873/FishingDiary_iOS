//
//  SeaAnalysisView.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct SeaAnalysisView: View {
    // ViewModel usage for region list (Local State for static UI)
    @State private var seaRegions: [SeaRegionInfo] = [
        SeaRegionInfo(
            id: Sea.west.id,
            sea: .west,
            title: "서해",
            subtitle: "황해 연안 지역",
            imageName: "sea_west",
            stationCount: WestObserv.allCases.count - 1
        ),
        SeaRegionInfo(
            id: Sea.east.id,
            sea: .east,
            title: "동해",
            subtitle: "동해안 지역",
            imageName: "sea_east",
            stationCount: EastObserv.allCases.count - 1
        ),
        SeaRegionInfo(
            id: Sea.south.id,
            sea: .south,
            title: "남해",
            subtitle: "남해안 지역",
            imageName: "sea_south",
            stationCount: SouthObserv.allCases.count - 1
        )
    ]
    
    // Navigation State
    @State private var selectedSea: Sea? // Used for Sheet Item
    @State private var selectedStation: ObservatoryInfo? // Used for Detail Navigation
    @State private var showDetailView: Bool = false
    
    // DI
    private let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()

    var body: some View {
        NavigationView {
             ZStack {
                // Background (safe area까지 확장)
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                // Hidden Navigation Link for Detail View
                NavigationLink(
                    destination: detailViewDestination,
                    isActive: $showDetailView
                ) {
                    EmptyView()
                }

                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        headerSection

                        // Sea Region Cards
                        cardsSection
                    }
                }
                .clipped()
                .scrollIndicators(.hidden)
            }
            .navigationBarHidden(true)
        }
        // Fix: Use sheet(item:) for safe unpacking of optional state
        .sheet(item: $selectedSea) { sea in
            SeaRegionListView(sea: sea) { station in
                // Callback when a station is selected
                self.selectedStation = station
                
                // Close sheet logic is handled by sheet binding (selectedSea = nil),
                // but usually sheet is dismissed by setting item to nil.
                // Here we set selectedSea to nil to dismiss.
                self.selectedSea = nil
                
                // Trigger detail view navigation after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showDetailView = true
                }
            }
            .presentationDetents([.fraction(0.9)])
            .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private var detailViewDestination: some View {
        if let station = selectedStation {
            // Fix: Inject station info to ViewModel
            SeaAnalysisDetailView(viewModel: pointSceneDIContainer.makeSeaAnalysisDetailViewModel(station: station))
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
        .padding(.bottom, 16)
        .background(Color.white)
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        VStack(spacing: 8) {
            ForEach(seaRegions, id: \.id) { region in
                SeaRegionCardView(region: region) {
                    // Tap Action
                    print("Selected: \(region.title)")
                    self.selectedSea = region.sea
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
}

#Preview {
    SeaAnalysisView()
}
