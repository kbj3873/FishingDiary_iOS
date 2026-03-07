# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참고하는 가이드 문서입니다.

## 관련 문서

| 문서 | 용도 | 언제 참조 |
|-----|------|----------|
| [기능 개발 워크플로우](.agent/workflows/develop_feature.md) | Standard Workflow | 기능 구현 시작 시 **필수** |
| [한국어 사용 규칙](.agent/workflows/korean_language.md) | Language Rule | 모든 대화 및 주석 작성 시 |
| [프로젝트 구조](.agent/workflows/project_structure.md) | Domain & Context | 기존 컴포넌트/엔티티 확인 시 |
| [작업 로그 가이드](.agent/workflows/work_log.md) | Notion Work Log | 일일 작업 로그 기록 시 |
| [Figma 변환 규칙](.claude/figma-to-swiftui.md) | 상세 디자인 가이드 | (참고용) Figma 작업 시 |
| [Domain 요약](.claude/domain-summary.md) | 상세 도메인 지식 | (참고용) 도메인 로직 심화 |

## 프로젝트 개요

**온바다(SeaThermo)**는 낚시 활동을 기록하고 추적하는 iOS 애플리케이션으로, 해양 데이터 통합 기능을 제공합니다. 한국 해양 API에서 실시간 해수 온도 정보를 가져오고, GPS 기반 낚시 위치 추적 및 듀얼 맵 지원(Apple Maps와 Kakao Maps)을 제공합니다.

- **플랫폼:** iOS 16.0+
- **언어:** Swift
- **UI 프레임워크:** SwiftUI (1차 마이그레이션 완료)
- **아키텍처:** Clean Architecture + MVVM
- **의존성 관리:** CocoaPods
- **주요 워크스페이스:** `SeaThermo.xcworkspace` (.xcodeproj 아님)

## 현재 상태

순수 SwiftUI 기반 앱으로 동작합니다. 레거시 UIKit 의존성(`AppDelegate`, `SceneDelegate`, `HostingViewController` 등)은 모두 제거되었으며, `@main` App 구조체를 통한 최신 앱 수명 주기 룰을 따릅니다.

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
@main
struct SeaThermoApp: App
  → WindowGroup
      → currentStep 상태에 따른 분기 (splash / onboarding / main)
          → SplashView
          → OnboardingView
          → MainTabView (SwiftUI 진입점)
```

**핵심 파일:**
- `SeaThermoApp.swift`: `@main` 앱 진입점, 의존성 초기화 및 Splash/Onboarding/Main 라우팅 관리
- `MainTabView.swift`: 탭 기반의 메인 화면 구성

## SwiftUI 아키텍처

### 화면 구성

현재 앱에서 실제로 사용되는 SwiftUI 화면들:

| 영역 | 화면 | SwiftUI View | 통합 방식 | 상태 |
|---|---|---|---|---|
| **Main** | 메인 탭 | `MainTabView.swift` | WindowGroup 최상단 | Active |
| **Main** | 메인 홈 | `CurrentTemperatureView.swift` | TabView Item | Active |
| **Main** | 해양 선택 | `OceanSelectView.swift` | NavigationLink | Active |
| **SeaAnalysis** | 수온 분석 홈 | `SeaAnalysisView.swift` | TabView Item | Active |
| **SeaAnalysis** | 수온 상세 | `SeaAnalysisDetailView.swift` | NavigationLink | Active |
| **FishingRecord** | 낚시 기록 | `FishingRecordView.swift` | TabView Item | Active |
| **History** | 조과 기록 목록 | `HistoryView.swift` | TabView Item | Active |
| **History** | 조과 상세 | `HistoryDetailView.swift` | NavigationLink | Active |
| **History** | 이미지 뷰어 | `HistoryImageViewer.swift` | FullScreenCover | Active |
| **Setting** | 설정 | `SettingView.swift` | TabView Item | Active |

### NavigationView 구조

앱 내부 내비게이션은 `NavigationStack`(iOS 16+) 및 기존 호환성을 위한 `NavigationView` 형태로 전환되었습니다.

```swift
// RouteView.swift 등에서의 화면 전환 예시
NavigationStack {
    MainTabView()
}
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
- UseCase는 단일 책임 원칙에 따라 비즈니스 흐름을 오케스트레이션합니다.
- 비동기 작업은 Swift Concurrency(`async throws`) 표준 패턴을 채택했습니다.
- Request/Response 값 객체로 입출력 데이터를 캡슐화합니다.

**예시:**
```swift
// Domain/Interfaces/OceanRepository.swift
protocol OceanRepository {
    func fetchTemperatureList(query: OceanQuery) async throws -> OceanResponse
}

// Domain/UseCases/OceanUseCase.swift
class OceanUseCase {
    private let oceanRepository: OceanRepository

    func excuteRisaList(requestValue: RequestValue) async throws -> Ocean {
        return try await oceanRepository.fetchTemperatureList(query: requestValue.query)
    }
}
```

### 2. Data 레이어 (`SeaThermo/Data/`)

Repository 구현체와 데이터 소스(네트워크, 로컬 스토리지) 구현부입니다.

**구조:**
- `Repositories/` - `Default` 접두사를 가진 구체적인 구현체 (예: `DefaultOceanRepository`)
- `Network/` - API 엔드포인트 및 DTO 매핑
- `PersistentStorages/` - 로컬 파일 및 DB 기반 저장소 (예: `RealmStorage`)

**주요 패턴:**
- Repository 구현체는 `NetworkService` 주입 (단일 네트워크 서비스)
- DTO (Data Transfer Objects)를 도메인 엔티티로 매핑
- Swift Concurrency 활용 통일

**예시:**
```swift
// Data/Repositories/DefaultOceanRepository.swift
class DefaultOceanRepository: OceanRepository {
    private let apiNetworkService: NetworkService

    init(apiNetworkService: NetworkService) {
        self.apiNetworkService = apiNetworkService
    }

    func fetchRisaList(_ query: CurrentTemperatureQuery) async throws -> [CurrentTemperature] {
        let requestDTO = RisaListRequestDTO(query)
        let endpoint = APIEndpoints.getRisaJson(baseURL: apiNetworkService.baseURL, with: requestDTO)
        let responseDTO: RisaListResponseDTO = try await apiNetworkService.request(with: endpoint)
        
        if responseDTO.header.resultCode != "00" {
            throw NetworkError.apiError(code: responseDTO.header.resultCode, message: "에러 메시지")
        }
        
        return responseDTO.body.item?.map { $0.toDomain() } ?? []
    }
}
```

### 3. Presentation 레이어 (`SeaThermo/Presentation/`)

SwiftUI + MVVM 기반의 UI 레이어

**구조:**
- `MainTab/`
  - `MainTabView.swift` - 탭 기반 앱 라우팅 및 탭 설정의 메인 뷰

- `CurrentTemperature/`
  - `View/CurrentTemperatureView.swift` - 현재 수온 상태 정보 홈 화면
  - `View/OceanSelectView.swift` - 즐겨찾기 해양 측정소 선택 뷰
  - `ViewModel/CurrentTemperatureViewModel.swift` - ObservableObject

- `SeaAnalysis/`
  - `SeaAnalysisView.swift` - 수온 분석 홈 화면
  - `SeaAnalysisDetailView.swift` - 수온 분석 상세 차트 화면

- `FishingRecord/`
  - `View/FishingRecordView.swift` - 낚시 기록 등록 및 지도 기반 기록
  - `View/Components/RecordKakaoMapView.swift` - 카카오맵 기반 맵 렌더러
  - `View/Components/RecordMapView.swift` - Apple Map 기반 맵 렌더러
  - `View/Components/RecordKakaoMapViewController.swift` - 브릿지 컨트롤러

- `History/`
  - `HistoryView.swift` - 조과 기록 목록 조회
  - `HistoryDetailView.swift` - 조과 상세 정보 및 이미지 뷰어
  - `HistoryImageViewer.swift` - 풀스크린 사진 모아보기

- `Setting/`
  - `SettingView.swift` - 설정 메뉴 관리 및 WebView 라우팅
  - `PrivacyTermsView.swift` - 약관 동의 화면

**MVVM 구현 패턴 (Swift 5.5+):**
- **ViewModel 정의**: `@MainActor` 속성을 클래스 레벨에 부여하여 모든 UI 상태(`@Published`) 업데이트가 메인 스레드에서 시리얼하게 발생함을 보장합니다.
- **상태 관리**: Combine의 `CurrentValueSubject`를 완전히 제거하고, 순수 `@Published` 프로퍼티만을 사용합니다.
- **의존성 주입**: ViewModel 생명주기 관리는 뷰 로드 시 `ApplicationDIContainer`의 Factory 메서드를 통해 주입받습니다.
- **비동기 처리**: `UseCase`의 로직은 SwiftUI View의 `.task {}` 모디파이어 내부, 또는 ViewModel의 `Task { ... }` 블록 내에서 `try await`으로 호출합니다.

```swift
@MainActor
final class CurrentTemperatureViewModel: ObservableObject {
    @Published var temperatureInfo: [CurrentTemperature] = []
    @Published var isLoading: Bool = false
    
    private let oceanUseCase: OceanUseCase
    
    init(oceanUseCase: OceanUseCase) {
        self.oceanUseCase = oceanUseCase
    }
    
    func fetchCurrentTemperature() {
        Task {
            isLoading = true
            do {
                let query = CurrentTemperatureQuery(...)
                temperatureInfo = try await oceanUseCase.excuteRisaList(requestValue: .init(query: query))
            } catch {
                print("Error: \(error)")
            }
            isLoading = false
        }
    }
}
```

## 의존성 주입 (Dependency Injection)

### DI 컨테이너 구조

```
SeaThermoApp (@main)
  └─ AppDIContainer (전역 싱글턴)
      └─ ApplicationDIContainer (UI 의존성 주입)
          ├─ AppConfiguration (Info.plist API 로드)
          ├─ FileDataStorage (로컬 저장소), RealmStorage 등
          ├─ apiNetworkService (단일 네트워크 서비스)
          ├─ Repositories (OceanRepository 등)
          ├─ UseCases (OceanUseCase 등)
          └─ ViewModels (모든 ObservableObject 공장)
```

### ApplicationDIContainer

앱 전체에서 사용할 ViewModel 생성을 담당하며, View 트리에 주입됩니다.

```swift
// Application/DIContainer/ApplicationDIContainer.swift
final class ApplicationDIContainer: ObservableObject {
    // 의존성 보관
    lazy var appConfiguration = AppConfiguration()
    lazy var apiNetworkService: NetworkService = { ... }()

    // ViewModel Factory 메서드
    func makeCurrentTemperatureViewModel() -> CurrentTemperatureViewModel {
        CurrentTemperatureViewModel(
            oceanUseCase: makeOceanUseCase(),
            appConfiguration: appConfiguration
        )
    }

    // UseCase 및 Repository 생성
    private func makeOceanUseCase() -> OceanUseCase {
        OceanUseCase(oceanRepository: makeOceanRepository())
    }
}
```

### ViewModel에서 DI 컨테이너 사용

SwiftUI 앱 진입점에서 로컬 State 기반 라우팅과 함께 `EnvironmentObject`로 컨테이너를 주입하고, 최하위 뷰에서 꺼내어 사용합니다.

```swift
// SeaThermoApp.swift
@main
struct SeaThermoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let applicationDIContainer: ApplicationDIContainer
    @State private var currentStep: AppStep = .splash

    init() {
        self.applicationDIContainer = ApplicationDIContainer()
        AppDIContainer.shared.register(applicationDIContainer)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch currentStep {
                case .splash:
                    SplashView(...)
                case .onboarding:
                    OnboardingView(...)
                case .main:
                    MainTabView()
                        .environmentObject(applicationDIContainer)
                }
            }
        }
    }
}


// 뷰 레벨에서의 사용 예시 (MainTabView.swift)
struct MainTabView: View {
    @EnvironmentObject var diContainer: ApplicationDIContainer

    var body: some View {
        TabView {
            CurrentTemperatureView(viewModel: diContainer.makeCurrentTemperatureViewModel())
        }
    }
}
```



## Infrastructure 레이어 (`SeaThermo/Infrastructure/Network/`)

저수준 네트워킹 추상화:
- `NetworkService.swift` - URLSession 래퍼 (단일 네트워크 서비스 역할 수행)
- `Endpoint.swift` - Associated Type을 사용하는 제네릭 엔드포인트 프로토콜
- `Swift Concurrency` 패러다임(`async/await`)을 활용한 전면적인 비동기 처리

**API 통합 (Base URL):**
- NIFS API (국립수산과학원 해양 데이터)
- Onbada API (자체 서비스 수온 데이터)
- Kakao Maps SDK (지도 시각화)

**API 키 및 URL 관리:**
`Info.plist`에 저장되며 `AppConfiguration`을 통해 로드 (옵셔널 바인딩 강제 언래핑 적용):
- `ApiKeyRisa`
- `ApiNifsURL`
- `ApiOnbadaURL`
- `KAKAO_APP_KEY` 등

## Managers (`SeaThermo/Managers/`)

애플리케이션 전역 매니저:
- `FDAppManager` - 앱 상태 관리 (지도 타입 선택, 상수, 초기화)
- `FDLocationManager` - GPS 위치 추적 및 권한 관리

## 메모리 관리 전략

### SwiftUI 및 Concurrency 기반 수명주기 관리

- **Task 취소 자동화**: `.task {}` 모디파이어를 사용하여 View가 사라질 때 비동기 작업 통신이 자동으로 취소되도록 관리합니다.
- **상태 관리 객체**: 뷰 계층 내에서 생성되는 `@StateObject`는 뷰 수명주기와 함께 메모리에서 해제되며, `[weak self]` 참조의 필요성이 줄었습니다.

### 맵 컴포넌트 명시적 Cleanup (UIKit 브릿징)

SwiftUI에서 `MKMapView`나 카카오맵 등 무거운 UIKit 컴포넌트를 브릿징할 때 활용하는 강제 정리(Cleanup) 패턴입니다.

```swift
// View 단계에서의 트리거 (예: FishingRecordView.swift)
.onDisappear {
    shouldCleanup = true // 맵 렌더러에 정리 지시
}

// Representable 내부 정리 로직 (예: RecordMapView.swift)
func updateUIView(_ uiView: MKMapView, context: Context) {
    if shouldCleanup {
        context.coordinator.cleanup()
        return
    }
    // ...
}

static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
    coordinator.cleanup() // 뷰가 완전히 파괴될 때 호출됨
}
```

### Weak 참조 패턴 (`Coordinator` 등 브릿징 객체 연결 시)

순환 참조를 방지하기 위해 델리게이트를 소유하는 객체 등에서는 `weak` 참조 패턴을 지속적으로 사용합니다.

```swift
class Coordinator: NSObject, MKMapViewDelegate {
    weak var mapView: MKMapView?

    deinit {
        print("Coordinator deinitialized")
        // 필요 시 여기서 추가 해제 작업
    }
}
```

## 네이밍 규칙

- **프로토콜:** 목적에 따라 접미사 (`Repository`, `ViewModel`, `UseCase`)
- **구현체:** `Default` 접두사 (예: `DefaultOceanRepository`)
- **DTO:** `DTO` 접미사 (예: `RisaListRequestDTO`, `RisaListResponseDTO`)
- **요청/응답:** `Query` 또는 `Response` 접미사
- **ViewModel:** `ViewModel` 접미사 (`ObservableObject` 채택 및 `@MainActor` 권장)
- **SwiftUI View:** `View` 접미사 (예: `MainTabView`, `OceanSelectView`)
- **DI 컨테이너:** `DIContainer` 접미사 (예: `ApplicationDIContainer`)
- **전역 베이스 클래스:** `FD` 접두사 (예: `FDAppManager`, `FDUserDefaults`)

## 코드 구조 규칙

### 레이어 의존성 (단방향)

```
Presentation (SwiftUI View + ViewModel)
    ↓
Domain (UseCase + Repository Protocol + Entity)
    ↓
Data (Repository Implementation + DTO)
    ↓
Infrastructure (Network / Storage)
```

- Domain 레이어는 절대 Data나 Presentation에 의존하지 않음 (엔티티 중심)
- Domain에서는 프로토콜을 정의하고, Data 계층에서 그 프로토콜을 구현

### Repository 패턴

1. `Domain/Interfaces/`에 `Repository` 프로토콜 정의
2. `Data/Repositories/`에 `Default` 접두사로 구현체 작성
3. 네트워크 통신 구현체는 의존성으로 구체적인 `NetworkService`를 주입받아 사용

### DTO 매핑

- DTO 파일은 `Data/Network/DataMapping/` 폴더에 생성
- `toDomain()` 매핑 메서드를 통해 DTO를 순수 도메인 엔티티로 변환
- 도메인 엔티티 코드 내부에는 외주 프레임워크나 API 스펙 변경의 여파가 닿지 않아야 함

### 비동기 작업

모든 네트워크/DB I/O는 Swift Concurrency 기반의 비동기 함수로 작성합니다. UI 업데이트는 `@MainActor`로 보장합니다.

```swift
func fetchData() async {
    do {
        let result = try await repository.fetch()
        await MainActor.run {
            self.items = result
        }
    } catch {
        print(error)
    }
}
```

### SwiftUI State 관리 패턴

```swift
// ViewModel
@MainActor
final class MyViewModel: ObservableObject {
    @Published var dataList = [DomainModel]()
}

// View
@StateObject var viewModel = MyFeatureViewModel()    // View 생명주기를 따르는 생성
@EnvironmentObject var di: ApplicationDIContainer    // 전역 의존성 접근
@State private var showDetail = false                // 화면 내 단일 로컬 상태
```

## 일반적인 개발 작업

### 새로운 SwiftUI 화면 추가 가이드

1. `Presentation/` 영역에 SwiftUI View 생성 (`*View.swift`)
   ```swift
   struct MyFeatureView: View {
       @StateObject private var viewModel: MyFeatureViewModel

       init(viewModel: MyFeatureViewModel) {
           _viewModel = StateObject(wrappedValue: viewModel)
       }

       var body: some View {
           // UI 구현
           Text("새 기능 뷰")
               .task {
                   await viewModel.loadData()
               }
       }
   }
   ```

2. ViewModel 생성 (`ObservableObject`, `@MainActor` 권장)
   ```swift
   @MainActor
   final class MyFeatureViewModel: ObservableObject {
       @Published var items: [MyItem] = []
       private let useCase: MyFeatureUseCase

       init(useCase: MyFeatureUseCase) {
           self.useCase = useCase
       }
       
       func loadData() async {
           // 비동기 통신 로직
       }
   }
   ```

3. `ApplicationDIContainer`에 의존성 팩토리 메서드 추가
   ```swift
   // ApplicationDIContainer.swift 내부
   func makeMyFeatureView() -> some View {
       return MyFeatureView(viewModel: makeMyFeatureViewModel())
   }

   private func makeMyFeatureViewModel() -> MyFeatureViewModel {
       return MyFeatureViewModel(useCase: makeMyFeatureUseCase())
   }
   // ... 생략 ...
   ```

4. `NavigationLink` 혹은 라우팅을 이용한 화면 전환
   ```swift
   @EnvironmentObject var di: ApplicationDIContainer
   // ...
   NavigationLink {
       di.makeMyFeatureView()
   } label: {
       Text("새 기능 열기")
   }
   ```

### 카카오맵 등 UIKit 컴포넌트를 SwiftUI로 통합

카카오맵 SDK나 기존 UIKit 기반 복잡한 뷰(예: 오버레이가 많은 `MKMapView`)는 네이티브 SwiftUI 뷰를 지원하지 않아, 필연적으로 브릿징 코드가 필요합니다. `UIViewRepresentable`이나 `UIViewControllerRepresentable`을 통해 SwiftUI 환경에 어댑터 형태로 통합합니다.

**UIView 브릿징 예시 (`RecordMapView` 스타일):**
```swift
struct MyMapRepresentable: UIViewRepresentable {
    @Binding var shouldCleanup: Bool
    
    // 1. UIKit 뷰 생성
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    // 2. SwiftUI 상태 변화에 따른 UIKit 뷰 업데이트
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if shouldCleanup {
            context.coordinator.cleanup() // 메모리 누수 방지
            return
        }
    }

    // 3. 델리게이트와 이벤트를 중계할 코디네이터 생성
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 4. 뷰가 완전히 사라질 때 호출 (클린업 트리거)
    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        coordinator.cleanup()
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
       func fetch() async throws -> [MyEntity]
   }
   ```

3. `Domain/UseCases/`에 UseCase 생성
   ```swift
   class MyEntityUseCase {
       private let repository: MyEntityRepository

       func execute() async throws -> [MyEntity] {
           return try await repository.fetch()
       }
   }
   ```

4. `Data/Repositories/`에 Repository 구현
   ```swift
   class DefaultMyEntityRepository: MyEntityRepository {
       private let apiNetworkService: NetworkService

       init(apiNetworkService: NetworkService) {
           self.apiNetworkService = apiNetworkService
       }

       func fetch() async throws -> [MyEntity] {
           let endpoint = APIEndpoints.getMyData(...)
           let dto: MyEntityResponseDTO = try await apiNetworkService.request(with: endpoint)
           return dto.toDomain()
       }
   }
   ```

5. DI 컨테이너에서 연결
   ```swift
   private func makeMyEntityRepository() -> MyEntityRepository {
       DefaultMyEntityRepository(dataTransferService: dependencies.apiDataTransferService)
   }
   ```

### 새로운 API 엔드포인트 추가 가이드

1. `Data/Network/APIEndpoints.swift`에 엔드포인트 팩토리 정의
   ```swift
   static func getFeatureData<R>(baseURL: String, with requestDTO: FeatureRequestDTO) -> Endpoint<R> {
       return Endpoint(baseURL: baseURL,
                       path: "api/v1/feature",
                       method: .post,
                       headerParameters: Headers.forSeaThermoAPI(),
                       bodyParametersEncodable: requestDTO)
   }
   ```

2. `Data/Network/DataMapping/` 하위에 Request/Response DTO 생성
   ```swift
   struct FeatureRequestDTO: Encodable {
       let targetId: String
   }

   struct FeatureResponseDTO: Decodable {
       let dataList: [DataDTO]
   }
   ```

3. DTO 매핑 익스텐션 추가
   ```swift
   extension FeatureEntity {
       func toDTO() -> FeatureRequestDTO {
           return FeatureRequestDTO(targetId: self.id)
       }
   }

   extension FeatureResponseDTO {
       func toDomain() -> [FeatureEntity] {
           return dataList.map { $0.toDomain() } // 내부 DTO에 toDomain() 각각 구현
       }
   }
   ```

## 주요 설정

1. **API 키 관리:** `Info.plist`에 안전하게 저장하며 전역 싱글톤인 `AppConfiguration`을 통해 앱 전역으로 로드
2. **백그라운드 위치:** GPS 추적을 위해 `Info.plist` (Location Always and When In Use Usage Description)에서 권한 명시 적용
3. **프로젝트 오픈:** `SeaThermo.xcworkspace` 워크스페이스 파일을 항상 엽니다. (`.xcodeproj` 제외)

## 주요 의존성 (Dependencies)

- **KakaoMapsSDK 2.6.3+** - 낚시 포인트 및 지도 시각화 (한국 맵 전용)
- **Firebase** - Analytics, Crashlytics 등 기본 앱 관제 및 유저 이벤트 트래킹 (적용 시점)
- **기본 Apple 프레임워크:** SwiftUI, MapKit, CoreLocation, Foundation, Swift Concurrency (`async/await`)

## 성능 최적화

### 메모리 관리 (Memory Leak Prevention)
- **Weak 참조:** `UIViewRepresentable`의 `Coordinator` 등 브릿지 객체와 비동기 콜백에서의 `[weak self]` 활용
- **명시적 Cleanup 플래그:** SwiftUI 사이클 종결 전 `shouldCleanup` 같은 @Binding 상태를 활용하여 UIKit 파티의 자원 명시적 반환 처리

### 렌더링 최적화
- **Task 기반 백그라운드 처리:** 뷰모델 내 데이터 무거운 데이터 가공 파트는 `Task.detached`나 백그라운드 큐로 오프로딩 적용
- **3D 비활성화 (맵 컴포넌트):** UIKit MapKit 요소 통합 시 성능 개선을 위해 기본적으로 `isRotateEnabled = false`, `isPitchEnabled = false` 강제 고정

## 향후 개선 계획

- [x] 레거시 UIKit ViewController 및 Storyboard 파일 완전 제거
- [x] Combine `CurrentValueSubject` 등 레거시옵저버 제거 및 한정적 로직에만 사용 (완전한 `@Published` 및 Concurrency 전환)
- [x] iOS 16+ Async/Await 전환 (Task 블록 기반 리팩토링 및 네트워킹 구조 `NetworkService`로 통합)
- [x] NavigationStack 도입 (화면 전환 라우팅 구조 개선 완료 및 DI 분리)
- [ ] 에러 핸들링 추가 고도화 (`NetworkError` -> 세부 `Domain Error` 변환 레이어 추가)
- [ ] SwiftUI Preview 지원 강화를 위한 Mock 데이터 팩토리 및 UI 컴포넌트 추가 분리
