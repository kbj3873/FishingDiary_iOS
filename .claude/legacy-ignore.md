# 레거시 파일 목록 (읽지 말 것)

이 파일에 나열된 파일들은 **레거시 UIKit 코드**로, SwiftUI 마이그레이션 후 삭제 예정입니다.
새 기능 개발 시 이 파일들을 참조하거나 수정하지 마세요.

## Storyboard 파일 (삭제 예정)

| 파일 | 상태 | 비고 |
|-----|------|------|
| `Base.lproj/Main.storyboard` | 미사용 | SwiftUI MainView로 대체됨 |
| `Base.lproj/Point.storyboard` | 미사용 | SwiftUI PointDateListUIView로 대체됨 |
| `Base.lproj/LaunchScreen.storyboard` | **사용중** | 런치 스크린은 Storyboard 필수 |
| `SeaWaterTemperature/SeaWaterTemperature.storyboard` | 미사용 | SwiftUI SeaWaterTemperatureView로 대체됨 |

## UIKit ViewController (삭제 예정)

| 파일 | 대체된 SwiftUI View |
|-----|-------------------|
| `Main/MainViewController.swift` | `MainView.swift` |
| `Main/OceanSelectViewController.swift` | `OceanSelectView.swift` |
| `PointScene/Point/PointDateListViewController.swift` | `PointDateListUIView.swift` |
| `PointScene/Point/PointDataListViewController.swift` | `PointDataListUIView.swift` |
| `PointScene/Map/PointMapViewController.swift` | `ApplePointMapView.swift` |
| `Track/TrackMapViewController.swift` | `AppleTrackMapView.swift` |
| `SeaWaterTemperature/SeaWaterTemperatureViewController.swift` | `SeaWaterTemperatureView.swift` |

## UIKit 전용 ViewController (유지)

다음 파일들은 UIViewControllerRepresentable로 래핑되어 **아직 필요**합니다:

| 파일 | 용도 |
|-----|------|
| `Main/MainHostingViewController.swift` | SwiftUI → UIKit 브릿지 (필수) |
| `PointScene/Map/KakaoPointMapViewController.swift` | Kakao Maps SDK 래핑 |
| `Track/KakaoTrackMapViewController.swift` | Kakao Maps SDK 래핑 |

## 레거시 Cell 파일 (삭제 예정)

| 파일 | 비고 |
|-----|------|
| `Main/Cells/TempuratureCell.swift` | UITableViewCell |
| `Main/Cells/OceanSelectCell.swift` | UITableViewCell |
| `PointScene/Point/Cells/PointDateCell.swift` | UITableViewCell |
| `PointScene/Point/Cells/PointDataCell.swift` | UITableViewCell |

## 레거시 ViewModel (점진적 교체 예정)

| 파일 | 상태 | 비고 |
|-----|------|------|
| `Main/ViewModel/TempuratureListItemViewModel.swift` | 병행 사용 | CurrentValueSubject 사용 |
| `Main/ViewModel/OceanSelectCellViewModel.swift` | 미사용 | |
| `PointScene/Point/ViewModel/PointDateListItemViewModel.swift` | 미사용 | |
| `PointScene/Point/ViewModel/PointDataListItemViewModel.swift` | 미사용 | |

## Utils (선택적 삭제)

| 파일 | 상태 |
|-----|------|
| `Utils/StoryboardInstantiable.swift` | Storyboard 삭제 시 함께 삭제 |
| `Utils/ToolbarPickerView.swift` | UIKit 기반, SwiftUI picker로 대체 가능 |

---

## 주의사항

1. **새 기능 개발 시**: 위 파일들을 참조하지 말고, 기존 SwiftUI 파일을 참조하세요
2. **버그 수정 시**: SwiftUI 버전에서 수정하세요 (레거시 파일 수정 불필요)
3. **코드 참조 시**: 동일 기능의 SwiftUI 버전이 있는지 먼저 확인하세요

## 삭제 순서 권장

```
1단계: Storyboard 파일 (Main, Point, SeaWaterTemperature)
2단계: ViewController 파일
3단계: Cell 파일
4단계: 레거시 ViewModel
5단계: Utils
```
