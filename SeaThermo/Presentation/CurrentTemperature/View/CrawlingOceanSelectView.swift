//
//  CrawlingOceanSelectView.swift
//  SeaThermo
//

import SwiftUI

struct CrawlingOceanSelectView: View {
    @ObservedObject var viewModel: CrawlingOceanSelectViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("지역 선택")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)

                    Text("즐겨찾기에 추가할 지역을 선택하세요 (최대 7개)")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8E8E93"))
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("완료")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "2563EB"))
                }
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // 목록
            if viewModel.oceanStations.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.oceanStations, id: \.self) { item in
                            Button {
                                viewModel.saveCheckList(!item.isChecked, model: item)
                            } label: {
                                HStack(spacing: 0) {
                                    Text(item.stationName)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.leading, 20)

                                    if !item.seaName.isEmpty {
                                        Text(item.seaName)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(Color(hex: "8E8E93"))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(hex: "E5E5EA"))
                                            )
                                            .padding(.leading, 8)
                                    }

                                    Spacer()

                                    Image(item.isChecked ? "ic_star_on" : "ic_star_off")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .padding(.trailing, 20)
                                }
                                .frame(height: 60)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color(hex: "F2F2F7").ignoresSafeArea())
        .onAppear {
            viewModel.viewDidLoad()
        }
        .onDisappear {
            viewModel.viewDidDisappear()
        }
        .alert("즐겨찾기 초과", isPresented: $viewModel.showMaxAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("즐겨찾기는 최대 7개까지 추가할 수 있습니다.")
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("관측소 목록을 불러올 수 없습니다")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "8E8E93"))
            Text("앱을 재시작하거나 잠시 후 다시 시도해주세요")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "AEAEB2"))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
