# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참고하는 가이드 문서입니다.

## 관련 문서

| 문서 | 용도 | 언제 참조 |
|-----|------|----------|
| [기능 개발 워크플로우](.agent/workflows/develop_feature.md) | Standard Workflow | 기능 구현 시작 시 **필수** |
| [한국어 사용 규칙](.agent/workflows/korean_language.md) | Language Rule | 모든 대화 및 주석 작성 시 |
| [프로젝트 구조](.agent/workflows/project_structure.md) | Domain & Context | 기존 컴포넌트/엔티티 확인 시 |
| [레거시 정책](.agent/workflows/legacy_policy.md) | Legacy Code Policy | **절대 수정 금지** 파일 확인 시 |
| [작업 로그 가이드](.agent/workflows/work_log.md) | Notion Work Log | 일일 작업 로그 기록 시 |
| [Figma 변환 규칙](.claude/figma-to-swiftui.md) | 상세 디자인 가이드 | (참고용) Figma 작업 시 |
| [Domain 요약](.claude/domain-summary.md) | 상세 도메인 지식 | (참고용) 도메인 로직 심화 |

## 프로젝트 개요

**온바다(SeaThermo)**는 낚시 활동을 기록하고 추적하는 iOS 애플리케이션으로, 해양 데이터 통합 기능을 제공합니다. 한국 해양 API에서 실시간 해수 온도 정보를 가져오고, GPS 기반 낚시 위치 추적 및 듀얼 맵 지원(Apple Maps와 Kakao Maps)을 제공합니다.

- **플랫폼:** iOS 13.0+
- **언어:** Swift
- **UI 프레임워크:** SwiftUI (1차 마이그레이션 완료)
- **아키텍처:** Clean Architecture + MVVM
- **의존성 관리:** CocoaPods
- **주요 워크스페이스:** `SeaThermo.xcworkspace` (.xcodeproj 아님)

## 현재 상태

SwiftUI 1차 마이그레이션이 완료되어 앱 실행 시 SwiftUI로 구성된 화면이 표시됩니다. 레거시 UIKit 코드(Storyboard, ViewController)는 아직 삭제되지 않았지만 실제 런타임에서는 사용되지 않습니다.

> [!WARNING]
> **Legacy Code**: `Presentation` 내부의 다음 폴더들은 레거시 코드로 분류됩니다. 신규 기능 개발 시 참조용으로만 사용하고 수정하지 마세요.
> - `PointScene/` (Data, Date, Map)
> - `SeaWaterTemperature/`
> - `Track/`
>
> **New Feature**: `SeaAnalysis` 모듈은 최신 SwiftUI 패턴으로 구현되었습니다.

## 빌드 명령어

```bash
# 의존성 설치 (클론 후 또는 Podfile 변경 시 필수)
pod install

# 프로젝트 열기 (항상 workspace 사용, xcodeproj 아님)
open SeaThermo.xcworkspace

# 커맨드 라인에서 빌드
xcodebuild -workspace SeaThermo.xcworkspace -scheme SeaThermo -configuration Debug build

# 클린 빌드
xcodebuild -workspace SeaThermo.xcworkspace -scheme SeaThermo clean build
```

## 애플리케이션 시작 흐름

```swift
AppDelegate.application(_:didFinishLaunchingWithOptions:)
  → appFlowCoordinator.startSwiftUI()  // SwiftUI 모드로 시작
  → PointFlowCoordinator.startSwiftUI()
  → MainHostingViewController (UIKit wrapper)
      → MainView (SwiftUI 진입점)
```

**핵심 파일:**
- `AppDelegate.swift`: `appFlowCoordinator.startSwiftUI()` 호출
- `AppFlowCoordinator.swift`: `startSwiftUI()` 메서드로 SwiftUI 흐름 시작
- `PointFlowCoordinator.swift`: `makeMainHostingViewController()` 생성 및 푸시
- `MainHostingViewController.swift`: SwiftUI → UIKit 브릿지
- `MainView.swift`: SwiftUI 메인 화면

## SwiftUI 아키텍처

### 화면 구성

현재 앱에서 실제로 사용되는 SwiftUI 화면들:

| 영역 | 화면 | SwiftUI View | 통합 방식 | 상태 |
|---|---|---|---|---|
| **Main** | 메인 탭 | `MainTabView.swift` | UIHostingController | Active |
| **Main** | 메인 홈 | `MainView.swift` | TabView Item | Active |
| **Main** | 해양 선택 | `OceanSelectView.swift` | NavigationLink | Active |
| **SeaAnalysis** | 수온 분석 홈 | `SeaAnalysisView.swift` | TabView Item | **New** |
| **SeaAnalysis** | 수온 상세 | `SeaAnalysisDetailView.swift` | NavigationLink | **New** |
| **FishingRecord** | 낚시 기록 | `FishingRecordView.swift` | TabView Item | Active |
| **History** | 조과 기록 목록 | `HistoryView.swift` | TabView Item | Active |
| **History** | 조과 상세 | `HistoryDetailView.swift` | NavigationLink | Active |
| **History** | 이미지 뷰어 | `HistoryImageViewer.swift` | FullScreenCover | Active |
| **Setting** | 설정 | `SettingView.swift` | TabView Item | Active |
| **Legacy** | 포인트 날짜 목록 | `PointDateListUIView.swift` | NavigationLink | **LEGACY** |
| **Legacy** | 포인트 데이터 목록 | `PointDataListUIView.swift` | NavigationLink | **LEGACY** |
| **Legacy** | 포인트 지도 (Apple) | `ApplePointMapView.swift` | UIViewRepresentable | **LEGACY** |
| **Legacy** | 포인트 지도 (Kakao) | `KakaoPointMapView.swift` | UIViewControllerRepresentable | **LEGACY** |
| **Legacy** | 트랙 추적 (Apple) | `AppleTrackMapView.swift` | UIViewRepresentable | **LEGACY** |
| **Legacy** | 트랙 추적 (Kakao) | `KakaoTrackMapView.swift` | UIViewControllerRepresentable | **LEGACY** |
| **Legacy** | 해수 온도 상세 | `SeaWaterTemperatureView.swift` | NavigationLink | **LEGACY** |
| **Legacy** | 포인트 정보 패널 | `PointInfoView.swift` | Overlay | **LEGACY** |

### UIKit → SwiftUI 브릿지 패턴

#### 1. UIHostingController (앱 진입점)

SwiftUI View를 UIKit NavigationController에 통합:

```swift
// MainHostingViewController.swift
class MainHostingViewController: UIViewController {
    private var viewModel: MainViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let swiftUIView = MainView(viewModel: self.viewModel)
        let hostingController = UIHostingController(rootView: swiftUIView)

        addChild(hostingController)
        self.view.addSubview(hostingController.view)
        // Auto Layout 설정
        hostingController.didMove(toParent: self)
    }

    static func create(with viewModel: MainViewModel) -> MainHostingViewController {
        let view = MainHostingViewController()
        view.viewModel = viewModel
        return view
    }
}
```

#### 2. UIViewRepresentable (Apple Maps)

Apple Maps의 `MKMapView`를 SwiftUI에 통합:

```swift
// AppleMapViewRepresentable.swift
struct AppleMapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var polylines: [MKPolyline]
    @Binding var annotations: [MapPin]
    @Binding var selectedAnnotation: MapPin?
    @Binding var shouldCleanup: Bool  // 메모리 정리 트리거

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false  // 성능 최적화
        mapView.isPitchEnabled = false
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if shouldCleanup {
            context.coordinator.cleanup()
            return
        }
        // Region, Polylines, Annotations 업데이트
    }

    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        uiView.delegate = nil
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        uiView.showsUserLocation = false
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        // Delegate 메서드 구현
    }
}
```

**사용 예시:**
```swift
// ApplePointMapView.swift
struct ApplePointMapView: View {
    @StateObject var viewModel: PointMapViewModel
    @State private var selectedPin: MapPin?
    @State private var shouldCleanupMap = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppleMapViewRepresentable(
                region: $viewModel.region,
                polylines: $viewModel.polyLines,
                annotations: $viewModel.mapPins,
                selectedAnnotation: $selectedPin,
                shouldCleanup: $shouldCleanupMap
            )

            if let pin = selectedPin {
                PointInfoView(locationData: pin.locationData, ...)
            }
        }
        .onDisappear {
            shouldCleanupMap = false  // 정리 트리거
        }
    }
}
```

#### 3. UIViewControllerRepresentable (Kakao Maps)

Kakao Maps의 UIViewController를 SwiftUI에 통합:

```swift
// KakaoMapViewControllerRepresentable.swift
struct KakaoMapViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: KakaoPointMapViewModel
    @Binding var selectedPin: KakaoMapPin?
    @Binding var shouldCleanup: Bool
    var onPinSelected: ((KakaoMapPin) -> Void)?

    func makeUIViewController(context: Context) -> KakaoPointMapViewController {
        let vc = KakaoPointMapViewController.create(with: viewModel)
        // 콜백 설정
        return vc
    }

    func updateUIViewController(_ uiViewController: KakaoPointMapViewController, context: Context) {
        if shouldCleanup {
            context.coordinator.cleanup()
        }
    }
}
```

### NavigationView 기반 화면 전환

SwiftUI에서는 `NavigationView`와 `NavigationLink`로 화면 전환:

```swift
// MainView.swift
NavigationView {
    VStack {
        // 수온 즐겨찾기
        NavigationLink {
            viewModel.createOceanSelectView()  // OceanSelectView 반환
        } label: {
            Text("수온 즐겨찾기")
        }

        // 수온 정보
        NavigationLink(destination: seaWaterTemperatureDestination,
                       isActive: $showOceanInfo) {
            EmptyView()
        }

        // 포인트
        NavigationLink(destination: viewModel.createPointDateListView(),
                       isActive: $showPoint) {
            EmptyView()
        }
    }
}
.navigationBarHidden(true)
```

### 듀얼 맵 지원

앱 실행 시 선택된 맵 타입(`FDAppManager.shared.mapType`)에 따라 조건부 렌더링:

```swift
// MainView.swift - ButtonListView
@ViewBuilder
private var trackMapDestination: some View {
    if FDAppManager.shared.mapTp == .AppleMap {
        if let viewModel = appleTrackMapViewModel {
            AppleTrackMapView(viewModel: viewModel)
        }
    } else {
        if let viewModel = kakaoTrackMapViewModel {
            KakaoTrackMapView(viewModel: viewModel)
        }
    }
}
```

**지도 타입 변경:**
```swift
// MainView.swift - MapSelectButtons
Button {
    viewModel.setMapType(.AppleMap)  // 또는 .KakaoMap
} label: {
    Text("Apple Map")
}
.tint(viewModel.selectedMapType == .AppleMap ? .white.opacity(0.3) : .clear)
```

## Clean Architecture 레이어

### 1. Domain 레이어 (`SeaThermo/Domain/`)

비즈니스 로직과 엔티티를 포함하는 가장 내부 레이어로, UI 프레임워크와 독립적입니다.

**구조:**
- `Entities/` - 순수 비즈니스 모델 (Ocean, PointMap, SeaInfo 등)
- `Interfaces/` - Repository 프로토콜 (데이터 접근 추상화)
- `UseCases/` - 비즈니스 로직 오케스트레이터

**주요 패턴:**
- 모든 Repository는 프로토콜 기반 (예: `OceanRepository`, `TrackMapRepository`)
- UseCase는 `UseCase` 프로토콜을 따르며 `execute()` 메서드 구현
- 비동기 작업 취소를 위해 `Cancellable?` 반환
- Request/Response 값 객체로 입출력 데이터 캡슐화

**예시:**
```swift
// Domain/Interfaces/OceanRepository.swift
protocol OceanRepository {
    func fetchTemperatureList(query: OceanQuery,
                            completion: @escaping (Result<OceanResponse, Error>) -> Void) -> Cancellable?
}

// Domain/UseCases/OceanUseCase.swift
class OceanUseCase {
    private let oceanRepository: OceanRepository

    func excuteRisaList(requestValue: RequestValue,
                       completion: @escaping (Result<Ocean, Error>) -> Void) -> Cancellable? {
        return oceanRepository.fetchTemperatureList(query: requestValue.query,
                                                    completion: completion)
    }
}
```

### 2. Data 레이어 (`SeaThermo/Data/`)

Repository 구현체와 데이터 소스(네트워크, 로컬 스토리지) 구현부입니다.

**구조:**
- `Repositories/` - `Default` 접두사를 가진 구체적인 구현체 (예: `DefaultOceanRepository`)
- `Network/` - API 엔드포인트 및 DTO 매핑
- `PointDataStorage/` - 로컬 파일 기반 저장소 (`FileDataStorage`)

**주요 패턴:**
- Repository 구현체는 `DataTransferService` 주입
- DTO (Data Transfer Objects)를 도메인 엔티티로 매핑
- 두 가지 전송 서비스:
  - `apiDataTransferService` - JSON API 호출
  - `apiXmlTransferService` - HTML/XML 파싱

**예시:**
```swift
// Data/Repositories/DefaultOceanRepository.swift
class DefaultOceanRepository: OceanRepository {
    private let dataTransferService: DataTransferService

    func fetchTemperatureList(query: OceanQuery,
                            completion: @escaping (Result<OceanResponse, Error>) -> Void) -> Cancellable? {
        let requestDTO = query.toDTO()
        let endpoint = APIEndpoints.getRisaXml(with: requestDTO)
        return dataTransferService.requestHtml(with: endpoint, completion: completion)
    }
}
```

### 3. Presentation 레이어 (`SeaThermo/Presentation/`)

SwiftUI + MVVM 기반의 UI 레이어

**구조:**
- `Main/`
  - `MainView.swift` - 메인 화면 (수온 리스트, 버튼, 지도 선택)
  - `MainHostingViewController.swift` - UIKit 브릿지
  - `OceanSelectView.swift` - 해양 측정소 선택
  - `ViewModel/MainViewModel.swift` - ObservableObject
  - `ViewModel/OceanSelectViewModel.swift` - ObservableObject

- `PointScene/Point/`
  - `PointDateListUIView.swift` - 포인트 날짜 목록
  - `PointDataListUIView.swift` - 포인트 데이터 목록
  - `ViewModel/PointDateListViewModel.swift` - ObservableObject
  - `ViewModel/PointDataListViewModel.swift` - ObservableObject

- `PointScene/Map/`
  - `ApplePointMapView.swift` - Apple Maps 포인트 지도
  - `AppleMapViewRepresentable.swift` - MKMapView 래퍼
  - `KakaoPointMapView.swift` - Kakao Maps 포인트 지도
  - `KakaoMapViewControllerRepresentable.swift` - KakaoMapViewController 래퍼
  - `PointInfoView.swift` - 포인트 정보 표시 패널
  - `ViewModel/PointMapViewModel.swift` - ObservableObject (Apple Maps용)
  - `ViewModel/KakaoPointMapViewModel.swift` - ObservableObject (Kakao Maps용)

- `Track/`
  - `AppleTrackMapView.swift` - Apple Maps 트랙 추적
  - `AppleTrackMapViewRepresentable.swift` - MKMapView 래퍼
  - `KakaoTrackMapView.swift` - Kakao Maps 트랙 추적
  - `KakaoTrackMapViewControllerRepresentable.swift` - KakaoMapViewController 래퍼
  - `ViewModel/TrackMapViewModel.swift` - ObservableObject (Apple Maps용)
  - `ViewModel/KakaoTrackMapViewModel.swift` - ObservableObject (Kakao Maps용)

- `SeaWaterTemperature/`
  - `SeaWaterTemperatureView.swift` - 해수 온도 그래프 및 상세 정보
  - `ViewModel/SeaWaterTemperatureViewModel.swift` - ObservableObject

**MVVM 패턴:**
- SwiftUI View + ObservableObject ViewModel 쌍
- ViewModel은 DI 컨테이너에서 UseCase 주입
- `@Published` 속성으로 데이터 바인딩

## 의존성 주입 (Dependency Injection)

### DI 컨테이너 구조

```
AppDelegate
  └─ DataServiceDIContainer (Application/DIContainer/DataServiceDIContainer.swift)
      ├─ AppConfiguration - Info.plist에서 API 키 로드
      ├─ FileDataStorage - 로컬 저장소
      ├─ apiDataTransferService - JSON API 호출
      ├─ apiXmlTransferService - HTML/XML 파싱
      └─ PointSceneDIContainer (Application/DIContainer/PointSceneDIContainer.swift)
          ├─ Repositories (DefaultOceanRepository, DefaultTrackMapRepository 등)
          ├─ UseCases (OceanUseCase, TrackMapUseCase 등)
          └─ ViewModels (모든 ObservableObject)
```

### PointSceneDIContainer

SwiftUI ViewModel 생성을 담당:

```swift
// Application/DIContainer/PointSceneDIContainer.swift
extension PointSceneDIContainer {
    // ViewModel 생성
    func makeMainViewModel(actions: MainViewModelActions) -> MainViewModel {
        MainViewModel(actions: actions,
                      appConfiguration: dependencies.appConfiguration,
                      oceanUseCase: makeOceanUseCase())
    }

    func makeOceanSelectViewModel() -> OceanSelectViewModel {
        OceanSelectViewModel(appConfiguration: dependencies.appConfiguration,
                             oceanUseCase: makeOceanUseCase())
    }

    func makeTrackMapViewModel() -> TrackMapViewModel {
        TrackMapViewModel(trackMapUseCase: makeTrackMapUseCase())
    }

    func makeTemperatureViewModel() -> SeaWaterTemperatureViewModel {
        SeaWaterTemperatureViewModel(oceanUseCase: makeOceanUseCase(),
                                     appConfiguration: dependencies.appConfiguration)
    }

    // UseCase 생성
    private func makeOceanUseCase() -> OceanUseCase {
        OceanUseCase(oceanRepository: makeOceanRepository())
    }

    // Repository 생성
    private func makeOceanRepository() -> OceanRepository {
        DefaultOceanRepository(dataTransferService: dependencies.apiXmlTransferService)
    }
}
```

### ViewModel에서 DI 컨테이너 사용

SwiftUI View에서 직접 DI 컨테이너 접근:

```swift
// MainView.swift
struct ButtonListView: View {
    let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()

    @State private var appleTrackMapViewModel: TrackMapViewModel?
    @State private var kakaoTrackMapViewModel: KakaoTrackMapViewModel?

    var body: some View {
        VStack {
            // ...
        }
        .onAppear {
            if appleTrackMapViewModel == nil {
                appleTrackMapViewModel = pointSceneDIContainer.makeTrackMapViewModel()
            }
            if kakaoTrackMapViewModel == nil {
                kakaoTrackMapViewModel = pointSceneDIContainer.makeKakaoTrackMapViewModel()
            }
        }
    }
}
```

또는 ViewModel 메서드를 통해:

```swift
// MainViewModel.swift
extension MainViewModel {
    func createOceanSelectView() -> OceanSelectView {
        let pointSceneDIContainer: PointSceneDIContainer = AppDIContainer.shared.resolve()
        return OceanSelectView(viewModel: pointSceneDIContainer.makeOceanSelectViewModel())
    }
}

// MainView.swift
NavigationLink {
    viewModel.createOceanSelectView()
} label: {
    Text("수온 즐겨찾기")
}
```

## ViewModel 패턴 (ObservableObject)

### 기본 구조

```swift
final class MainViewModel: ObservableObject {
    // Published 속성 (SwiftUI 바인딩)
    @Published var oceanStations = [OceanStationModel]()
    @Published var selectedMapType: MapType = FDAppManager.shared.mapType

    // 레거시 Combine 호환성 (점진적 제거 예정)
    var items = CurrentValueSubject<TempuratureListItemViewModel, Never>(...)

    // UseCase 주입
    private let oceanUseCase: OceanUseCase
    private let appConfiguration: AppConfiguration
    private let mainQueue: DispatchQueueType

    init(actions: MainViewModelActions? = nil,
         appConfiguration: AppConfiguration,
         oceanUseCase: OceanUseCase,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.oceanUseCase = oceanUseCase
        self.appConfiguration = appConfiguration
        self.mainQueue = mainQueue
    }

    // 비즈니스 로직
    func fetchStationList() {
        oceanUseCase.excuteRisaList(requestValue: ...) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success(let data):
                    self?.oceanStations = self?.parseData(data) ?? []
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
```

### SwiftUI State 관리 패턴

```swift
// View에서 사용
struct MainView: View {
    @ObservedObject var viewModel: MainViewModel  // 외부 주입

    var body: some View {
        List(viewModel.oceanStations, id: \.self) { station in
            TempuratureRowUIView(station: station)
        }
        .onAppear {
            viewModel.fetchStationList()
        }
    }
}

// 지도 View에서 사용
struct ApplePointMapView: View {
    @StateObject var viewModel: PointMapViewModel  // View 소유
    @State private var selectedPin: MapPin?        // 로컬 상태

    var body: some View {
        AppleMapViewRepresentable(
            region: $viewModel.region,           // @Published 바인딩
            annotations: $viewModel.mapPins,
            selectedAnnotation: $selectedPin     // @State 바인딩
        )
    }
}
```

### 주요 ViewModel들의 @Published 속성

| ViewModel | @Published 속성 | 용도 |
|-----------|----------------|------|
| `MainViewModel` | oceanStations, selectedMapType | 수온 리스트, 지도 타입 |
| `OceanSelectViewModel` | oceanStations | 측정소 선택 리스트 |
| `PointMapViewModel` | region, mapPins, polyLines, isLoaded | 지도 상태 |
| `TrackMapViewModel` | mapLine, currentSpeed, currentLatitude, currentLongitude, isTracking | 트랙 추적 상태 |
| `SeaWaterTemperatureViewModel` | tempuratureItems, isLoading | 온도 데이터, 로딩 상태 |
| `PointDateListViewModel` | pointDateList | 날짜 목록 |
| `PointDataListViewModel` | pointDataList, isShowingPointMap | 데이터 목록, 지도 표시 여부 |

## Infrastructure 레이어 (`SeaThermo/Infrastructure/Network/`)

저수준 네트워킹 추상화:
- `NetworkService.swift` - URLSession 래퍼
- `DataTransferService.swift` - JSON/HTML 지원하는 상위 수준 API 서비스
- `Endpoint.swift` - Associated Type을 사용하는 제네릭 엔드포인트 프로토콜
- `DispatchQueue`를 통한 백그라운드 큐 지원

**API 통합:**
- RISA API (해수 온도)
- COO API (대체 해양 데이터)
- Kakao Maps SDK (지도 시각화)

**API 키 관리:**
`Info.plist`에 저장되며 `AppConfiguration`을 통해 로드:
- `ApiKeyRisa`
- `ApiKeyCoo`
- `KAKAO_APP_KEY`

## Managers (`SeaThermo/Managers/`)

애플리케이션 전역 매니저:
- `FDAppManager` - 앱 상태 관리 (지도 타입 선택, 상수, 초기화)
- `FDFileManager` - 파일 I/O 작업 및 디렉토리 관리
- `FDLocationManager` - GPS 위치 추적 및 권한 관리

## 메모리 관리 전략

### 명시적 Cleanup 메커니즘

```swift
// ApplePointMapView.swift
.onDisappear {
    shouldCleanupMap = false  // 뒤로가기 시 즉시 정리 트리거
    selectedPin = nil
}

// AppleMapViewRepresentable.swift
static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
    uiView.delegate = nil
    uiView.removeOverlays(uiView.overlays)
    uiView.removeAnnotations(uiView.annotations)
    uiView.showsUserLocation = false
}

// Coordinator
func cleanup() {
    DispatchQueue.global(qos: .userInitiated).async {
        DispatchQueue.main.async {
            mapView.delegate = nil
            mapView.removeOverlays(mapView.overlays)
            // ...
        }
    }
}
```

### Weak 참조 패턴

```swift
class Coordinator: NSObject {
    weak var mapView: MKMapView?

    deinit {
        print("Coordinator deinitialized")
    }
}
```

### Delta 비교로 업데이트 최적화

```swift
func shouldUpdatePolylines(current: [MKOverlay], new: [MKPolyline]) -> Bool {
    guard current.count == new.count else { return true }
    // 추가 비교 로직
    return false
}
```

## 네이밍 규칙

- **프로토콜:** 목적에 따라 접미사 (`Repository`, `ViewModel`, `UseCase`)
- **구현체:** `Default` 접두사 (예: `DefaultOceanRepository`)
- **DTO:** `DTO` 접미사 (예: `OceanResponseDTO`)
- **요청/응답:** `RequestValue` 또는 `Response` 접미사
- **ViewModel:** `ViewModel` 접미사 (ObservableObject 채택 필수)
- **SwiftUI View:** `View` 접미사 (예: `MainView`, `OceanSelectView`)
- **Representable:** `Representable` 접미사 (예: `AppleMapViewRepresentable`)
- **HostingController:** `HostingViewController` 접미사
- **베이스 클래스:** `FD` 접두사 (예: `FDAppManager`)

## 코드 구조 규칙

### 레이어 의존성 (단방향)

```
Presentation (SwiftUI View + ViewModel)
    ↓
Domain (UseCase + Repository Protocol)
    ↓
Data (Repository Implementation + DTO)
    ↓
Infrastructure (Network + DataTransferService)
```

- Domain 레이어는 절대 Data나 Presentation에 의존하지 않음
- Domain에서는 프로토콜 사용, Data에서 구현

### Repository 패턴

1. `Domain/Interfaces/`에 프로토콜 정의
2. `Data/Repositories/`에 `Default` 접두사로 구현
3. 네트워크 호출을 위해 `DataTransferService` 주입

### DTO 매핑

- DTO는 `Data/Network/DataMapping/`에 위치
- `toDTO()` 및 `toDomain()` 매핑 메서드 제공
- 도메인 엔티티는 깔끔하고 프레임워크 독립적으로 유지

### 에러 처리

Swift의 `Result` 타입 사용:
```swift
completion: @escaping (Result<DomainEntity, Error>) -> Void
```

### 비동기 작업

취소 가능한 작업은 `Cancellable?` 반환:
```swift
func fetchData() -> Cancellable? {
    return repository.fetch { result in
        // 결과 처리
    }
}
```

### SwiftUI State 관리

```swift
// ViewModel
@Published var oceanStations = [OceanStationModel]()

// View
@ObservedObject var viewModel: MainViewModel       // 외부 주입
@StateObject var viewModel = PointMapViewModel()   // View 소유
@State private var showOceanInfo = false           // 로컬 상태
@Binding var selectedPin: MapPin?                  // 양방향 바인딩
```

## 일반적인 개발 작업

### 새로운 SwiftUI 화면 추가

1. `Presentation/`에 SwiftUI View 생성 (`*View.swift`)
   ```swift
   struct MyFeatureView: View {
       @ObservedObject var viewModel: MyFeatureViewModel

       var body: some View {
           // UI 구현
       }
   }
   ```

2. ObservableObject ViewModel 생성
   ```swift
   final class MyFeatureViewModel: ObservableObject {
       @Published var items = [Item]()
       private let useCase: MyFeatureUseCase

       init(useCase: MyFeatureUseCase) {
           self.useCase = useCase
       }
   }
   ```

3. `PointSceneDIContainer`에 ViewModel 생성 메서드 추가
   ```swift
   func makeMyFeatureViewModel() -> MyFeatureViewModel {
       MyFeatureViewModel(useCase: makeMyFeatureUseCase())
   }
   ```

4. NavigationLink로 화면 전환 추가
   ```swift
   NavigationLink {
       MyFeatureView(viewModel: pointSceneDIContainer.makeMyFeatureViewModel())
   } label: {
       Text("새 기능")
   }
   ```

### UIKit 컴포넌트를 SwiftUI로 통합

**UIView인 경우:**
```swift
struct MyViewRepresentable: UIViewRepresentable {
    @Binding var data: SomeData

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 데이터 업데이트
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        // 메모리 정리
    }
}
```

**UIViewController인 경우:**
```swift
struct MyViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: MyViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 업데이트
    }
}
```

### 새로운 도메인 엔티티 추가

1. `Domain/Entities/`에 엔티티 struct 생성
   ```swift
   struct MyEntity {
       let id: String
       let name: String
   }
   ```

2. `Domain/Interfaces/`에 Repository 프로토콜 정의
   ```swift
   protocol MyEntityRepository {
       func fetch(completion: @escaping (Result<[MyEntity], Error>) -> Void) -> Cancellable?
   }
   ```

3. `Domain/UseCases/`에 UseCase 생성
   ```swift
   class MyEntityUseCase {
       private let repository: MyEntityRepository

       func execute(completion: @escaping (Result<[MyEntity], Error>) -> Void) -> Cancellable? {
           return repository.fetch(completion: completion)
       }
   }
   ```

4. `Data/Repositories/`에 Repository 구현
   ```swift
   class DefaultMyEntityRepository: MyEntityRepository {
       private let dataTransferService: DataTransferService

       func fetch(completion: @escaping (Result<[MyEntity], Error>) -> Void) -> Cancellable? {
           // 구현
       }
   }
   ```

5. DI 컨테이너에서 연결
   ```swift
   private func makeMyEntityRepository() -> MyEntityRepository {
       DefaultMyEntityRepository(dataTransferService: dependencies.apiDataTransferService)
   }
   ```

### 새로운 API 엔드포인트 추가

1. `Data/Network/APIEndpoints.swift`에 엔드포인트 정의
   ```swift
   static func getMyData(with requestDTO: MyRequestDTO) -> Endpoint<MyResponseDTO> {
       return Endpoint(path: "api/mydata", method: .get, queryParameters: requestDTO)
   }
   ```

2. `Data/Network/DataMapping/`에 request/response DTO 생성
   ```swift
   struct MyRequestDTO: Encodable {
       let param: String
   }

   struct MyResponseDTO: Decodable {
       let data: [DataDTO]
   }
   ```

3. 매핑 메서드 추가
   ```swift
   extension MyEntity {
       func toDTO() -> MyRequestDTO {
           return MyRequestDTO(param: self.id)
       }
   }

   extension MyResponseDTO {
       func toDomain() -> [MyEntity] {
           return data.map { $0.toDomain() }
       }
   }
   ```

## 주요 설정

1. **API 키:** `Info.plist`에 저장, `AppConfiguration`을 통해 로드
2. **백그라운드 위치:** GPS 추적을 위해 `Info.plist`에서 활성화
3. **CocoaPods:** 변경사항 pull 후 항상 `pod install` 실행
4. **Workspace:** 항상 `.xcworkspace` 열기, `.xcodeproj` 아님

## 의존성

- **KakaoMapsSDK 2.6.3** - 지도 시각화 (한국 지도)
- **SnapKit** - 프로그래밍 방식 레이아웃 제약 (커스텀 xcframework)
- 기본 프레임워크: SwiftUI, UIKit, MapKit, CoreLocation, Foundation, Combine

## 성능 최적화

### 메모리 관리
- **Weak 참조:** Coordinator와 closure의 메모리 누수 방지
- **Cleanup 플래그:** `shouldCleanup` @Binding으로 명시적 정리
- **Deinit 추적:** Print 문으로 생명주기 모니터링

### 렌더링 최적화
- **Delta 비교:** Polyline/Annotation 변경 감지 후 필요시만 업데이트
- **백그라운드 처리:** 지도 정리 작업을 `DispatchQueue.global`에서 수행
- **3D 비활성화:** Apple Maps 성능 개선 (`isRotateEnabled = false`, `isPitchEnabled = false`)

### State 업데이트 최적화
```swift
// 불필요한 업데이트 방지
if mapView.overlays.count != polylines.count {
    mapView.removeOverlays(mapView.overlays)
    mapView.addOverlays(polylines)
}
```

## 향후 개선 계획

- [ ] 레거시 UIKit ViewController 및 Storyboard 파일 제거
- [ ] CurrentValueSubject 제거 (완전한 @Published로 전환)
- [ ] SwiftUI Preview 추가
- [ ] 테스트 커버리지 추가
- [ ] iOS 16+ Async/Await 전환 검토
- [ ] NavigationStack 도입 (iOS 16+)
