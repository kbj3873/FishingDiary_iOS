import SwiftUI
import CoreLocation

struct HistoryDetailView: View {
    @StateObject private var viewModel: HistoryDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isExpanded: Bool = false
    
    init(sessionId: String, useCase: FishingRecordUseCase) {
        _viewModel = StateObject(wrappedValue: HistoryDetailViewModel(sessionId: sessionId, useCase: useCase))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. 지도 레이어 (전체 배경)
            HistoryMapView(
                centerCoordinate: $viewModel.centerCoordinate,
                polylines: $viewModel.polylines,
                markers: $viewModel.markers,
                stateMarkers: $viewModel.stateMarkers,
                stateMarkerInfos: $viewModel.stateMarkerInfos,
                selectedMarker: $viewModel.selectedMarker
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // 2. 상단 통합 헤더 카드
                headerCardView
                    .padding(.horizontal, 16)
                    .padding(.top, 16) // Safe Area 아래 여백
                
                Spacer()
            }
            
            // 3. 하단 선택된 지점 오버레이 카드
            if let marker = viewModel.selectedMarker {
                VStack {
                    Spacer()
                    
                    // 상태 마커 vs 사진 마커 분기 처리
                    if marker.thumbnailPath == nil {
                        // 상태 마커용 간단한 카드 (Figma: node-id 285:1589)
                        stateMarkerCard(marker: marker)
                    } else {
                        // 사진 마커용 썸네일 포함 카드
                        photoMarkerCard(marker: marker)
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onAppear()
        }
        // 5. 이미지 확대 보기 (FullScreenCover)
        .fullScreenCover(isPresented: $viewModel.isImageViewerPresented) {
            imageViewer
        }
    }
    
    // MARK: - Subviews
    
    private var headerCardView: some View {
        VStack(spacing: 0) {
            // 기본 헤더 영역 (항상 보임)
            HStack(alignment: .center) {
                // 뒤로가기 버튼
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("뒤로") // Figma "뒤로" 텍스트 추가
                            .font(.system(size: 16, weight: .regular))
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // 중앙 타이틀 (날짜 & 시간) - 탭하여 펼치기
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(viewModel.dateString)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(viewModel.startTimeString)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12)) // 사이즈 살짝 키움 (10 -> 12)
                            .foregroundColor(Color(hex: "C7C7CC")) // 연한 회색으로 변경
                            .rotationEffect(Angle(degrees: isExpanded ? 180 : 0))
                            .padding(.top, 2) // 텍스트와 간격 추가
                    }
                }
                
                Spacer()
                
                // 삭제 버튼
                Button(action: {
                    // 삭제 동작 (추후 구현)
                }) {
                    Image("trash_icon")
                        .renderingMode(.template) // 틴트 컬러 적용 허용
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            // 확장 영역 (상세 정보)
            if isExpanded {
                VStack(spacing: 0) {
                    
                    // 1. 상세 정보 3단 컬럼 (시간, 거리, 조과물)
                    HStack(spacing: 0) {
                        // 낚시 시간
                        expandedDetailItem(icon: "clock_icon", label: "낚시 시간", value: viewModel.totalDuration)
                        
                        Divider().frame(height: 32)
                        
                        // 총 거리
                        expandedDetailItem(icon: "distance_icon", label: "총 거리", value: String(format: "%.1f km", viewModel.totalDistance))
                        
                        Divider().frame(height: 32)
                        
                        // 조과물
                        expandedDetailItem(icon: "photo_icon", label: "조과물", value: "\(viewModel.markers.count)장")
                    }
                    .padding(.vertical, 24)
                    
                    // 2. 조과물 사진 섹션
                    if !viewModel.markers.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("조과물 사진")
                                .font(.system(size: 14, weight: .semibold)) // Figma: 14pt, Semibold
                                .foregroundColor(Color(hex: "1C1C1E"))
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) { // Figma: 간격 8
                                    ForEach(Array(viewModel.markers.enumerated()), id: \.element.id) { index, marker in
                                        Button(action: {
                                            viewModel.selectedImageIndex = index
                                            viewModel.isImageViewerPresented = true
                                        }) {
                                            if let image = UIImage(contentsOfFile: marker.thumbnailPath) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80) // Figma: 80x80
                                                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Figma: Radius 12
                                            } else {
                                                Rectangle()
                                                    .fill(Color(hex: "F2F2F7"))
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func expandedDetailItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(icon)
                .resizable()
                .frame(width: 16, height: 16) // Figma: 16pt
            
            Text(label)
                .font(.system(size: 13, weight: .medium)) // Figma: 13pt Medium
                .foregroundColor(Color(hex: "8E8E93"))
            
            Text(value)
                .font(.system(size: 15, weight: .semibold)) // Figma: 15pt Semibold
                .foregroundColor(Color(hex: "1C1C1E"))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 상태 마커용 간단한 카드 (Figma: node-id 285:1589)
    private func stateMarkerCard(marker: HistoryDetailViewModel.SelectedMarkerInfo) -> some View {
        HStack {
            // 좌측: 위치 아이콘 + 지점명 + 시간
            HStack(spacing: 16) {
                // 위치 아이콘 + 지점명
                HStack(spacing: 6) {
                    Image("distance_icon") // 위치 핀 아이콘
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text(marker.title) // "지점 #N"
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                // 시계 아이콘 + 시간
                HStack(spacing: 6) {
                    Image("clock_icon")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text(marker.timeString)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
            
            Spacer()
            
            // 닫기 버튼
            Button(action: {
                withAnimation {
                    viewModel.selectedMarker = nil
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56) // Figma: 약 56px 높이
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4) // Figma: 0px 4px 20px rgba(0,0,0,0.15)
        .padding(.horizontal, 16)
        .padding(.bottom, 34)
    }
    
    // MARK: - 사진 마커용 썸네일 포함 카드
    private func photoMarkerCard(marker: HistoryDetailViewModel.SelectedMarkerInfo) -> some View {
        HStack(spacing: 12) {
            // 썸네일
            Button(action: {
                if let thumbnailPath = marker.thumbnailPath,
                   let index = viewModel.markers.firstIndex(where: { $0.thumbnailPath == thumbnailPath }) {
                    viewModel.selectedImageIndex = index
                    viewModel.isImageViewerPresented = true
                }
            }) {
                if let thumbnailPath = marker.thumbnailPath,
                   let image = UIImage(contentsOfFile: thumbnailPath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(marker.title) // "지점 #N"
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            viewModel.selectedMarker = nil
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8E8E93"))
                    Text(marker.timeString)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                
                Button(action: {
                    if let thumbnailPath = marker.thumbnailPath,
                       let index = viewModel.markers.firstIndex(where: { $0.thumbnailPath == thumbnailPath }) {
                        viewModel.selectedImageIndex = index
                        viewModel.isImageViewerPresented = true
                    }
                }) {
                    Text("이 지점의 조과물")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .padding(.bottom, 34)
    }
    
    private var imageViewer: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $viewModel.selectedImageIndex) {
                ForEach(Array(viewModel.markers.enumerated()), id: \.element.id) { index, marker in
                    if let image = UIImage(contentsOfFile: marker.thumbnailPath) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tag(index)
                    } else {
                        Text("이미지를 불러올 수 없습니다.")
                            .foregroundColor(.white)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // 닫기 버튼
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.isImageViewerPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 40)
                .padding(.trailing, 20)
                Spacer()
            }
        }
    }
}
