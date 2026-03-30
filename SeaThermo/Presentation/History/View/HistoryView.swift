//
//  HistoryView.swift
//  SeaThermo
//
//  Created by Gemini on 2/4/26.
//

import SwiftUI

/// 낚시 히스토리 메인 화면
struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 0) {
                // 헤더
                headerView
                
                // 컨텐츠
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.records.isEmpty {
                    emptyView
                } else {
                    recordListView
                }
            }
            .background(Color(hex: "F2F2F7"))
            .navigationBarHidden(true)
            .navigationDestination(for: HistoryRecordItem.self) { record in
                HistoryDetailView(sessionId: record.id, useCase: viewModel.useCase, onDataChanged: {
                    viewModel.loadRecords()
                })
            }
        }
        .onAppear {
            // 탭 이동 시 불필요한 리로드 방지 (데이터가 없고 로딩중이 아닐 때만 로드)
            if viewModel.records.isEmpty && !viewModel.isLoading {
                viewModel.loadRecords()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("낚시 히스토리")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "1F2937"))
            
            Text("과거 낚시 기록을 확인하세요")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8E8E93"))
                .kerning(-0.1504)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 48)
        .padding(.bottom, 24)
        .background(Color.white)
    }
    
    // MARK: - Record List
    private var recordListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.records) { record in
                    NavigationLink(value: record) {
                        HistoryRecordCardView(item: record)
                    }
                    .buttonStyle(PlainButtonStyle()) // 리스트 스타일 간섭 방지
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fish")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "9CA3AF"))
            
            Text("기록된 낚시가 없습니다")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
            
            Text("낚시기록 탭에서 새로운 낚시를 시작해보세요")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("기록을 불러오는 중...")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6B7280"))
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let repository = DefaultFishingRecordRepository()
    let useCase = DefaultFishingRecordUseCase(repository: repository)
    let viewModel = HistoryViewModel(useCase: useCase)
    
    return HistoryView(viewModel: viewModel)
}
