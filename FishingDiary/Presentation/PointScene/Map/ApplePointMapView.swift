//
//  ApplePointMapView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/24/25.
//

import SwiftUI
import MapKit
import Combine

struct ApplePointMapView: View {
    @StateObject var viewModel: PointMapViewModel
    @State private var selectedPin: MapPin?
    @State private var dmsType: DMSType = .D
    @State private var shouldCleanupMap = false
    
    // Map 표시 상태 추적
    //@State private var isMapVisible = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppleMapViewRepresentable(
                region: $viewModel.region,
                polylines: $viewModel.polyLines,
                annotations: $viewModel.mapPins,
                selectedAnnotation: $selectedPin,
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
            viewModel.viewDidLoad()
        }
        .onDisappear {
            shouldCleanupMap = false // 뒤로가기 시 즉시 정리 트리거
            selectedPin = nil
            print("ApplePointMapView disappeared")
        }
        .onAppear {
            shouldCleanupMap = false // 다시 진입 시 리셋
        }
    }
}

