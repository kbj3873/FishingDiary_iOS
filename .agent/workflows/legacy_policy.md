---
description: 레거시 코드 및 수정 금지 파일 목록 정책
---

# Legacy Code Policy

이 문서는 마이그레이션 대상이거나 사용을 중단해야 할 레거시 파일들을 정의합니다. **이 파일들은 신규 개발 시 참조용으로만 사용하고, 직접 수정하지 마세요.**

## 1. 레거시 폴더 (Folder-level Legacy)

다음 폴더 내의 **모든 파일**은 레거시 코드로 간주됩니다. 기획서가 반영된 신규 기능은 이 폴더들이 아닌 새로운 구조(예: `SeaAnalysis`)에 작성해야 합니다.

### Presentation Layer
*   `Presentation/PointScene/**`
    *   포인트 날짜/데이터 목록, 지도(Apple/Kakao) 관련 구 구현체
*   `Presentation/SeaWaterTemperature/**`
    *   구 수온 정보 화면 (Storyboard 기반 포함)
*   `Presentation/Track/**`
    *   트랙 추적 화면 관련 구 구현체

## 2. 절대 수정 금지 (Ignore List)

### Storyboards (Deprecated)
*   `Base.lproj/Main.storyboard`
*   `Base.lproj/Point.storyboard`
*   `SeaWaterTemperature.storyboard`

### ViewControllers (UIKit Legacy)
*   `MainViewController.swift`
*   `OceanSelectViewController.swift`
*   `PointDateListViewController.swift`
*   ... (및 위 레거시 폴더 내의 모든 VC)

## 3. 예외 (유지되는 UIKit)
다음 파일들은 SwiftUI 연동을 위해 **필요하므로 삭제하지 않습니다**:
*   `MainHostingViewController.swift` (Bridge)
*   `Kakao...ViewController.swift` (SDK Wrapper - 단, 레거시 폴더 내에 있다면 신규 래퍼를 만드는 것을 권장)

## 4. 작업 원칙
*   새 기능은 무조건 **SwiftUI**로 작성합니다.
*   레거시 폴더의 코드를 수정해야 할 경우, 해당 기능을 **SwiftUI View로 재작성**하는 것을 원칙으로 합니다.
*   레거시 코드는 로직 파악을 위한 **참조용(Read-only)**으로만 취급합니다.
