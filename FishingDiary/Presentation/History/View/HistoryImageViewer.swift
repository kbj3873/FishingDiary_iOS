import SwiftUI

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
                        // isImageViewerPresented = false 대신 presentationMode.dismiss() 사용 권장
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
                        onDataChanged?()
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
