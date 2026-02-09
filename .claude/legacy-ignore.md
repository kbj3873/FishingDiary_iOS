# 레거시 파일 및 폴더 목록 (읽기 전용)

이 파일에 나열된 대상들은 **레거시 코드**입니다. 신규 기능 개발 시 이들을 수정하지 말고, 새로운 SwiftUI 뷰와 로직을 생성하세요.

## 📁 레거시 폴더 (Presentation)

다음 폴더 하위의 모든 파일은 레거시입니다.

| 폴더 | 설명 | 대체 방향 |
|-----|-----|---------|
| `Presentation/PointScene/` | 포인트 목록, 지도(Apple/Kakao) | 신규 모듈로 재개발 권장 |
| `Presentation/SeaWaterTemperature/` | 수온 상세 화면 | `SeaAnalysis` 모듈로 대체됨 |
| `Presentation/Track/` | 트랙 추적 관련 | 신규 모듈로 재개발 권장 |

## 📄 기타 레거시 파일

| 파일 | 상태 | 비고 |
|-----|------|------|
| `Base.lproj/Main.storyboard` | 미사용 | SwiftUI MainView로 대체됨 |
| `Base.lproj/Point.storyboard` | 미사용 | |
| `Main/MainViewController.swift` | 삭제 예정 | |
| `Main/OceanSelectViewController.swift` | 삭제 예정 | |

## ⚠️ 주의사항

1. **폴더 전체가 레거시**: 위 나열된 폴더 내부의 코드는 버그 수정이라도 가급적 신규 모듈로 이관하여 처리하세요.
2. **참조 가능**: 로직 파악을 위해 코드를 읽는 것은 허용됩니다.
3. **의존성 주의**: 신규 코드에서 레거시 코드를 import하거나 상속받지 않도록 주의하세요.
