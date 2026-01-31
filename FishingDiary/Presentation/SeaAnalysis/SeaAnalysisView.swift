//
//  SeaAnalysisView.swift
//  FishingDiary
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct SeaAnalysisView: View {
    @StateObject private var viewModel = SeaAnalysisViewModel()
    @State private var selectedSea: Sea?

    var body: some View {
        ZStack {
            // Background (safe area까지 확장)
            Color(hex: "F2F2F7")
                .ignoresSafeArea()

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
        .sheet(item: $selectedSea) { sea in
            SeaRegionListView(sea: sea)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
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
            ForEach(viewModel.seaRegions) { region in
                SeaRegionCardView(region: region) {
                    selectedSea = region.sea
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
