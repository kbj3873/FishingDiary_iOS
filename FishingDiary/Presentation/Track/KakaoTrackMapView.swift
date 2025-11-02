//
//  KakaoTrackMapView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/29/25.
//

import SwiftUI

struct KakaoTrackMapView: View {
    @ObservedObject var viewModel: KakaoTrackMapViewModel
    @State private var shouldCleanupMap = false
    
    @State private var mapCoordinator: KakaoTrackMapViewControllerRepresentable.Coordinator?
    
    var body: some View {
        ZStack{
            // Kakao Map
            KakaoTrackMapViewControllerRepresentable(
                viewModel: viewModel,
                shouldCleanup: $shouldCleanupMap,
                coordinator: $mapCoordinator
            )
            .edgesIgnoringSafeArea(.all)
            
            // 상단 정보 표시
            VStack {
                TrackInfoView(
                    speed: viewModel.currentSpeed,
                    latitude: viewModel.currentLatitude,
                    longitude: viewModel.currentLongitude
                )
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .navigationTitle("포인트 추적")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.viewDidLoad()
        }
        .onDisappear {
            viewModel.viewWillDisappear()
            
            mapCoordinator?.cleanup()
            
            shouldCleanupMap = true
        }
        .onAppear {
            shouldCleanupMap = false
        }
    }
}
