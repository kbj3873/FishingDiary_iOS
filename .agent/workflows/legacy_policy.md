# Legacy Code Policy

이 문서는 프로젝트 내의 레거시 코드와 그에 대한 정책을 정의합니다.
여기에 나열된 파일이나 클래스는 **수정하지 않고**, 신규 기능 개발 시 **사용을 지양**해야 합니다.

## Legacy Components

| 컴포넌트 | 파일 경로/이름 | 대체제 | 비고 |
|---|---|---|---|
| **Alert** | `FDAlertViewController` | `CommonPopupView` | UIKit 기반의 커스텀 Alert. SwiftUI 환경에서는 `CommonPopupView` 사용 권장. |
| **PointScene** | `Presentation/PointScene/*` | `SeaAnalysis` | 포인트 관련 구 기능. |
| **SeaWaterTemperature** | `Presentation/SeaWaterTemperature/*` | `SeaAnalysis` | 수온 관련 구 기능. |
| **Track** | `Presentation/Track/*` | - | 트랙킹 관련 구 기능. |

## Rules
1. 레거시 코드는 버그 수정 외에는 건드리지 않습니다.
2. 신규 기능은 SwiftUI와 Clean Architecture를 따릅니다.
