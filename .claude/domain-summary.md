# Domain Layer 요약

Domain 레이어의 Entity, Repository, UseCase 요약입니다.
도메인 로직 작업 시 이 파일을 먼저 참조하세요.

## Entities

### Ocean (해양 데이터)

**파일:** `Domain/Entities/Ocean.swift`

```swift
// 해양 측정소 정보 (앱에서 주로 사용)
struct OceanStationModel: Codable, Hashable {
    var stationCode: String      // 측정소 코드
    var stationName: String      // 측정소 이름
    var surTempurature: String   // 표층 수온
    var midTempurature: String   // 중층 수온
    var botTempurature: String   // 저층 수온
    var isChecked: Bool          // 즐겨찾기 여부
}

// API 응답 원본
struct Ocean: Equatable {
    let staCde: String           // 측정소 코드
    let staNamKor: String        // 측정소 한글명
    let staNam: String           // 측정소 영문명
    let obsDtm: String           // 관측 일시
    let wtrTempS: Float          // 표층 수온
    let wtrTempM: Float          // 중층 수온
    let wtrTempB: Float          // 저층 수온
    let lon: Float               // 경도
    let lat: Float               // 위도
}

// RISA API 응답
struct RisaList: Equatable {
    var gruNam: String           // 그룹명
    var staCde: String           // 측정소 코드
    var obsLay: String           // 관측 층 (1:표층, 2:중층, 3:저층)
    var staNamKor: String        // 측정소 한글명
    var wtrTmp: String           // 수온
}
```

### PointMap (지도/위치)

**파일:** `Domain/Entities/PointMap.swift`

```swift
// 지도 타입
enum MapType: Int {
    case AppleMap
    case KakaoMap
}

// 위치 데이터 (저장용)
struct LocationData: Codable {
    var time: String             // 기록 시간
    var latitude: String         // 위도
    var longitude: String        // 경도
    var kmh: String              // 속도 (km/h)
    var knot: String             // 속도 (knot)
    var sequence: Int            // 순서
}

// Apple Maps 핀
class MapPin: MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let locationData: LocationData
    let image: UIImage
    var dmsType: DMSType         // 좌표 표시 형식
}

// Kakao Maps 핀
class KakaoMapPin {
    let title: String?
    let mapPoint: MapPoint       // Kakao SDK 좌표
    let locationData: LocationData
    var dmsType: DMSType
}

// 좌표 표시 형식
enum DMSType: Int {
    case D      // 도 (Decimal)
    case DM     // 도/분
    case DMS    // 도/분/초
}
```

### PointDate (포인트 저장)

**파일:** `Domain/Entities/PointDate.swift`

```swift
// 날짜별 포인트 폴더
struct PointDate: Equatable {
    let date: String?            // 날짜 문자열
    let datePath: URL?           // 폴더 경로
}

// 개별 포인트 데이터
struct PointData: Equatable {
    let dataName: String?        // 파일 이름
    let dataPath: URL?           // 파일 경로
}
```

---

## Repository Protocols

### OceanRepository

**파일:** `Domain/Interfaces/OceanRepository.swift`

```swift
protocol OceanRepository {
    // RISA API - 수온 리스트
    func fetchRisaList(query: RisaListQuery,
                       completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable?

    // RISA API - 측정소 코드
    func fetchStationCode(query: RisaCodeQuery,
                          completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable?

    // COO API - 수온 데이터
    func fetchRisaCoo(query: RisaCooQuery,
                      completion: @escaping (Result<RisaResponse, Error>) -> Void) -> Cancellable?

    // 해양 수온 정보
    func fetchTemperature(query: OceanQuery,
                          completion: @escaping (Result<OceanResponse, Error>) -> Void) -> Cancellable?
}
```

### PointMapRepository

**파일:** `Domain/Interfaces/PointMapRepository.swift`

```swift
protocol PointMapRepository {
    // 로컬 파일에서 위치 데이터 로드
    func fetchLocations(pointData: PointData,
                        completion: (Result<[LocationData], FileStorageError>) -> Void)
}
```

### TrackMapRepository

**파일:** `Domain/Interfaces/TrackMapRepository.swift`

```swift
protocol TrackMapRepository {
    // 새 날짜 폴더 생성
    func createPointDate() -> FileCreateResult

    // 새 포인트 파일 생성
    func createPointData() -> FileCreateResult

    // 위치 데이터 저장
    func savePoints(locations: [LocationData])
}
```

### PointDateListRepository

**파일:** `Domain/Interfaces/PointDateListRepository.swift`

```swift
protocol PointDateListRepository {
    func fetchPointDateList(completion: (Result<[PointDate], FileStorageError>) -> Void)
}
```

### PointDataListRepository

**파일:** `Domain/Interfaces/PointDataListRepository.swift`

```swift
protocol PointDataListRepository {
    func fetchPointDataList(pointDate: PointDate,
                            completion: (Result<[PointData], FileStorageError>) -> Void)
}
```

---

## UseCases

### OceanUseCase

**파일:** `Domain/UseCases/OceanUseCase.swift`

| 메서드 | RequestValue | 용도 |
|--------|-------------|------|
| `excuteRisaList` | `RisaListQuery` | 수온 리스트 조회 |
| `excuteStationCode` | `RisaCodeQuery` | 측정소 코드 조회 |
| `excuteRisaCoo` | `RisaCooQuery` | COO 수온 조회 |
| `excuteTemperature` | `OceanQuery` | 해양 수온 조회 |

### PointMapUseCase

**파일:** `Domain/UseCases/PointMapUseCase.swift`

| 메서드 | RequestValue | 용도 |
|--------|-------------|------|
| `execute` | `PointData` | 위치 데이터 로드 |

### TrackMapUseCase

**파일:** `Domain/UseCases/TrackMapUseCase.swift`

| 메서드 | 용도 |
|--------|------|
| `createPointDate` | 날짜 폴더 생성 |
| `createPointData` | 포인트 파일 생성 |
| `savePoints` | 위치 데이터 저장 |

### PointDateUseCase

**파일:** `Domain/UseCases/PointDateUseCase.swift`

| 메서드 | 용도 |
|--------|------|
| `execute` | 날짜 목록 조회 |

### PointDataUseCase

**파일:** `Domain/UseCases/PointDataUseCase.swift`

| 메서드 | RequestValue | 용도 |
|--------|-------------|------|
| `execute` | `PointDate` | 데이터 목록 조회 |

---

## Query 객체

**파일:** `Domain/Entities/OceanQuery.swift`

```swift
struct RisaListQuery {
    let key: String      // API 키
    let id: String       // "risaList"
    let gruNam: String   // 그룹명 ("E": 동해)
}

struct RisaCodeQuery {
    let key: String
    let id: String
    let gruNam: String
    let useYn: String    // 사용여부 ("Y")
}

struct RisaCooQuery {
    let key: String
    let id: String
    let staCde: String   // 측정소 코드
}

struct OceanQuery {
    let key: String
    let staCde: String?
}
```

---

## 데이터 흐름

```
View (SwiftUI)
    ↓ 이벤트
ViewModel (@Published)
    ↓ 메서드 호출
UseCase
    ↓ execute()
Repository Protocol
    ↓ 구현체 호출
DefaultRepository
    ↓ 네트워크/로컬
DataTransferService / FileDataStorage
```
