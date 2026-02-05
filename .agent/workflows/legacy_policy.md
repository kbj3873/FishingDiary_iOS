---
description: 레거시 코드 및 수정 금지 파일 목록 정책
---

# Legacy Code Policy

이 문서는 마이그레이션 대상이거나 사용을 중단해야 할 레거시 파일들을 정의합니다. **이 파일들은 읽거나 수정하지 마세요.**

## 1. 절대 수정 금지 (Ignore List)

### Storyboards (Deprecated)
*   `Base.lproj/Main.storyboard`
*   `Base.lproj/Point.storyboard`
*   `SeaWaterTemperature.storyboard`

### ViewControllers (UIKit Legacy)
*   `MainViewController.swift`
*   `OceanSelectViewController.swift`
*   `PointDateListViewController.swift`
*   `PointDataListViewController.swift`
*   `PointMapViewController.swift`
*   `SeaWaterTemperatureViewController.swift`

### Cells & Utils
*   `TempuratureCell.swift`, `OceanSelectCell.swift` 등 UITableViewCell 전반.
*   `StoryboardInstantiable.swift`

## 2. 예외 (유지되는 UIKit)
다음 파일들은 SwiftUI 연동을 위해 **필요하므로 삭제하지 않습니다**:
*   `MainHostingViewController.swift` (Bridge)
*   `Kakao...ViewController.swift` (SDK Wrapper)

## 3. 작업 원칙
*   새 기능은 무조건 **SwiftUI**로 작성합니다.
*   기존 ViewController를 수정해야 할 경우, 해당 기능을 **SwiftUI View로 재작성**하는 것을 우선합니다.
