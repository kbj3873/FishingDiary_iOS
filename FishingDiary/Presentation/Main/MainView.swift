//
//  MainView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/15/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                
                VStack {
                    
                    FavoriteOceanListButtonView(viewModel: viewModel)
                    
                    TempuratureListView(viewModel: viewModel)
                    
                    Spacer()
                    
                    ButtonListView(viewModel: viewModel)
                    
                    MapSelectButtons(viewModel: viewModel)
                    
                }
                .padding(.vertical)
                .background {
                    Image("sunset_background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
            }
            .onAppear {
                viewModel.fetchStationList()
            }
        }
        .navigationBarHidden(true)
        
    }
}

// 수온 즐겨찾기
struct FavoriteOceanListButtonView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack {
            Spacer()
            NavigationLink {
                viewModel.createOceanSelectView()
            } label: {
                Text("수온 즐겨찾기")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 20)
                    .background(Color.clear)
                    .padding(.trailing, 10)
            }
        }
    }
}

struct TempuratureListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        if viewModel.oceanStations.count > 1 {
            List(viewModel.oceanStations, id: \.self) { station in
                TempuratureRowUIView(station: station)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
                UITableView.appearance().backgroundView = nil
                UITableViewCell.appearance().backgroundColor = .clear
            }
            .refreshable {
                viewModel.fetchStationList()
            }
        }
        
        else {
            ZStack {
                Color.black.opacity(0.3)
                
                Text("수온 즐겨찾기를 추가해 주세요")
                    .foregroundColor(.white)
            }
        }
    }
}

// 수온정보 row
struct TempuratureRowUIView: View {
    let station: OceanStationModel
    
    var body: some View {
        HStack(spacing: 0) {
            Text(station.stationName).frame(maxWidth: .infinity,
                                            alignment: .center)
            Text(station.surTempurature).frame(maxWidth: .infinity,
                                               alignment: .center)
            Text(station.midTempurature).frame(maxWidth: .infinity,
                                               alignment: .center)
            Text(station.botTempurature).frame(maxWidth: .infinity,
                                               alignment: .center)
        }
        .frame(height: 40.0)
        .foregroundColor(.white)
        .listRowBackground(Color.black.opacity(0.3))
        .listRowInsets(EdgeInsets()) // 좌우 여백 제거
        .listRowSeparator(.hidden)
    }
}

struct ButtonListView: View {
    
    @State private var showOceanInfo = false
    @State private var showPoint = false
    @State private var showTrackingStart = false
    
    @ObservedObject var viewModel: MainViewModel
    
    let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()
    
    @State private var appleTrackMapViewModel: TrackMapViewModel?
    @State private var kakaoTrackMapViewModel: KakaoTrackMapViewModel?
    
    var body: some View {
        VStack {
            Button("수온정보") {
                showOceanInfo = true
            }
            .frame(height:44)
            Button("포인트") {
                showPoint = true
            }
            .frame(height:44)
            Button("추적시작") {
                showTrackingStart = true
            }
            .frame(height:44)
        }
        .foregroundColor(.white)
        .padding(.bottom, 10)
        .onAppear {
            if appleTrackMapViewModel == nil {
                appleTrackMapViewModel = pointSceneDIContainer.makeTrackMapViewModel()
            }
            
            if kakaoTrackMapViewModel == nil {
                kakaoTrackMapViewModel = pointSceneDIContainer.makeKakaoTrackMapViewModel()
            }
        }
        
        NavigationLink(destination: seaWaterTemperatureDestination,
                       isActive: $showOceanInfo
        ) {
            EmptyView()
        }
        
        NavigationLink(destination: viewModel.createPointDateLietView(),
                       isActive: $showPoint
        ) {
            EmptyView()
        }
        
        NavigationLink(destination: trackMapDestination,
                       isActive: $showTrackingStart
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var seaWaterTemperatureDestination: some View {
        SeaWaterTemperatureView(viewModel: pointSceneDIContainer.makeTemperatureViewModel())
    }
    
    @ViewBuilder
    private var trackMapDestination: some View {
        if FDAppManager.shared.mapTp == .AppleMap {
            if let viewModel = appleTrackMapViewModel {
                AppleTrackMapView(viewModel: viewModel)
            }
        } else {
            if let viewModel = kakaoTrackMapViewModel {
                KakaoTrackMapView(viewModel: viewModel)
            }
        }
    }
}

struct MapSelectButtons: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.setMapType(.AppleMap)
            } label: {
                Text("Apple Map")
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)
            .tint(viewModel.selectedMapType == MapType.AppleMap ? .white.opacity(0.3) : Color.clear)
            .buttonStyle(.bordered)
            
            Button {
                viewModel.setMapType(.KakaoMap)
            } label: {
                Text("Kakao Map")
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)
            .tint(viewModel.selectedMapType == MapType.KakaoMap ? .white.opacity(0.3) : Color.clear)
            .buttonStyle(.bordered)
        }
        .frame(height: 34)
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}
