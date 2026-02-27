# Figma to SwiftUI 변환 규칙

이 파일은 Figma 디자인을 SwiftUI 코드로 변환할 때 자동으로 적용되는 규칙입니다.

## 무시해야 할 요소 (구현 대상 아님)

### iOS 시스템 UI
다음 요소들은 iOS가 자동으로 처리하므로 **구현하지 않음**:

- **iOS 상태바 (Status Bar)**: 시간, 신호 강도, Wi-Fi, 배터리 아이콘
- **홈 인디케이터 (Home Indicator)**: 하단 스와이프 바
- **노치 (Notch) / 다이나믹 아일랜드**: 상단 센서 영역

### Safe Area 처리
- 상태바 영역 → `.ignoresSafeArea(edges: .top)` 또는 safe area 내부 콘텐츠로 처리
- 홈 인디케이터 영역 → `.ignoresSafeArea(edges: .bottom)` 또는 safe area 내부 콘텐츠로 처리
- 전체 화면 배경 → `.ignoresSafeArea()` 적용

## 변환 규칙

### 1. 색상 (Colors)
```swift
// Figma 그라디언트 → SwiftUI LinearGradient
LinearGradient(
    colors: [Color(hex: "4FACFE"), Color(hex: "1E3C72")],
    startPoint: .top,
    endPoint: .bottom
)
```

### 2. 크기 및 위치
- Figma의 절대 좌표 → SwiftUI의 상대적 레이아웃으로 변환
- `left`, `top` 절대값 → `VStack`, `HStack`, `ZStack` + alignment/spacing
- 고정 크기가 필요한 경우만 `.frame(width:height:)` 사용

### 3. 이미지 에셋
- Figma localhost URL → Assets.xcassets에 추가
- 이미지 이름은 snake_case 사용 (예: `fish_temperature_icon`)
- **PNG 해상도: @2x, @3x만 생성 (@1x는 생성하지 않음)**
  - @2x: 기본 크기 × 2 (예: 24pt 아이콘 → 48px)
  - @3x: 기본 크기 × 3 (예: 24pt 아이콘 → 72px)
- Template Image로 사용할 아이콘은 `template-rendering-intent: template` 설정

### 4. 폰트
- Figma 시스템 폰트 → SwiftUI `.font(.system(size:weight:))`
- SF Pro → `.font(.system(...))`
- 커스텀 폰트 → `.font(.custom("FontName", size:))`

### 5. 레이아웃 변환 매핑
| Figma | SwiftUI |
|-------|---------|
| Frame (vertical) | VStack |
| Frame (horizontal) | HStack |
| Auto layout | Stack + spacing |
| Absolute position | ZStack + offset/position |
| Constraints | GeometryReader 또는 alignment |

## 코드 스타일

### 구조
```swift
struct ScreenNameView: View {
    var body: some View {
        ZStack {
            // 1. 배경 (safe area 무시)
            backgroundGradient
                .ignoresSafeArea()

            // 2. 콘텐츠 (safe area 내부)
            VStack {
                // 실제 UI 요소
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(...)
    }
}
```

### Preview
```swift
#Preview {
    ScreenNameView()
}
```

## 네이밍 규칙

- View 파일: `{화면명}View.swift`
- ViewModel: `{화면명}ViewModel.swift`
- 컴포넌트: `{기능명}Component.swift` 또는 `{기능명}View.swift`

## 프로젝트 특화 규칙

### SeaThermo 앱 컬러 팔레트
- Primary Blue: `#4FACFE`
- Deep Blue: `#1E3C72`
- Mid Blue: `#3979BE`

### 공통 컴포넌트 재사용
- 기존 `Presentation/` 폴더의 컴포넌트 확인 후 재사용
- 새 컴포넌트 생성 시 해당 Scene 폴더에 배치
