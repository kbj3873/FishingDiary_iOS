---
description: Figma 디자인을 분석하여 SwiftUI 코드로 변환하고, 에셋을 추출하며 템플릿 기반으로 기능을 구현하는 통합 워크플로우
---

# Feature Development & Figma to SwiftUI Workflow

이 워크플로우는 Figma 디자인을 의도에 맞게 SwiftUI 코드로 변환하고, 필요한 벡터(SVG) 아이콘을 프로젝트에 자동 변환/추가하며, 템플릿을 통해 기능 구현을 시작하는 통합 파이프라인입니다.

## 1. 사전 분석 (Preparation)

작업을 시작하기 전 아래 사항들을 먼저 확인합니다.

1.  **디자인 분석**: 구현할 디자인의 주요 화면 구성 요소(리스트, 버튼, 탭 등)와 로직을 파악합니다.
2.  **구조 확인**: `project_structure.md`를 읽고, 재사용 가능한 기존 컴포넌트나 연관된 도메인 엔티티가 있는지 확인합니다.
3.  **레거시 확인**: `legacy_ignore.md` (레거시 정책)를 확인하여 건드리지 말아야 할 구 파일들을 파악합니다.

## 2. SwiftUI 템플릿 기반 코드 생성 (Implementation)

새로운 화면(Scene)이나 기능을 만들 때 아래 템플릿을 사용하여 기본 뼈대를 잡습니다.
**주의**: 새로운 Swift 파일을 생성하는 경우, 해당 파일이 Xcode 프로젝트(`project.pbxproj`)에 포함되어야 빌드가 가능합니다. 가능하면 사용자에게 파일 추가를 먼저 요청하거나 스크립트 기반의 자동 등록을 고려합니다.

### SwiftUI View 템플릿
```swift
struct {ScreenName}View: View {
    @StateObject var viewModel: {ScreenName}ViewModel

    var body: some View {
        ZStack {
            // 1. 배경 (Safe Area 무시)
            backgroundView.ignoresSafeArea()
            
            // 2. 콘텐츠 (Safe Area 준수)
            contentView
        }
        .navigationTitle("{Title}")
        .onAppear { viewModel.onAppear() }
    }

    private var backgroundView: some View { Color.white }
    private var contentView: some View {
        VStack(spacing: 16) { /* Content */ }
    }
}
```

### ViewModel 템플릿
```swift
final class {ScreenName}ViewModel: ObservableObject {
    @Published var state: ViewState = .idle // 상태 관리
    private let useCase: {Feature}UseCase

    init(useCase: {Feature}UseCase) {
        self.useCase = useCase
    }

    func onAppear() { /* Load Data */ }
}
```

## 3. SwiftUI 변환 규칙 (UI/Layout/Style)

Figma 디자인을 디테일하게 코드로 옮길 때 다음의 변환 규칙을 따릅니다.

### 무시해야 할 시스템 UI 및 Safe Area
- **iOS 시스템 UI 무시**: 상태바(시간, 배터리), 홈 인디케이터(하단 스와이프 바), 노치/다이나믹 아일랜드 영역은 iOS가 자동으로 처리하므로 직접 구현하지 않습니다.
- **Safe Area 처리**:
  - 상태바 및 홈 인디케이터 영역까지 색상/이미지가 덮여야 할 경우 `.ignoresSafeArea()` 적용.
  - 콘텐츠는 기본적으로 Safe Area 내부에 배치하여 시스템 UI와 겹치지 않도록 합니다.

### 레이아웃 및 뷰 계층 구조
- **기본 구조**: 배경 레이어와 콘텐츠 레이어를 `ZStack`으로 분리합니다.
- **Figma 매핑 규칙**:
  - `Frame (vertical)` → `VStack`
  - `Frame (horizontal)` → `HStack`
  - 절대 좌표 (X/Y) → `ZStack` 및 `.offset()` 혹은 `.position()` 지양
  - 제약조건(Constraints) → `GeometryReader` 또는 Alignment 속성 조정

### 색상 폰트 및 기타 규칙
- **색상**: Figma의 그라디언트는 SwiftUI의 `LinearGradient`로, 단일 색상은 `Color(hex: "...")` 형태로 변환합니다. (예: SeaThermo Primary Blue `#4FACFE`)
- **폰트**: 시스템 폰트는 `.font(.system(size:weight:))`, 커스텀 폰트는 `.font(.custom("FontName", size:))`을 사용합니다.
- **언어 및 소통**: 모든 작업 관련 문서(`task.md`, `implementation_plan.md` 등), **`task_boundary` 도구의 인자(`TaskName`, `TaskSummary`, `TaskStatus`)**, 그리고 사용자 소통은 모두 **한국어**로 작성하는 것을 원칙으로 합니다.

## 4. Asset 추출 및 추가 (Vector to PNG)

프로젝트 이미지 리소스는 @2x, @3x 해상도의 투명한 PNG를 사용합니다.

### Step A: Figma에서 Asset (SVG) 수집 및 검증
1. Figma에서 필요한 아이콘 노드(Node)를 선택해 SVG 코드를 추출합니다.
2. SVG 코드가 배경이 투명(`fill="none"`)하고 의도한 형태를 띄고 있는지 시각적/코드 레벨에서 검증합니다.

### Step B: Assets.xcassets 폴더 구성
1. `SeaThermo/Assets.xcassets/` 하위에서 성격에 맞는 카테고리(예: `FishingRecord`, `History`)를 선택하거나, 불분명하다면 사용자에게 문의합니다.
2. 카테고리 내에 `[asset_name].imageset` 폴더를 만들고, 추출한 데이터를 `[asset_name].svg`로 저장합니다. 
   - 에셋 이름은 스네이크 케이스(`snake_case`) 필수 사용 (예: `ic_new_icon`).
   - 단색 템플릿 아이콘 방식이 경우, `template-rendering-intent: template`으로 사용할 것을 고려합니다.

### Step C: 변환 스크립트 실행 (`convert_to_png.sh`)
1. `.agent/workflows/convert_to_png.sh` 파일을 엽니다.
2. 파일 하단에 새로운 변환 명령을 추가합니다:
   ```bash
   # 사용법: convert_and_update "[Category]" "[Asset_Name]" [Width] [Height]
   # Height 생략 시 Width와 1:1 비율 간주
   convert_and_update "History" "ic_new_icon" 24
   ```
3. 터미널 스크립트 실행 (프로젝트 루트 위치 기준):
   ```bash
   ./.agent/workflows/convert_to_png.sh
   ```
   - 스크립트가 `@2x`, `@3x` 해상도로 PNG를 자동 생성하고 Xcode가 인식하도록 `Contents.json`을 작성합니다.
   - 용량 최적화를 위해 원본 `.svg` 파일은 자동 삭제됩니다.

### Step D: 독립성 및 최종 검증
- 생성된 `.imageset` 폴더 내에 `.svg`가 삭제되었고 PNG 파일들과 `Contents.json`이 정상 구비되었는지 검증합니다.
- 추출한 에셋의 배경이 투명한지 확인합니다.
- SwiftUI 뷰(`Image("ic_new_icon")`)에서 이상 없이 렌더링되는지 확인하며, 기존 레거시 UIKit 코드(`ViewController`)와 불필요한 의존성 없이 독립적으로 화면이 동작하는지 테스트합니다.
