//
//  CurrentTemperatureView.swift
//  FishingDiary
//
//  Created by Claude on 1/29/26.
//

import SwiftUI

struct CurrentTemperatureView: View {
    @StateObject var viewModel: CurrentTemperatureViewModel

    var body: some View {
        NavigationView {
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
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.fetchStationList()
        }
        .sheet(isPresented: $viewModel.isOceanSelectPresented) {
            viewModel.createOceanSelectView()
                .presentationDetents([.fraction(0.8)])
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
        }
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

#Preview {
    CurrentTemperatureView(
        viewModel: CurrentTemperatureViewModel(
            appConfiguration: AppConfiguration(),
            oceanUseCase: OceanUseCase(oceanRepository: PreviewOceanRepository())
        )
    )
}

// MARK: - Preview Helper

private class PreviewOceanRepository: OceanRepository {
    func fetchRisaList(query: RisaListQuery, completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable? {
        return nil
    }

    func fetchStationCode(query: RisaCodeQuery, completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable? {
        return nil
    }

    func fetchRisaCoo(query: RisaCooQuery, completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable? {
        return nil
    }

    func fetchTemperature(query: OceanQuery, completion: @escaping (Result<OceanResponse, Error>) -> Void) -> Cancellable? {
        return nil
    }
}
