# 온바다 (SeaThermo)

온바다(SeaThermo)는 낚시 활동을 기록하고 해양 수온 데이터를 확인하는 iOS 애플리케이션입니다. 한국 해양 관측 데이터와 자체 온바다 서버 API를 사용하며, GPS 기반 낚시 기록과 Apple Maps/Kakao Maps 지도 표시를 지원합니다.

## 주요 기능

- 실시간/최신 해수 온도 확인
- 즐겨찾기 관측소 기반 현재수온 목록
- 공개/내부 빌드별 현재수온 데이터 소스 분리
- 공개 빌드 수온분석 준비중 화면
- 내부 빌드 수온분석 상세 그래프
- GPS 기반 낚시 경로 기록
- 속도 기반 낚시 상태 분류: 이동 중, 탐색 중, 낚시 중
- 낚시기록 진입 안내 팝업과 다시 보지 않기
- 낚시 시작/종료 마커, 상태 전환 마커, 조과 사진 마커 표시
- 세션별 낚시 히스토리 조회와 지도 마커 선택 UI
- Apple Maps와 Kakao Maps 지도 타입 선택
- 앱 버전 체크, 공지사항, 오픈소스 라이선스 WebView

## 기술 스택

- Platform: iOS 16.0+
- Language: Swift
- UI: SwiftUI 중심, 지도/WebView 일부 UIKit 브릿지
- Architecture: Clean Architecture + MVVM
- Dependency Manager: CocoaPods
- Local Storage: RealmSwift, UserDefaults, Documents directory image files
- Maps: MapKit, KakaoMapsSDK
- Analytics/Diagnostics: Firebase Analytics, Crashlytics, Remote Config, MetricKit

## 프로젝트 구조

```text
SeaThermo/
  Application/        앱 진입점, 앱 설정, DI 컨테이너, 빌드 모드
  Domain/             Entity, Repository protocol, UseCase
  Data/               Repository 구현체, DTO, Realm 저장소
  Infrastructure/     NetworkService, Endpoint, WebView 설정
  Presentation/       SwiftUI 화면, ViewModel, 지도 브릿지 컴포넌트
  Managers/           위치 추적, 앱 전역 상태, MetricKit
  Common/             공통 컴포넌트, 유틸, extension
  Assets.xcassets/    앱 아이콘, 탭 아이콘, 지도/온보딩/히스토리 이미지
```

## 앱 시작 흐름

```text
SeaThermoApp
  -> SplashView
      -> 버전 체크
      -> 관측소 목록 캐싱
  -> OnboardingView 또는 MainTabView
  -> MainTabView
      -> 현재수온
      -> 수온분석
      -> 낚시기록
      -> 히스토리
      -> 설정
```

## 빌드 모드

이 저장소는 하나의 코드베이스에서 공개 배포용 앱과 내부용 앱을 함께 관리합니다.

| Scheme | 용도 | Bundle ID | 빌드 플래그 |
| --- | --- | --- | --- |
| `SeaThermo` | 공개 배포 | `com.onbada.seathermo` | 없음 |
| `SeaThermoInternal` | 내부/개인용 | `com.onbada.seathermo.internal` | `INTERNAL_BUILD` |

공개 빌드 동작:

- 현재수온은 공식 OpenAPI 기반 View/ViewModel을 사용합니다.
- 수온분석 탭은 준비중 화면을 표시합니다.
- 내부 crawling/direct server 화면이 노출되지 않아야 합니다.

내부 빌드 동작:

- 현재수온은 crawling/direct server 기반 View/ViewModel을 사용합니다.
- 앱 시작 시 `https://seathermo.com/api/regions` 호출이 필요합니다.
- 수온분석 상세 화면의 최근 7일 그래프를 `날짜별`, `12시간`, `6시간`, `3시간` 기준으로 볼 수 있습니다.

## 빌드 및 실행

이 프로젝트는 CocoaPods를 사용하므로 항상 `SeaThermo.xcworkspace`를 사용합니다. `SeaThermo.xcodeproj`를 직접 열거나 빌드 기준으로 삼지 않습니다.

```bash
pod install
open SeaThermo.xcworkspace
```

공개 빌드:

```bash
xcodebuild -workspace SeaThermo.xcworkspace \
  -scheme SeaThermo \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  CODE_SIGNING_ALLOWED=NO \
  build
```

내부 빌드:

```bash
xcodebuild -workspace SeaThermo.xcworkspace \
  -scheme SeaThermoInternal \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  CODE_SIGNING_ALLOWED=NO \
  build
```

실기기 디버깅 설치는 Xcode에서 원하는 scheme을 직접 선택하고 signing 설정을 맞춘 뒤 실행합니다. 두 scheme 모두 실행 가능해야 하며, internal만 실행 가능하게 고정하지 않습니다.

## 최근 반영된 구현 상태

- `MainTabView`에서 `INTERNAL_BUILD` 기준으로 현재수온/수온분석 화면을 분기합니다.
- 공개 빌드 수온분석 탭은 준비중 안내를 표시합니다.
- `CommonPopupView`를 확장해 낚시기록 안내 팝업과 다시 보지 않기 UI를 제공합니다.
- 낚시기록 화면과 히스토리 상세 지도에 시작/종료 마커를 표시합니다.
- 시작/종료 마커는 원형 asset 기준으로 중앙 anchor를 사용하고, 낚시중/탐색중 pin 마커는 기존 pin anchor를 유지합니다.
- 상태 마커는 `이동 중 -> 탐색 중`, `이동 중 -> 낚시 중` 전환에서만 생성합니다.
- 히스토리 상단 UI는 헤더 고정 + 상세 영역 accordion 방식으로 확장/축소합니다.
- 내부 수온분석 상세 그래프는 y축 온도 라벨을 고정하고, 시간 기준 그래프만 가로 스크롤합니다.
- 내부 수온분석 시간 기준 그래프는 당일 다음 tick 세로선/라벨까지 표시합니다.
- 내부 현재수온 지역 선택과 수온분석 관측소 리스트는 회색 배경 위에 흰색 셀을 표시합니다.

## 설정 값

앱 실행에 필요한 주요 설정은 `Info.plist` placeholder와 Xcode build settings를 통해 주입됩니다.

- `ApiKeyRisa`
- `ApiNifsURL`
- `ApiOnbadaURL`
- `KAKAO_APP_KEY`
- `GoogleService-Info.plist`

릴리즈 또는 환경 분리 작업 시 위 값과 signing 설정, bundle identifier, version/build number를 함께 확인해야 합니다.

## 주요 유지보수 포인트

- 빌드 분기: `SeaThermo/Application/AppBuildMode.swift`, `Presentation/MainTab/MainTabView.swift`, Xcode target/scheme 설정
- 현재수온/관측소: `SplashViewModel`, `DefaultOceanRepository`, OpenAPI/Crawling ViewModel, UserDefaults 캐시
- 수온분석: `SeaAnalysisView`, `SeaAnalysisDetailView`, `SeaAnalysisDetailViewModel`, `TemperatureLineGraphView`
- 낚시기록: `FDLocationManager`, `FishingRecordView`, `FishingRecordViewModel`, `DefaultFishingRecordRepository`, `RealmManager`
- 히스토리: `HistoryViewModel`, `HistoryDetailViewModel`, `HistoryDetailView`, `HistoryMapView`, `HistoryKakaoMapView`
- 지도: Apple Map은 `MKMapView` 브릿지, Kakao Map은 별도 `UIViewControllerRepresentable` 컨트롤러 중심
- 배포/진단: `SeaThermoApp`, `MetricKitManager`, Firebase 설정, Xcode build settings

## 작업 가이드 문서

- [CODEX.md](CODEX.md): Codex가 우선 참고할 최신 iOS 작업 가이드
- [CLAUDE.md](CLAUDE.md): 과거 Claude Code 작업용 문서. 유용한 배경은 있지만 실제 코드와 맞지 않는 내용이 있을 수 있음
- [README_Android.md](README_Android.md): Android 저장소로 가져갈 README 초안
- [CODEX_Android.md](CODEX_Android.md): Android 저장소로 가져갈 Codex 작업 가이드
- [.agent/workflows/figma_to_swiftui_workflow.md](.agent/workflows/figma_to_swiftui_workflow.md): Figma 기반 SwiftUI 구현/에셋 작업 참고
- [.agent/workflows/commit_message.md](.agent/workflows/commit_message.md): 커밋 메시지 규칙
- [.agent/workflows/work_log.md](.agent/workflows/work_log.md): 작업 로그 작성 규칙
