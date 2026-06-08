import SwiftUI
import CoreLocation

struct HistoryDetailView: View {
    @StateObject private var viewModel: HistoryDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isExpanded: Bool = false
    
    private let onDataChanged: (() -> Void)?
    
    init(sessionId: String, useCase: FishingRecordUseCase, onDataChanged: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: HistoryDetailViewModel(sessionId: sessionId, useCase: useCase))
        self.onDataChanged = onDataChanged
    }
    
    @AppStorage(UserDefaultKey.mapType) private var mapType: Int = 0
    
    // ... (init)

    var body: some View {
        ZStack(alignment: .top) {
            // 1. 지도 레이어 (전체 배경)
            if mapType == 1 {
                HistoryKakaoMapView(
                    centerCoordinate: $viewModel.centerCoordinate,
                    polylines: $viewModel.polylines,
                    markers: $viewModel.markers,
                    stateMarkers: $viewModel.stateMarkers,
                    stateMarkerInfos: $viewModel.stateMarkerInfos,
                    boundaryMarkers: $viewModel.boundaryMarkers,
                    boundaryMarkerInfos: $viewModel.boundaryMarkerInfos,
                    selectedMarker: $viewModel.selectedMarker,
                    isMapInitialized: $viewModel.isMapInitialized
                )
                .edgesIgnoringSafeArea(.all)
            } else {
                HistoryMapView(
                    centerCoordinate: $viewModel.centerCoordinate,
                    polylines: $viewModel.polylines,
                    markers: $viewModel.markers,
                    stateMarkers: $viewModel.stateMarkers,
                    stateMarkerInfos: $viewModel.stateMarkerInfos,
                    boundaryMarkers: $viewModel.boundaryMarkers,
                    boundaryMarkerInfos: $viewModel.boundaryMarkerInfos,
                    selectedMarker: $viewModel.selectedMarker,
                    isMapInitialized: $viewModel.isMapInitialized
                )
                .edgesIgnoringSafeArea(.all)
            }
            
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
            // 5. 삭제 팝업
            deletePopupOverlay
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onAppear()
        }
        // 5. 이미지 확대 보기 (FullScreenCover)
        .fullScreenCover(isPresented: $viewModel.isImageViewerPresented) {
            HistoryImageViewer(viewModel: viewModel, onDataChanged: nil) // 이미지 뷰어에서는 콜백 호출 안함
        }
        .onDisappear {
            // 화면이 닫힐 때만 데이터 변경 사항이 있으면 리스트 갱신
            // (deleteRecord로 인한 닫힘은 shouldDismiss에서 이미 처리됨)
            if viewModel.isDataModified {
                onDataChanged?()
            }
        }
    }
    
    // MARK: - Subviews

    private var expandedHeaderContentHeight: CGFloat {
        viewModel.markers.isEmpty ? 101 : 258
    }
    
    private var headerCardView: some View {
        VStack(spacing: 0) {
            // 기본 헤더 영역 (항상 보임)
            ZStack {
                // 중앙 타이틀 (날짜 & 시간) - 탭하여 펼치기
                // ZStack의 가장 아래(먼저 선언) 또는 zIndex로 배치 순서 고려.
                // 여기서는 겹침 문제가 없으므로 순서대로 배치하되, 중앙 요소가 가장 중요하므로 명시적으로 center 정렬
                
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.24)) {
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
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "C7C7CC"))
                                .rotationEffect(Angle(degrees: isExpanded ? 180 : 0))
                                .padding(.top, 2)
                        }
                        .contentShape(Rectangle())
                    }
                    Spacer()
                }
                .zIndex(1)
                
                // 좌우 버튼
                HStack {
                    // 뒤로가기 버튼
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("뒤로")
                                .font(.system(size: 16, weight: .regular))
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // 삭제 버튼
                    Button(action: {
                        withAnimation {
                            viewModel.isDeletePopupPresented = true
                        }
                    }) {
                        Image("trash_icon")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            // 확장 영역 (상세 정보)
            expandedHeaderContent
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: isExpanded ? expandedHeaderContentHeight : 0, alignment: .top)
                .clipped()
                .allowsHitTesting(isExpanded)
                .accessibilityHidden(!isExpanded)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                onDataChanged?()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var expandedHeaderContent: some View {
        VStack(spacing: 0) {
            // 1. 상세 정보 3단 컬럼 (시간, 거리, 조과물)
            Divider()
                .background(Color(hex: "E5E5EA"))
                .padding(.horizontal, 16)

            HStack(spacing: 0) {
                // 낚시 시간
                expandedDetailItem(icon: "clock_icon", label: "낚시 시간", value: viewModel.totalDuration)

                Rectangle()
                    .fill(Color(hex: "E5E5EA"))
                    .frame(width: 1, height: 40)

                // 이동 경로 (지점 개수)
                expandedDetailItem(icon: "distance_icon", label: "이동 경로", value: "\(viewModel.boundaryMarkerInfos.count + viewModel.stateMarkerInfos.count + viewModel.markers.count)지점")

                Rectangle()
                    .fill(Color(hex: "E5E5EA"))
                    .frame(width: 1, height: 40)

                // 조과물
                expandedDetailItem(icon: "photo_icon", label: "조과물", value: "\(viewModel.markers.count)장")
            }
            .padding(.vertical, 20)

            // 2. 조과물 사진 섹션
            if !viewModel.markers.isEmpty {
                Divider()
                    .background(Color(hex: "E5E5EA"))
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("조과물 사진")
                        .font(.system(size: 14, weight: .semibold)) // Figma: 14pt, Semibold
                        .foregroundColor(Color(hex: "1C1C1E"))
                        .padding(.horizontal, 16)
                        .padding(.top, 24) // 구분선과의 간격 추가

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
    }
    
    // MARK: - 삭제 팝업 오버레이
    @ViewBuilder
    private var deletePopupOverlay: some View {
        if viewModel.isDeletePopupPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewModel.isDeletePopupPresented = false
                    }
                
                CommonPopupView(
                    title: "낚시 기록 삭제",
                    message: "이 기록을 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.",
                    layoutType: .horizontal, // Figma 확인 필요하지만 일단 기존 스타일
                    primaryButtonText: "삭제",
                    primaryButtonTextColor: .red,
                    primaryAction: {
                        viewModel.deleteRecord()
                        viewModel.isDeletePopupPresented = false
                    },
                    secondaryButtonText: "취소",
                    secondaryAction: {
                        viewModel.isDeletePopupPresented = false
                    }
                )
            }
            .zIndex(2) // 최상단 배치
        }
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
    
}

// MARK: - HistoryImageViewer
struct HistoryImageViewer: View {
    @ObservedObject var viewModel: HistoryDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let onDataChanged: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 1. 이미지 뷰어 (TabView)
            TabView(selection: $viewModel.selectedImageIndex) {
                ForEach(Array(viewModel.markers.enumerated()), id: \.element.id) { index, marker in
                    AsyncLocalImageView(path: marker.thumbnailPath)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // 기본 점 숨김
            
            // 2. 상단 컨트롤 (닫기, 삭제)
            VStack {
                HStack(spacing: 20) {
                    Spacer()
                    
                    // 삭제 버튼 (휴지통)
                    Button(action: {
                        viewModel.isPhotoDeletePopupPresented = true
                    }) {
                        Image("trash_icon")
                            .renderingMode(.template) // 템플릿 모드로 변경하여 틴트 컬러 적용
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    
                    // 닫기 버튼 (X)
                    Button(action: {
                        // presentationMode.dismiss()를 명시적으로 호출하여 커버만 닫음
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 60) // Safe Area 고려
                .padding(.trailing, 20)
                
                Spacer()
                
                // 3. 하단 컨트롤 (페이지 이동 및 인디케이터)
                HStack(spacing: 40) {
                    // 이전 버튼
                    Button(action: {
                        withAnimation {
                            if viewModel.selectedImageIndex > 0 {
                                viewModel.selectedImageIndex -= 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white.opacity(viewModel.selectedImageIndex > 0 ? 1.0 : 0.3))
                    }
                    .disabled(viewModel.selectedImageIndex <= 0)
                    
                    // 페이지 텍스트 (1 / 5)
                    if !viewModel.markers.isEmpty {
                        Text("\(viewModel.selectedImageIndex + 1) / \(viewModel.markers.count)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // 다음 버튼
                    Button(action: {
                        withAnimation {
                            if viewModel.selectedImageIndex < viewModel.markers.count - 1 {
                                viewModel.selectedImageIndex += 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white.opacity(viewModel.selectedImageIndex < viewModel.markers.count - 1 ? 1.0 : 0.3))
                    }
                    .disabled(viewModel.selectedImageIndex >= viewModel.markers.count - 1)
                }
                .padding(.bottom, 60)
            }
            
            // 4. 사진 삭제 팝업 오버레이
            deletePopupOverlay
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var deletePopupOverlay: some View {
        if viewModel.isPhotoDeletePopupPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewModel.isPhotoDeletePopupPresented = false
                    }
                
                CommonPopupView(
                    title: "사진 삭제",
                    message: "이 사진을 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.",
                    layoutType: .horizontal,
                    primaryButtonText: "삭제",
                    primaryButtonTextColor: .red,
                    primaryAction: {
                        viewModel.deletePhoto(at: viewModel.selectedImageIndex)
                        viewModel.isPhotoDeletePopupPresented = false
                        // 여기서 onDataChanged 호출하지 않음 (HistoryDetailView 닫힐 때 호출)
                    },
                    secondaryButtonText: "취소",
                    secondaryAction: {
                        viewModel.isPhotoDeletePopupPresented = false
                    }
                )
            }
            .zIndex(2)
        }
    }
}

// MARK: - AsyncLocalImageView
struct AsyncLocalImageView: View {
    let path: String
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Color.black
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("이미지를 불러올 수 없습니다.")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        isLoading = true
        // 백그라운드 스레드에서 이미지 로드
        Task {
            let loadedImage = UIImage(contentsOfFile: path)
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        }
    }
}
