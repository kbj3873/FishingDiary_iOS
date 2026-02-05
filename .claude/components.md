# 컴포넌트 인덱스

현재 프로젝트에서 사용 중인 SwiftUI 컴포넌트 목록입니다.
새 기능 개발 전 이 목록을 확인하여 재사용 가능한 컴포넌트를 파악하세요.

## SwiftUI View 목록

### Main Scene

| View | 경로 | 용도 |
|------|-----|------|
| `MainView` | `Presentation/Main/MainView.swift` | 메인 화면 (수온 리스트 + 버튼) |
| `OceanSelectView` | `Presentation/Main/OceanSelectView.swift` | 해양 측정소 선택 |
| `MainHostingViewController` | `Presentation/Main/MainHostingViewController.swift` | UIKit 브릿지 |

### Point Scene

| View | 경로 | 용도 |
|------|-----|------|
| `PointDateListUIView` | `Presentation/PointScene/Point/PointDateListUIView.swift` | 포인트 날짜 목록 |
| `PointDataListUIView` | `Presentation/PointScene/Point/PointDataListUIView.swift` | 포인트 데이터 목록 |
| `ApplePointMapView` | `Presentation/PointScene/Map/ApplePointMapView.swift` | Apple Maps 포인트 지도 |
| `KakaoPointMapView` | `Presentation/PointScene/Map/KakaoPointMapView.swift` | Kakao Maps 포인트 지도 |
| `PointInfoView` | `Presentation/PointScene/Map/PointInfoView.swift` | 포인트 정보 팝업 패널 |

### Track Scene

| View | 경로 | 용도 |
|------|-----|------|
| `AppleTrackMapView` | `Presentation/Track/AppleTrackMapView.swift` | Apple Maps 트랙 추적 |
| `KakaoTrackMapView` | `Presentation/Track/KakaoTrackMapView.swift` | Kakao Maps 트랙 추적 |

### Sea Water Temperature Scene

| View | 경로 | 용도 |
|------|-----|------|
| `SeaWaterTemperatureView` | `Presentation/SeaWaterTemperature/SeaWaterTemperatureView.swift` | 해수 온도 상세/그래프 |

---

## UIKit Representable (UIKit → SwiftUI 래퍼)

| Representable | 래핑 대상 | 용도 |
|--------------|----------|------|
| `AppleMapViewRepresentable` | `MKMapView` | Apple Maps 통합 |
| `AppleTrackMapViewRepresentable` | `MKMapView` | Apple Maps 트랙 |
| `KakaoMapViewControllerRepresentable` | `KakaoPointMapViewController` | Kakao Maps 포인트 |
| `KakaoTrackMapViewControllerRepresentable` | `KakaoTrackMapViewController` | Kakao Maps 트랙 |

---

## ViewModel 목록

### @Published 속성 요약

| ViewModel | @Published 속성 | 용도 |
|-----------|----------------|------|
| `MainViewModel` | `oceanStations`, `selectedMapType` | 수온 리스트, 지도 타입 |
| `OceanSelectViewModel` | `oceanStations` | 측정소 리스트 |
| `PointDateListViewModel` | `pointDateList` | 날짜 목록 |
| `PointDataListViewModel` | `pointDataList`, `isShowingPointMap` | 데이터 목록, 지도 표시 |
| `PointMapViewModel` | `region`, `mapPins`, `polyLines`, `isLoaded` | Apple Maps 상태 |
| `KakaoPointMapViewModel` | `mapPins`, `polyLines`, `isLoaded` | Kakao Maps 상태 |
| `TrackMapViewModel` | `mapLine`, `currentSpeed`, `currentLatitude`, `currentLongitude`, `isTracking` | 트랙 추적 |
| `KakaoTrackMapViewModel` | `mapLine`, `currentSpeed`, `isTracking` | Kakao 트랙 추적 |
| `SeaWaterTemperatureViewModel` | `tempuratureItems`, `isLoading` | 온도 데이터 |

---

## 재사용 가능 컴포넌트

### 지도 관련

```swift
// Apple Maps 포인트 표시
AppleMapViewRepresentable(
    region: $viewModel.region,
    polylines: $viewModel.polyLines,
    annotations: $viewModel.mapPins,
    selectedAnnotation: $selectedPin,
    shouldCleanup: $shouldCleanup
)

// Kakao Maps 포인트 표시
KakaoMapViewControllerRepresentable(
    viewModel: viewModel,
    selectedPin: $selectedPin,
    shouldCleanup: $shouldCleanup
)
```

### 포인트 정보 팝업

```swift
// 지도 위 포인트 정보 표시
PointInfoView(
    locationData: pin.locationData,
    dmsType: dmsType,
    onDismiss: { selectedPin = nil }
)
```

---

## 공통 패턴

### 듀얼 맵 지원

```swift
@ViewBuilder
var mapView: some View {
    if FDAppManager.shared.mapTp == .AppleMap {
        ApplePointMapView(viewModel: appleViewModel)
    } else {
        KakaoPointMapView(viewModel: kakaoViewModel)
    }
}
```

### DI Container에서 ViewModel 생성

```swift
let container: PointSceneDIContainer = AppDIContainer.shared.resolve()
let viewModel = container.makeMainViewModel(actions: actions)
```

### NavigationLink 화면 전환

```swift
NavigationLink {
    viewModel.createOceanSelectView()
} label: {
    Text("수온 즐겨찾기")
}
```

---

## 화면 흐름

```
MainView
├── OceanSelectView (수온 즐겨찾기)
├── SeaWaterTemperatureView (수온 상세)
├── PointDateListUIView (포인트)
│   └── PointDataListUIView
│       └── ApplePointMapView / KakaoPointMapView
│           └── PointInfoView (overlay)
└── AppleTrackMapView / KakaoTrackMapView (트랙)
```
