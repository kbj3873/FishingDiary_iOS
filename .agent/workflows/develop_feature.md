---
description: Figma 디자인을 SwiftUI로 구현하는 표준 워크플로우 (템플릿 및 스타일 규칙 포함)
---

# Feature Development Workflow

이 워크플로우는 Figma 디자인을 SwiftUI로 변환하고 기능을 구현할 때 따르는 표준 절차입니다.

## 1. 사전 분석 (Preparation)

1.  **디자인 분석**: 구현할 디자인의 주요 구성 요소(리스트, 버튼, 탭 등)를 파악합니다.
2.  **구조 확인**: `project_structure.md`를 읽고 재사용 가능한 컴포넌트나 연관된 도메인 엔티티가 있는지 확인합니다.
3.  **레거시 확인**: `legacy_policy.md`를 확인하여 건드리지 말아야 할 파일들을 파악합니다.

## 2. 템플릿 기반 코드 생성 (Implementation)

새로운 View와 ViewModel 생성 시 아래 템플릿을 사용하여 기본 구조를 잡습니다.

### Xcode 프로젝트 등록 및 파일 관리
*   새로운 Swift 파일을 생성하는 경우, 해당 파일이 Xcode 프로젝트(`project.pbxproj`)에 포함되어야 빌드가 가능합니다.
*   가능한 경우 `ruby` 스크립트(`xcodeproj` gem)를 활용하여 자동 등록을 시도합니다.
*   프로젝트 파일 수정이 위험하거나 복잡하다고 판단될 경우, **사용자에게 파일 추가를 요청**하여 안전하게 진행합니다.

### SwiftUI View 템플릿
```swift
struct {ScreenName}View: View {
    @ObservedObject var viewModel: {ScreenName}ViewModel

    var body: some View {
        ZStack {
            // 배경 (safe area 무시)
            backgroundView.ignoresSafeArea()
            // 콘텐츠 (safe area 준수)
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

## 3. Figma to SwiftUI 변환 규칙 (Style)

디자인 디테일을 적용할 때 다음 규칙을 준수합니다.

*   **색상**: Hex 코드 대신 `Color(hex: "...")` 사용
*   **폰트**: 시스템 폰트 사용 시 `.font(.system(size:weight:))`, 커스텀은 `.font(.custom(...))`
*   **이미지**: `Assets.xcassets`에 `snake_case`로 저장 (@2x, @3x). 
*   **레이아웃**: 절대 좌표(`position`) 사용 지양 → `VStack`, `HStack`, `Spacer` 활용.
*   **언어**: 모든 작업 관련 문서(`task.md`, `implementation_plan.md`, `walkthrough.md` 등), **`task_boundary` 도구의 인자(`TaskName`, `TaskSummary`, `TaskStatus`)**, 그리고 사용자 소통은 모두 **한국어**로 작성합니다.

## 4. 검증 (Verification)

*   레거시 UIKit 코드(`ViewController` 등)와의 의존성 없이 독립적으로 동작하는지 확인합니다.
