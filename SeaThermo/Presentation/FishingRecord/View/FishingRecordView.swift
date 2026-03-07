import SwiftUI
import MapKit

struct FishingRecordView: View {
    @ObservedObject var viewModel: FishingRecordViewModel
    @State private var shouldCleanupMap = false
    @State private var mapCoordinator: RecordMapView.Coordinator?
    @State private var kakaoMapAction: KakaoMapAction? = nil
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    
    // 0: Apple, 1: Kakao
    @AppStorage(UserDefaultKey.mapType) private var mapType: Int = 0
    
    var body: some View {
        ZStack {
            // 1. 지도 레이어
            if mapType == 1 {
                RecordKakaoMapView(
                    mapLineInfo: $viewModel.currentMapLine,
                    shouldCleanup: $shouldCleanupMap,
                    mapAction: $kakaoMapAction,
                    markers: $viewModel.markers,
                    photoMarkers: $viewModel.photoMarkers,
                    fishingState: $viewModel.fishingState,
                    userLocation: $viewModel.currentLocation,
                    getLocationList: viewModel.getLocationList
                )
                .edgesIgnoringSafeArea(.all)
            } else {
                RecordMapView(
                    mapLineInfo: $viewModel.currentMapLine,
                    shouldCleanup: $shouldCleanupMap,
                    markers: $viewModel.markers,
                    photoMarkers: $viewModel.photoMarkers,
                    fishingState: $viewModel.fishingState,
                    getLocationList: viewModel.getLocationList,
                    coordinator: $mapCoordinator
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            // 2. Overlay Layer
            // 2. 오버레이 레이어
            ZStack(alignment: .top) {
                // 상단 정보 (상태, 타이머)
                topInfoBar
                    .padding(.top, 16) // Figma Top 16
                    .padding(.horizontal, 16) // Figma Left/Right 16
                
                // 지도 컨트롤 버튼 (우측 상단, TopInfoBar 바로 아래에 위치하도록 조정)
                // TopInfoBar Height(48) + Top Margin(16) + Spacing(12) = 76
                HStack {
                    Spacer()
                    mapControlButtons
                        .padding(.trailing, 16) // Figma Right 16
                        .padding(.top, 16 + 48 + 12) // TopInfoBar Bottom + Gap
                }
                
                VStack {
                    Spacer()
                    
                    // 하단 컨트롤 (녹화, 카메라, 썸네일)
                    bottomControlBar
                        .padding(.bottom, 40) // Bottom Margin
                }
            }
        }
        .onAppear {
            viewModel.startMonitoring()
            // 탭 진입 시 위치 권한 체크
            viewModel.checkLocationPermission()
        }
        .onDisappear {
            viewModel.stopMonitoring()
            
            // 탭 이동 시에도 지도를 유지하기 위해 cleanup 로직 제거
            // shouldCleanupMap = true
            // mapCoordinator?.cleanup()
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage)
                .edgesIgnoringSafeArea(.all) // 전체 화면 꽉 차게
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage, let data = image.jpegData(compressionQuality: 0.8) {
                viewModel.savePhoto(data: data)
            }
        }

        .overlay(
            Group {
                if viewModel.isStopPopupPresented {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                // 배경 터치 시 팝업 닫기 (선택 사항)
                                // viewModel.isStopPopupPresented = false
                            }
                        
                        CommonPopupView(
                            title: "기록 중단",
                            message: "현재 진행 중인 낚시 기록을 중단하시겠습니까? 현재까지의 기록은 모두 저장됩니다.",
                            layoutType: .horizontal,
                            primaryButtonText: "계속 기록",
                            primaryAction: {
                                viewModel.isStopPopupPresented = false
                            },
                            secondaryButtonText: "중단",
                            secondaryAction: {
                                viewModel.stopRecording()
                                if mapType == 1 {
                                    kakaoMapAction = .clearMap
                                } else {
                                    mapCoordinator?.clearMap()
                                }
                                shouldCleanupMap = true
                            }
                        )
                    }
                }
                
                if viewModel.isCameraPermissionPopupPresented {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                // 배경 터치 등 처리
                            }
                        
                        CommonPopupView(
                            title: "카메라 권한 필요",
                            message: "사진 촬영을 위해 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.",
                            layoutType: .vertical,
                            primaryButtonText: "설정으로 이동",
                            primaryAction: {
                                viewModel.isCameraPermissionPopupPresented = false
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            },
                            secondaryButtonText: "취소",
                            secondaryAction: {
                                viewModel.isCameraPermissionPopupPresented = false
                            }
                        )
                    }
                }
                
                if viewModel.isLocationPermissionPopupPresented {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                // 필수 권한이므로 배경 터치로 닫기 막음 (선택 사항)
                            }
                        
                        CommonPopupView(
                            title: "위치 권한이 필요합니다",
                            message: "낚시 기록을 위해 위치 권한이 필요합니다.\n설정에서 위치 서비스를 허용해주세요.",
                            layoutType: .horizontal,
                            primaryButtonText: "설정으로 이동",
                            primaryAction: {
                                viewModel.isLocationPermissionPopupPresented = false
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            },
                            secondaryButtonText: "취소",
                            secondaryAction: {
                                viewModel.isLocationPermissionPopupPresented = false
                                // 권한 거부 시 탭 이동이나 다른 동작이 필요하다면 여기서 처리
                                // 예: 메인 탭으로 이동 등 (기획에 따라 다름, 현재는 팝업만 닫음)
                            }
                        )
                    }
                }
            }
        )
    }

// MARK: - Subviews
    
    // 상단 정보 바 (Figma 스타일: 동적 상태)
    private var topInfoBar: some View {
        HStack(spacing: 0) {
            // 좌측 상태 정보 그룹
            HStack(spacing: 12) { // Figma 간격: 12
                // 상태 아이콘 (Dot)
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                    .opacity(statusDotOpacity)
                
                // 상태 텍스트
                Text(!viewModel.isRecording ? "대기 중" : viewModel.fishingState.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(statusTextColor)
                    .fixedSize() // 텍스트 줄바꿈 방지
                
                // 이동/탐색/낚시 중일 때 속도 표시 (녹화 중일 때만)
                if viewModel.isRecording {
                    HStack(spacing: 6) {
                        // 속도 수치 + 단위
                        Text(String(format: "%.1f %@", viewModel.convertedSpeed, viewModel.speedUnit == .knots ? "knots" : "km/h"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .fixedSize()
                        
                        // 단위 토글 스위치 (Figma Design)
                        ZStack {
                            // 배경
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "F2F2F7"))
                                .frame(width: 109, height: 28)
                            
                            HStack(spacing: 0) {
                                // Knots 버튼
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.speedUnit = .knots
                                    }
                                }) {
                                    Text("knots")
                                        .font(.system(size: 11, weight: viewModel.speedUnit == .knots ? .semibold : .medium))
                                        .foregroundColor(viewModel.speedUnit == .knots ? Color(hex: "1F2937") : Color(hex: "6B7280"))
                                        .frame(width: 54, height: 24)
                                        .background(
                                            viewModel.speedUnit == .knots ?
                                            RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1) : nil
                                        )
                                }
                                .buttonStyle(StaticButtonStyle()) // 하이라이트 제거
                                
                                // km/h 버튼
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.speedUnit = .kmh
                                    }
                                }) {
                                    Text("km/h")
                                        .font(.system(size: 11, weight: viewModel.speedUnit == .kmh ? .semibold : .medium))
                                        .foregroundColor(viewModel.speedUnit == .kmh ? Color(hex: "1F2937") : Color(hex: "6B7280"))
                                        .frame(width: 50, height: 24)
                                        .background(
                                            viewModel.speedUnit == .kmh ?
                                            RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1) : nil
                                        )
                                }
                                .buttonStyle(StaticButtonStyle()) // 하이라이트 제거
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
            }
            
            Spacer()
            
            // 우측 저장된 지점 수 (공통)
            Text("\(viewModel.savedPointCount)개 지점 저장")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(uiColor: .systemGray2))
                .fixedSize()
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 2)
    }
    
    // 지도 컨트롤 버튼 (배경: White Circle, 아이콘: Asset)
    private var mapControlButtons: some View {
        VStack(spacing: 8) {
            Button(action: {
                if mapType == 1 {
                    // 약간의 딜레이를 주어 상태 변경 인식
                    Task { kakaoMapAction = .zoomIn }
                } else {
                    mapCoordinator?.zoomIn()
                }
            }) {
                CircleButton(iconName: "btn_zoom_in")
            }
            
            Button(action: {
                if mapType == 1 {
                    Task { kakaoMapAction = .zoomOut }
                } else {
                    mapCoordinator?.zoomOut()
                }
            }) {
                CircleButton(iconName: "btn_zoom_out")
            }
            
            Button(action: {
                if mapType == 1 {
                    Task { kakaoMapAction = .moveToUserLocation }
                } else {
                    mapCoordinator?.moveToUserLocation()
                }
            }) {
                CircleButton(iconName: "btn_my_location")
            }
        }
    }
    
    // 원형 버튼 공통 뷰
    private struct CircleButton: View {
        let iconName: String
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            }
        }
    }
    
    // 하단 컨트롤 바
    private var bottomControlBar: some View {
        VStack(spacing: 16) {
            // 안내 텍스트 (녹화 전일 때만 표시)
            if !viewModel.isRecording {
                Text("낚시를 시작하려면 버튼을 누르세요")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(24)
                    .shadow(radius: 4)
            }
            
            HStack(alignment: .center) {
                // 썸네일 (좌측) - 삭제됨
                Spacer() // 좌측 공백 채우기 (중앙 정렬 유지를 위해 Spacer 비율 조정 필요 시 확인)
                
                Spacer()
                
                // 녹화 제어 버튼 (중앙) - 배경(Code) + 아이콘(Asset)
                Button(action: {
                    if viewModel.isRecording {
                        // 바로 중단하지 않고 팝업 표시
                        viewModel.isStopPopupPresented = true
                    } else {
                        viewModel.startRecording()
                    }
                }) {
                    ZStack {
                        // 그림자 및 외곽선 효과
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 72, height: 72)
                            .blur(radius: 10)
                            .offset(y: 4)
                        
                        // 메인 버튼 배경 (상태에 따라 색상 변경)
                        Circle()
                            .fill(viewModel.isRecording ? Color(hex: "EF4444") : Color(hex: "10B981")) // Stop: Red, Play: Green(#10b981)
                            .frame(width: 64, height: 64)
                        
                        // 아이콘 (흰색)
                        Image(viewModel.isRecording ? "btn_record_stop" : "btn_record_play")
                            .resizable()
                            .renderingMode(.template) // 흰색 틴트 강제 적용
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                    }
                    // 터치 영역
                    .frame(width: 84, height: 84)
                }
                
                Spacer()
                
                // 카메라 버튼 (우측)
                Button(action: {
                    if viewModel.isCameraAuthorized() {
                        showCamera = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        
                        Image("btn_camera")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
                .opacity(viewModel.isRecording ? 1.0 : 0.4)
            }
            .padding(.horizontal, 30)
        }
    }
    
    private func thumbnailView(path: String) -> some View {
        let fullPath = getDocumentsDirectory().appendingPathComponent(path).path
        let image = UIImage(contentsOfFile: fullPath) ?? UIImage()
        
        return Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 2))
            .shadow(radius: 4)
            .onTapGesture {
                // 갤러리 보기 등 추후 구현
            }
    }
    
    // MARK: - Helpers
    
    // 상태 아이콘 색상 (Figma Data)
    private var statusColor: Color {
        if !viewModel.isRecording {
            return Color(hex: "CAD5E2") // #cad5e2 (회색-파랑: 대기)
        }
        switch viewModel.fishingState {
        case .moving: return Color(hex: "2563EB") // #2563eb (파랑)
        case .drifting: return Color(hex: "F59E0B") // #f59e0b (주황)
        case .fishing: return Color(hex: "EF4444") // #ef4444 (빨강)
        }
    }
    
    // 상태 아이콘 투명도
    private var statusDotOpacity: Double {
        if !viewModel.isRecording { return 1.0 }
        switch viewModel.fishingState {
        case .moving: return 0.63
        case .drifting: return 0.60
        case .fishing: return 0.71
        }
    }
    
    // 상태 텍스트 색상 (Figma Data)
    private var statusTextColor: Color {
        if !viewModel.isRecording {
            return Color(hex: "64748B") // #64748b (Slate-500)
        }
        switch viewModel.fishingState {
        case .moving: return Color(hex: "2563EB")
        case .drifting: return Color(hex: "F59E0B")
        case .fishing: return Color(hex: "EF4444")
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval)
        let mm = (seconds % 3600) / 60
        let ss = seconds % 60
        return String(format: "%02d:%02d", mm, ss)
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// SwiftUI 이미지 피커
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        #if targetEnvironment(simulator)
        picker.sourceType = .photoLibrary
        #else
        picker.sourceType = .camera
        #endif
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Helper Views
struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
