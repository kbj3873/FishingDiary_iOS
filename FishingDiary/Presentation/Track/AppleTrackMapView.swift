//
//  AppleTrackMapView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/29/25.
//

import SwiftUI
import MapKit

struct AppleTrackMapView: View {
    @ObservedObject var viewModel: TrackMapViewModel
    @State private var shouldCleanupMap = false
    
    @State private var mapCoordinator: AppleTrackMapViewRepresentable.Coordinator?
    
    var body: some View {
        ZStack {
            // Apple Map
            AppleTrackMapViewRepresentable(
                mapLineInfo: $viewModel.mapLine,
                shouldCleanup: $shouldCleanupMap,
                getLocationList: viewModel.getLocationList,
                coordinator: $mapCoordinator
            )
            .edgesIgnoringSafeArea(.all)
            
            //상단 정보 표시
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
            print("onDisappear: shouldCleanup = true")
            shouldCleanupMap = true
        }
        .onAppear {
            shouldCleanupMap = false
        }
    }
}

// 상단 정보 표시 컴포넌트
struct TrackInfoView: View {
    let speed: String
    let latitude: String
    let longitude: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Speed: \(speed) km/h")
                .font(.system(size: 17))
            Text("Lat: \(latitude)")
                .font(.system(size: 17))
            Text("Lon: \(longitude)")
                .font(.system(size: 17))
        }
        .foregroundColor(.black)
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}
