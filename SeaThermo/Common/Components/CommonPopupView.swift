import SwiftUI

// MARK: - Layout Type
enum PopupLayoutType {
    case horizontal // 기존 스타일 (좌우 배치)
    case vertical   // 추가 스타일 (상하 배치)
}

struct CommonPopupView: View {
    // MARK: - Properties
    let title: String
    let message: String
    let layoutType: PopupLayoutType
    let primaryButtonText: String
    let primaryButtonTextColor: Color
    let primaryButtonFontWeight: Font.Weight
    let secondaryButtonText: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    let accessoryContent: AnyView?
    
    // MARK: - Internal Config
    private var popupWidth: CGFloat {
        switch layoutType {
        case .horizontal: return 272
        case .vertical: return 320
        }
    }
    
    private var buttonHeight: CGFloat {
        switch layoutType {
        case .horizontal: return 44
        case .vertical: return 50
        }
    }
    
    // MARK: - Initializer
    init(
        title: String,
        message: String,
        layoutType: PopupLayoutType = .horizontal,
        primaryButtonText: String = "확인",
        primaryButtonTextColor: Color = Color(hex: "2563EB"),
        primaryButtonFontWeight: Font.Weight = .semibold,
        primaryAction: @escaping () -> Void,
        secondaryButtonText: String? = nil,
        secondaryAction: (() -> Void)? = nil,
        accessoryContent: AnyView? = nil
    ) {
        self.title = title
        self.message = message
        self.layoutType = layoutType
        self.primaryButtonText = primaryButtonText
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonFontWeight = primaryButtonFontWeight
        self.primaryAction = primaryAction
        self.secondaryButtonText = secondaryButtonText
        self.secondaryAction = secondaryAction
        self.accessoryContent = accessoryContent
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 배경 딤 효과 (필요 시 주석 해제)
            // Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 1. Content Area
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.top, 24)
                    
                    Text(message)
                        .font(.system(size: 17, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "8E8E93")) // System Gray
                        .padding(.horizontal, 16)
                        .padding(.bottom, accessoryContent == nil ? 24 : 8)
                        .fixedSize(horizontal: false, vertical: true)

                    if let accessoryContent {
                        accessoryContent
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // 2. Buttons Area
                if layoutType == .horizontal {
                    horizontalLayoutButtons
                } else {
                    verticalLayoutButtons
                }
            }
            .frame(width: popupWidth)
            .background(Color.white.opacity(0.95))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    // MARK: - Horizontal Layout (기존)
    private var horizontalLayoutButtons: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.black.opacity(0.1))
            
            HStack(spacing: 0) {
                // Secondary (Left)
                if let secondaryText = secondaryButtonText {
                    Button(action: { secondaryAction?() }) {
                        Text(secondaryText)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Divider()
                        .background(Color.black.opacity(0.1))
                        .frame(width: 0.5)
                }
                
                // Primary (Right)
                Button(action: { primaryAction() }) {
                    Text(primaryButtonText)
                        .font(.system(size: 17, weight: primaryButtonFontWeight))
                        .foregroundColor(primaryButtonTextColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: buttonHeight)
        }
    }
    
    // MARK: - Vertical Layout (신규 - Figma 스타일 2)
    private var verticalLayoutButtons: some View {
        VStack(spacing: 0) {
            // Figma 순서: 위(Secondary/취소) -> 아래(Primary/설정)
            
            // 1. Secondary Button (취소)
            if let secondaryText = secondaryButtonText {
                Divider()
                    .background(Color.black.opacity(0.1))
                
                Button(action: { secondaryAction?() }) {
                    Text(secondaryText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                }
            }
            
            // 2. Primary Button (설정으로 이동)
            Divider()
                .background(Color.black.opacity(0.1))
            
            Button(action: { primaryAction() }) {
                Text(primaryButtonText)
                    .font(.system(size: 17, weight: primaryButtonFontWeight))
                    .foregroundColor(primaryButtonTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
            }
        }
    }
}

// MARK: - Preview
struct CommonPopupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Case 1: Horizontal (Default)
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all)
                CommonPopupView(
                    title: "기록 중단",
                    message: "기록을 중단하시겠습니까?",
                    layoutType: .horizontal,
                    primaryButtonText: "계속 기록",
                    primaryAction: {},
                    secondaryButtonText: "중단",
                    secondaryAction: {}
                )
            }
            .previewDisplayName("Horizontal Style")
            
            // Case 2: Vertical (New)
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all)
                CommonPopupView(
                    title: "위치 서비스 불가",
                    message: "기기의 '설정 > 개인정보 보호'에서\n위치 서비스를 켜주세요.",
                    layoutType: .vertical,
                    primaryButtonText: "설정으로 이동",
                    primaryAction: {},
                    secondaryButtonText: "취소",
                    secondaryAction: {}
                )
            }
            .previewDisplayName("Vertical Style")
            
            // Case 3: Single Button (New)
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all)
                CommonPopupView(
                    title: "네트워크 연결 없음",
                    message: "네트워크 연결 상태를 확인해주세요.",
                    layoutType: .horizontal,
                    primaryButtonText: "확인",
                    primaryAction: {}
                    // secondaryButtonText 생략
                )
            }
            .previewDisplayName("Single Button Style")
            
            // Case 4: Destructive Style (New)
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all)
                CommonPopupView(
                    title: "낚시 기록 삭제",
                    message: "이 기록을 삭제하시겠습니까?",
                    layoutType: .horizontal,
                    primaryButtonText: "삭제",
                    primaryButtonTextColor: Color(hex: "FF3B30"), // Red
                    primaryButtonFontWeight: .regular, // Regular
                    primaryAction: {},
                    secondaryButtonText: "취소",
                    secondaryAction: {}
                )
            }
            .previewDisplayName("Destructive Style")
        }
    }
}
