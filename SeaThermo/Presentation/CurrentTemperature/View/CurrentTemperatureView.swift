//
//  CurrentTemperatureView.swift
//  SeaThermo
//
//  Created by Claude on 1/29/26.
//

import SwiftUI

struct CurrentTemperatureView: View {
    @StateObject var viewModel: CurrentTemperatureViewModel

    var body: some View {
        ZStack {
            // Background
            Color(hex: "F2F2F7")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Content
                contentSection
            }
            
            // 오류 팝업 오버레이 (ZStack 내부 최상단에 배치)
            if viewModel.showErrorAlert {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.showErrorAlert = false
                        }
                    
                    CommonPopupView(
                        title: "네트워크 오류",
                        message: viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.",
                        layoutType: .horizontal,
                        primaryButtonText: "확인",
                        primaryAction: {
                            viewModel.showErrorAlert = false
                        }
                    )
                }
                .zIndex(100)
            }
        }
        .onAppear {
            viewModel.fetchStationList()
        }
        .sheet(isPresented: $viewModel.isOceanSelectPresented) {
            viewModel.createOceanSelectView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("바다 현재수온")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)

            Text("즐겨찾기한 지역의 실시간 수온 정보")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8E8E93"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 48)
        .padding(.bottom, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(hex: "E5E5EA"))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Content Section

    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Add Region Button
                addRegionButton

                // Station Cards
                if viewModel.oceanStations.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    stationCardList
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            viewModel.fetchStationList()
        }
    }

    // MARK: - Add Region Button

    private var addRegionButton: some View {
        Button {
            viewModel.isOceanSelectPresented = true
        } label: {
            HStack(spacing: 8) {
                Image("ic_plus")
                    .renderingMode(.template)
                    .foregroundColor(Color(hex: "2563EB"))

                Text("지역 추가/관리")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "2563EB"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 0)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            
            // 피그마 디자인 기반 PNG 에셋 적용
            Image("ic_star_empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundColor(Color(hex: "E5E5EA"))
                .padding(.bottom, 8)
            
            Text("즐겨찾기한 지역이 없습니다")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "8E8E93"))
            
            Text("위 버튼을 눌러 지역을 추가해보세요")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "AEAEB2"))
            
            Spacer().frame(height: 60)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 0)
    }

    // MARK: - Station Card List

    private var stationCardList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.oceanStations, id: \.stationCode) { station in
                OceanRegionCardView(station: station)
            }
        }
    }
}
