//
//  OceanSelectView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/16/25.
//

import SwiftUI

struct OceanSelectView: View {
    @ObservedObject var viewModel: OceanSelectViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("지역 선택")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("즐겨찾기에 추가할 지역을 선택하세요")
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
            .padding(.top, 30) // 상단 핸들을 위한 여백 추가
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // List
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
                                
                                // Sea Name Badge
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
        .background(Color(hex: "F2F2F7").ignoresSafeArea())
        .onAppear {
            viewModel.viewDidLoad()
        }
        .onDisappear {
            viewModel.viewDidDisappear()
        }
    }
}

// 버튼 클릭 효과를 위한 스타일
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
