//
//  SeaAnalysisDetailView.swift
//  FishingDiary
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct SeaAnalysisDetailView: View {
    @StateObject private var viewModel: SeaAnalysisDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: SeaAnalysisDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // 배경색
            Color(hex: "F2F2F7")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 네비게이션 바
                navigationBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 지역 제목 섹션
                        headerSection
                        
                        // 그래프 섹션
                        graphSection
                        
                        // 수온 정보 카드 섹션 (표층, 중층, 저층)
                        temperatureCardsSection
                        
                        // 하단 안내 문구
                        footerView
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchTemperatureData()
        }
    }
    
    // MARK: - Components
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("뒤로")
                        .font(.system(size: 17))
                }
                .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "F2F2F7"))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.stationName)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
            
            Text("수온 변화 추이")
                .font(.system(size: 17))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var graphSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("최근 7일 수온 변화")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("일별 수온 추이 분석")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            // 그래프 영역
            TemperatureLineGraphView(dataSets: viewModel.graphData, dates: viewModel.graphDates)
                .frame(height: 280)
                .padding(.horizontal, 10)
        }
        .background(
            Color(hex: "2C303E") // Figma 다크 배경색 일치 필요
        )
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    private var temperatureCardsSection: some View {
        Group {
            if viewModel.hasAnyData {
                let columns = [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ]
                
                LazyVGrid(columns: columns, spacing: 12) {
                    if viewModel.hasSurfaceData {
                        temperatureCard(type: "표층", temp: viewModel.surfaceTemp, max: viewModel.surfaceMax, min: viewModel.surfaceMin, color: .blue)
                    }
                    if viewModel.hasMiddleData {
                        temperatureCard(type: "중층", temp: viewModel.middleTemp, max: viewModel.middleMax, min: viewModel.middleMin, color: .purple)
                    }
                    if viewModel.hasBottomData {
                        temperatureCard(type: "저층", temp: viewModel.bottomTemp, max: viewModel.bottomMax, min: viewModel.bottomMin, color: .green)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                // All data missing fallback
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("수온 데이터가 존재하지 않습니다.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120) // Approximate card height
                .background(Color.white.opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func temperatureCard(type: String, temp: String, max: String, min: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Rectangle()
                    .fill(color)
                    .frame(width: 4, height: 12)
                    .cornerRadius(2)
                
                Text(type)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(temp)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("최고")
                        .foregroundColor(.gray)
                    Text(max)
                        .foregroundColor(.gray)
                }
                .font(.system(size: 13))
                
                HStack(spacing: 4) {
                    Text("최저")
                        .foregroundColor(.gray)
                    Text(min)
                        .foregroundColor(.gray)
                }
                .font(.system(size: 13))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var footerView: some View {
        Text("이 지역은 표층, 중층, 저층 모든 수온 데이터를 제공합니다.")
            .font(.system(size: 13))
            .foregroundColor(.blue.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
    }
}
