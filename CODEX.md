# CODEX.md

이 문서는 Codex가 SeaThermo iOS 저장소에서 작업할 때 우선 참고하는 최신 작업 가이드입니다. `CLAUDE.md`는 과거 작업 맥락으로 보존하되, 내용이 충돌하면 실제 코드와 이 문서를 우선합니다.

## 기본 원칙

- 사용자와의 소통, 작업 요약, 문서 작성은 한국어로 한다.
- 작업 전에는 요청과 관련된 파일을 먼저 읽고, 기존 구조와 스타일에 맞춰 최소 범위로 수정한다.
- 사용자가 명시하지 않은 리팩토링, 포맷 변경, 파일 이동은 피한다.
- 기존 변경사항을 임의로 되돌리지 않는다.
- 빌드/테스트가 필요한 변경은 가능한 범위에서 직접 검증하고, 실행하지 못한 경우 이유를 남긴다.
- Swift 파일을 새로 만들면 Xcode target membership과 실제 빌드 포함 여부를 확인한다.

## 현재 프로젝트 사실

- 앱 이름: 온바다(SeaThermo)
- 플랫폼: iOS 16.0+
- 언어: Swift
- UI: SwiftUI 중심
- 일부 UIKit 브릿지 사용: `UIApplicationDelegate`, `UIViewRepresentable`, `UIViewControllerRepresentable`, `WKWebView`, `MKMapView`, Kakao Maps
- 아키텍처: Clean Architecture + MVVM
- 의존성 관리: CocoaPods
- 반드시 사용할 Xcode workspace: `SeaThermo.xcworkspace`

## 배포/빌드 모드

이 저장소는 공개 배포용 앱과 내부/개인용 앱을 하나의 코드베이스에서 관리한다. 장기 브랜치를 `public`/`private`로 나누지 않고 target, scheme, build configuration, compile flag로 분기한다.

| Scheme | 용도 | Bundle ID | 빌드 플래그 |
| --- | --- | --- | --- |
| `SeaThermo` | 공개 배포 | `com.onbada.seathermo` | 없음 |
| `SeaThermoInternal` | 내부/개인용 | `com.onbada.seathermo.internal` | `INTERNAL_BUILD` |

공개 빌드 기준:

- 현재수온은 공식 OpenAPI 기반 구현을 사용한다.
- 수온분석 탭은 준비중 화면을 표시한다.
- 국립수산과학원 서버 직접 호출 또는 온바다 내부 crawling용 화면이 노출되지 않아야 한다.
- 이미 알고 있는 데이터 권리/정책 리스크를 강제 업데이트로 회수하는 방식은 피한다.

내부 빌드 기준:

- 현재수온은 crawling/direct server 기반 구현을 사용한다.
- 앱 시작 시 `https://seathermo.com/api/regions` 호출이 필요하다.
- 수온분석 상세 화면은 내부용 전체 기능을 유지한다.
- iOS 내부 배포는 개인 개발자 계정 기준 Ad Hoc 배포가 현실적인 선택이다. TestFlight는 빌드별 90일 제한이 있다.

Android 참고:

- 공개 Android package name은 `com.onbada.seathermo`를 유지한다.
- Play Console 비공개 테스트 조건은 이미 통과한 앱이므로, 새 앱을 만들거나 package name을 바꾸지 않는다.
- 공개용 안전 빌드는 같은 앱/package name에 더 높은 `versionCode`로 새 AAB를 올리는 방향으로 진행한다.
- Android 인계용 문서는 `README_Android.md`, `CODEX_Android.md`를 참고한다.

## 빌드 명령

```bash
pod install
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

`SeaThermo.xcodeproj`를 직접 열거나 빌드 기준으로 삼지 않는다. 실기기 디버깅은 Xcode에서 `SeaThermo` 또는 `SeaThermoInternal` scheme을 선택하고 signing을 맞춘 뒤 실행한다. 두 target 모두 실행 가능해야 하며, internal만 실행 가능하게 고정하지 않는다.

## 레이어 구조

```text
Presentation
  -> SwiftUI View, ViewModel, 지도/WebView 브릿지
Domain
  -> Entity, Repository protocol, UseCase
Data
  -> Repository 구현체, DTO, Realm 저장소
Infrastructure
  -> Endpoint, NetworkService, WebView 설정
Application
  -> SeaThermoApp, AppConfiguration, DIContainer, AppBuildMode
Managers
  -> FDLocationManager, FDAppManager, MetricKitManager
```

Domain은 원칙적으로 Presentation/Data에 의존하지 않는다. 단, 현재 `PointMap.swift`에는 `MapKit`, `KakaoMapsSDK` 의존성이 남아 있으므로 지도 관련 수정 시 경계를 의식한다.

## 주요 파일 역할

- `SeaThermo/Application/SeaThermoApp.swift`: 앱 진입점, Firebase/MetricKit 초기화, splash/onboarding/main 라우팅
- `SeaThermo/Application/AppBuildMode.swift`: `INTERNAL_BUILD` 기반 앱 빌드 모드 식별
- `SeaThermo/Application/AppConfiguration.swift`: `Info.plist` 기반 API URL/키 로드
- `SeaThermo/Application/DIContainer/ApplicationDIContainer.swift`: NetworkService, Repository, UseCase, ViewModel 생성
- `SeaThermo/Infrastructure/Network/Endpoint.swift`: 요청 생성
- `SeaThermo/Infrastructure/Network/NetworkService.swift`: URLSession 기반 async 네트워크 실행
- `SeaThermo/Data/Network/APIEndpoints.swift`: NIFS/온바다 API endpoint와 header 정의
- `SeaThermo/Data/PersistentStorages/RealmStorage/RealmManager.swift`: Realm 설정과 migration
- `SeaThermo/Managers/FDLocationManager.swift`: 위치 권한, 모니터링, 트래킹, 위치 스트림
- `SeaThermo/Managers/FDAppManager.swift`: 지도 타입, 기록 상태, 속도 임계값

## 화면 구조

- `Presentation/MainTab/MainTabView.swift`: 5개 탭 구성과 공개/내부 화면 분기
- `Presentation/Splash`: 버전 체크, 관측소 목록 캐싱
- `Presentation/Onboarding`: 최초 실행 가이드
- `Presentation/CurrentTemperature`: 즐겨찾기 현재수온
- `Presentation/SeaAnalysis`: 해역/관측소 선택과 주간 수온 차트
- `Presentation/FishingRecord`: 지도 기반 낚시 기록, 사진 저장, 상태/시작/종료 마커
- `Presentation/History`: 세션별 기록 목록, 상세 지도, 이미지 뷰어
- `Presentation/Setting`: 지도 타입 선택, 공지/라이선스 WebView

## 현재수온/관측소 분기

공개 빌드:

- 사용자 지정 OpenAPI 기반 `CurrentTemperatureView`, `OceanSelectView`, `CurrentTemperatureViewModel`, `OceanSelectViewModel`을 사용한다.
- 공개 배포에 내부 crawling/direct server UI가 노출되지 않아야 한다.

내부 빌드:

- crawling/direct server 기반 현재수온 화면과 ViewModel을 사용한다.
- 앱 시작 시 `/api/regions` 호출이 필요하다.
- 현재수온 지역 선택 시트는 `F2F2F7` 배경 위에 흰색 관측소 셀을 배치한다.
- 이 분기는 `SplashViewModel`의 `INTERNAL_BUILD` 조건과 `MainTabView`의 화면 선택을 함께 확인한다.
- 사용자가 직접 고친 `/api/regions` 조건을 임의로 다시 뒤집지 않는다.

## 수온분석 분기

공개 빌드:

- `#if !INTERNAL_BUILD` 기준으로 수온분석 탭은 준비중 화면을 표시한다.
- 히스토리 빈 상태와 같은 톤의 아이콘/문구를 사용한다.
- 취지 문구는 “수온 분석 서비스는 준비 중입니다”이다.

내부 빌드:

- 기존 수온분석 목록/상세 화면을 그대로 제공한다.
- 관측소 리스트 시트는 `F2F2F7` 배경 위에 흰색 관측소 셀을 배치한다.
- 상세 화면의 최근 7일 그래프는 아래 기준을 따른다.

## 내부 수온분석 상세 그래프 기준

선택 UI:

- `"최근 7일 수온 변화"` 오른쪽에 드롭다운 메뉴를 둔다.
- 선택 항목은 `날짜별`, `12시간`, `6시간`, `3시간`이다.
- subtitle은 선택 기준에 맞춰 바꾼다.
  - 날짜별: `일별 수온 추이 분석`
  - 12시간: `12시간 단위 수온 추이 분석`
  - 6시간: `6시간 단위 수온 추이 분석`
  - 3시간: `3시간 단위 수온 추이 분석`

데이터/축 처리:

- 기존 7일 수온 데이터는 30분 단위 샘플을 유지한다.
- 기준 변경은 데이터를 다시 호출하거나 라인 데이터를 줄이는 기능이 아니다.
- 표층/중층/저층 라인은 모든 30분 샘플을 그대로 사용한다.
- 선택 기준은 x축 세로선과 하단 라벨 tick 간격만 바꾼다.
- 날짜별은 기존 카드 폭에서 표시하고 가로 스크롤하지 않는다.
- `12시간`, `6시간`, `3시간`은 가로 스크롤 처리한다.
- `3시간` 기준이 가장 넓은 스크롤 범위를 가진다.

x축 라벨:

- 날짜별은 날짜만 표시한다. 예: `6/2`, `6/3`
- 시간별은 `00시` tick에서만 날짜를 함께 표시한다. 예: `6/8\n00시`
- 시간별의 나머지 tick은 시간만 표시한다. 예: `03시`, `06시`, `12시`
- 시간별은 현재 시각 이후라도 같은 날짜의 바로 다음 tick 세로선/라벨까지 표시한다. 예: `20:49` 기준 `21시`
- 시간별 스크롤 첫 라벨은 왼쪽에서 잘리지 않게 보정하되, 너무 오른쪽으로 밀지 않는다.
- 날짜별은 스크롤뷰가 아니므로 첫 라벨 위치 보정을 적용하지 않는다.

y축/스크롤:

- 시간별 그래프를 오른쪽으로 스크롤해도 왼쪽 온도 라벨은 고정되어야 한다.
- 구현 구조는 `고정 y축 영역 + 스크롤되는 plot 영역`을 우선한다.
- 온도 라벨과 그래프 첫 세로선 사이 가로 간격은 0에 가깝게 맞춘다.
- `20.0` 같은 최상단 y축 라벨이 잘리지 않도록 상단 padding을 확보한다.

관련 파일:

- `SeaThermo/Presentation/SeaAnalysis/SeaAnalysisDetailView.swift`
- `SeaThermo/Presentation/SeaAnalysis/ViewModel/SeaAnalysisDetailViewModel.swift`
- `SeaThermo/Presentation/SeaAnalysis/Components/TemperatureLineGraphView.swift`

## 낚시기록 안내 팝업

- 낚시기록 탭 진입 시 안내 팝업을 표시한다.
- `FDUserDefault`의 `hideFishingRecordGuidePopup` 키로 다시 보지 않기를 저장한다.
- `CommonPopupView`를 확장해 accessory content를 넣는 방식으로 구현했다.
- body font가 너무 작지 않게 조정되어 있어야 한다.
- 안내 취지는 다음과 같다.

```text
낚시 기록은 워킹 루어 낚시나 보트 낚시처럼 이동하며 포인트를 탐색하는 상황에 최적화되어 있습니다.
기록 중 이동 경로와 상태 변화를 저장하고, 사진으로 조과를 남겨 히스토리에서 다시 확인할 수 있습니다.
```

## 낚시기록/히스토리 마커 규칙

마커 종류:

- 시작 마커: `ic_map_marker_start`
- 종료 마커: `ic_map_marker_end`
- 상태 마커: 탐색중/낚시중 pin 마커
- 사진 마커: 조과 사진 위치

표시 기준:

- 낚시기록 화면에서도 시작 마커가 노출되어야 한다.
- 기록 시작 시 시작 마커를 추가한다.
- 기록 종료 시 종료 마커를 추가한다.
- 히스토리 상세에서도 시작/종료 마커를 노출한다.
- Realm schema 변경 없이 세션 첫 record와 마지막 record에서 시작/종료 마커를 파생한다.

anchor 기준:

- 시작/종료 마커는 원형 이미지이므로 지도 좌표가 이미지 정중앙에 오도록 한다.
  - Apple/Kakao 공통 의도: `(0.5, 0.5)`
- 탐색중/낚시중 pin 마커는 pin 끝점 기준을 유지한다.
  - 의도: `(0.5, 1.0)`

종료 마커 좌표:

- 경로 라인의 마지막 좌표를 우선 사용한다.
- fallback은 current map line/current location/location manager latest 순서로 둔다.
- 종료 마커가 polyline 마지막 지점보다 앞에 찍히지 않는지 확인한다.

상태 마커 생성 규칙:

- 상태 마커는 `이동 중 -> 탐색 중`, `이동 중 -> 낚시 중` 전환에서만 생성한다.
- 시작 마커 직후 첫 상태가 탐색중/낚시중이라고 해서 강제로 상태 마커를 추가하지 않는다.
- `탐색중 -> 낚시중`, `낚시중 -> 탐색중`, `탐색/낚시 -> 이동중` 전환은 상태 마커로 세지 않는다.
- 히스토리 상세에서도 시작 record를 이전 상태로 사용하지 않는다. 첫 실제 위치 상태는 baseline으로만 저장하고 마커를 만들지 않는다.

히스토리 마커 탭 UI:

- 시작/종료 마커 탭 시 낚시중/탐색중 마커와 같은 하단 UI 구조를 재사용한다.
- 상태 마커 제목이 `지점 #n`이면 시작/종료는 다음으로 표시한다.
  - 시작: `낚시 시작`
  - 종료: `낚시 종료`
- 시작/종료에는 사진 썸네일이 없다.

히스토리 지점 수:

```text
시작 마커 1
+ 종료 마커 1, 단 record가 2개 이상일 때
+ 이동 중 -> 탐색/낚시 상태 마커 개수
+ 사진 마커 개수
```

목록과 상세의 지점 수 계산이 같아야 한다.

## 히스토리 상단 UI

- 상단 헤더의 뒤로 버튼, 날짜, 시간, 삭제 버튼 영역은 고정한다.
- 확장 상세 영역만 height animation으로 연다.
- fade in/out + move transition으로 헤더와 겹치게 만들지 않는다.
- 상세 영역에는 clipping을 적용한다.
- 조과 썸네일이 없는 경우, 조과 사진 섹션 위의 하단 구분선을 숨긴다.
- 중앙 날짜/시간/chevron 버튼이 좌우 버튼 레이어에 가려지지 않게 터치 영역과 z-order를 확인한다.

## 데이터 흐름

### 수온/관측소

```text
View
  -> ViewModel
  -> OceanUseCase
  -> OceanRepository
  -> DefaultOceanRepository
  -> APIEndpoints + NetworkService
  -> DTO.toDomain()
```

내부 빌드는 스플래시에서 온바다 서버의 관측소 목록을 받아 `UserDefaultKey.allRegionList`에 캐싱한다. 현재수온 즐겨찾기는 `UserDefaultKey.crawlingFavoriteRegions`를 사용한다.

### 낚시 기록

```text
FDLocationManager
  -> FishingRecordViewModel
  -> FishingRecordUseCase
  -> DefaultFishingRecordRepository
  -> RealmFishingRecord + Documents image files
```

위치 포인트와 사진 마커는 같은 Realm 모델에 저장된다. 한 번의 낚시 기록은 `sessionId`로 묶는다.

## 지도 작업 주의사항

- Apple Map 기록 화면: `RecordMapView`
- Kakao Map 기록 화면: `RecordKakaoMapView`, `RecordKakaoMapViewController`
- Apple Map 히스토리: `HistoryMapView`
- Kakao Map 히스토리: `HistoryKakaoMapView`, `HistoryKakaoMapViewController`
- 지도 타입은 `UserDefaultKey.mapType`과 `FDAppManager.mapTp`를 함께 확인한다.
- 앱 최초 설치 시 기본 지도 타입은 코드의 UserDefaults 기본값과 `FDAppManager.mapTp` 초기값을 함께 확인한다.
- 기록 중 지도 타입 변경은 설정 화면에서 막고 있다.
- 백그라운드 복귀, cleanup, delegate 해제, marker/style 정리는 지도 메모리 문제와 직접 관련된다.

## 저장소/캐시

- Realm schema version은 `RealmManager.databaseVersion`에서 관리한다.
- 사진은 Documents directory에 jpg 파일로 저장하고, Realm에는 파일명/경로를 저장한다.
- UserDefaults list 저장/조회는 `UserDefaults.setToList`, `getFromList` extension을 사용한다.
- UserDefaults key는 `Common/Utils/FDUserDefault.swift`에 정의되어 있다.

## API/환경 값

`Info.plist`에는 build setting placeholder가 들어간다.

- `ApiKeyRisa`
- `ApiNifsURL`
- `ApiOnbadaURL`
- `KAKAO_APP_KEY`

릴리즈 작업에서는 다음을 함께 확인한다.

- `MARKETING_VERSION`
- `CURRENT_PROJECT_VERSION`
- `PRODUCT_BUNDLE_IDENTIFIER`
- `DEVELOPMENT_TEAM`
- `GoogleService-Info.plist`
- 위치/카메라/사진 권한 문구
- background location mode

## Figma/UI 작업

Figma 기반 화면 구현 또는 에셋 추가 요청이 있으면 `.agent/workflows/figma_to_swiftui_workflow.md`를 참고한다. 새 이미지 에셋은 기존 `Assets.xcassets` 카테고리 구조와 네이밍을 따른다.

SwiftUI UI 수정 시 다음을 특히 확인한다.

- 화면별 기존 spacing, radius, font weight를 유지한다.
- compact panel 안에 hero급 폰트를 쓰지 않는다.
- 버튼/라벨 텍스트가 작은 화면에서 겹치거나 잘리지 않는지 확인한다.
- 상태별 empty view나 popup은 기존 공통 컴포넌트를 먼저 확장한다.

## Android 인계 문서

- `README_Android.md`: Android 저장소 루트에 가져갈 README 초안
- `CODEX_Android.md`: Android 작업자가 iOS 변경사항을 따라 구현하기 위한 상세 가이드

Android 작업을 시작하면 Android 저장소의 `CLAUDE.md`, Gradle 구조, 실제 파일명을 먼저 확인하고, iOS 파일명을 그대로 가정하지 않는다.

## 커밋 메시지

커밋 메시지를 요청받으면 `.agent/workflows/commit_message.md` 규칙을 따른다. 사용자가 별도 규칙을 주면 사용자 지시를 우선한다.

## 알려진 문서 불일치

- `CLAUDE.md`에는 순수 SwiftUI/레거시 UIKit 제거라고 되어 있으나, 실제 코드는 지도/WebView/Firebase 초기화에 UIKit 브릿지를 사용한다.
- `.agent/workflows` 안에 과거 문서에서 언급된 일부 파일은 현재 존재하지 않을 수 있다.
