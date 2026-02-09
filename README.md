# 온바다 (SeaThermo)

**온바다(SeaThermo)**는 낚시 활동을 기록하고 추적하는 iOS 애플리케이션으로, 해양 데이터 통합 기능을 제공합니다. 한국 해양 API에서 실시간 해수 온도 정보를 가져오고, GPS 기반 낚시 위치 추적 및 듀얼 맵 지원(Apple Maps와 Kakao Maps)을 제공합니다.

## 주요 기능

*   **해양 데이터 통합**: 실시간 해수 온도 및 해양 정보 확인
*   **낚시 기록**: 낚시 위치, 조과, 날씨 등 상세 기록 저장
*   **위치 추적**: GPS 기반 이동 경로 추적 및 저장
*   **듀얼 맵**: Apple Maps와 Kakao Maps 선택 지원

## 개발자 가이드

이 프로젝트의 개발 규칙, 아키텍처, 워크플로우에 대한 자세한 내용은 [CLAUDE.md](CLAUDE.md)를 참조하세요.

### 필수 확인 문서

*   [기능 개발 워크플로우](.agent/workflows/develop_feature.md)
*   [한국어 사용 규칙](.agent/workflows/korean_language.md)
*   [프로젝트 구조](.agent/workflows/project_structure.md)
*   [레거시 정책](.agent/workflows/legacy_policy.md)

## 기술 스택

*   **Platform**: iOS 13.0+
*   **Language**: Swift
*   **UI Framework**: SwiftUI (Primary), UIKit (Legacy/Hybrid)
*   **Architecture**: Clean Architecture + MVVM
*   **Dependency Manager**: CocoaPods