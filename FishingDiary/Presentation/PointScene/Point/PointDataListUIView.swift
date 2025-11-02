//
//  PointDataListUIView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/21/25.
//

import SwiftUI

struct PointDataListUIView: View {
    @ObservedObject var viewModel: PointDataListViewModel
    
    var body: some View {
        ZStack {
            List(Array(viewModel.pointDataList.enumerated()), id: \.element.dataPath) { index, item in
                
                HStack {
                    Button {
                        if FDAppManager.shared.mapTp == .AppleMap {
                            viewModel.pushSelectPointMap(at: index)
                        } else {
                            viewModel.pushSelectKakaoPointMap(at: index)
                        }
                    } label: {
                        Text(item.dataName)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    
                    NavigationLink(
                        destination: destinationView,
                        isActive: $viewModel.isShowingPointMap
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                 
            }
            .listStyle(.plain)
        }
        .navigationTitle("포인트 데이터")
        .onAppear {
            viewModel.viewDidLoad()
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if FDAppManager.shared.mapTp == .AppleMap {
            if let viewModel = viewModel.pointMapViewModel {
                ApplePointMapView(viewModel: viewModel)
            }
        }
        
        else {
            if let viewModel = viewModel.kakaoPointMapViewModel {
                KakaoPointMapView(viewModel: viewModel)
            }
        }
    }
}

