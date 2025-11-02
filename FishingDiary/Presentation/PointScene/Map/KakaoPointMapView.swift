//
//  KakaoPointMapView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/28/25.
//

import SwiftUI

struct KakaoPointMapView: View {
    @ObservedObject var viewModel: KakaoPointMapViewModel
    @State private var selectedPin: KakaoMapPin?
    @State private var dmsType: DMSType = .D
    @State private var shouldCleanupMap = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Kakao Map (UIKit 래퍼)
            KakaoMapViewControllerRepresentable(
                viewModel: viewModel,
                selectedPin: $selectedPin,
                shouldCleanup: $shouldCleanupMap
            )
            .edgesIgnoringSafeArea(.all)
            
            // 하단 정보 패널
            if let pin = selectedPin {
                PointInfoView(
                    locationData: pin.locationData,
                    dmsType: $dmsType,
                    onClose: {
                        selectedPin = nil
                    }
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: selectedPin != nil)
            }
        }
        .navigationTitle("포인트 지도")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadPointData()
        }
        .onDisappear() {
            shouldCleanupMap = true
            selectedPin = nil
            viewModel.cleanup()
        }
        .onAppear() {
            shouldCleanupMap = false
        }
    }
}
