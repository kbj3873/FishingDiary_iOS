# 커밋 메시지 생성 규칙

이 파일을 로드하면 아래 규칙에 따라 커밋 메시지를 자동 생성할 수 있습니다.

---

## 제목 형식

```
{타입}: {한 줄 요약}
```

**타입 목록**

| 타입 | 사용 시점 |
|---|---|
| `Feat` | 신규 기능 추가 |
| `Refactor` | 코드 구조 개편 (기능 변경 없음) |
| `Fix` | 버그 수정 |
| `Remove` | 파일/코드 삭제 |
| `Build` | 빌드 설정 변경 (Podfile, xcconfig 등) |
| `Docs` | 문서/가이드 추가 및 수정 |
| `Chore` | 기타 잡무 (설정 파일, .gitignore 등) |
| `Security` | 보안 관련 변경 |

---

## 본문 섹션 구성

변경 내용을 아래 섹션 중 해당하는 것만 골라서 작성합니다.

```
[레거시 제거]
- 삭제한 파일 또는 코드 목록

[Domain 레이어]
- 추가/수정된 Entity, Repository 인터페이스, UseCase

[Data 레이어]
- 추가/수정된 DTO, Repository 구현체, PersistentStorage

[Infrastructure]
- NetworkService, Endpoint 등 저수준 레이어 변경 사항

[Presentation]
- SwiftUI View, ViewModel, Component 변경 사항

[DI]
- ApplicationDIContainer 및 팩토리 메서드 변경 사항

[빌드 설정]
- Podfile, xcconfig, Info.plist, project.pbxproj 변경 사항

[프로젝트 가이드]
- CLAUDE.md, .agent/ 문서 변경 사항
```

---

## 꼬리말

```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

---

## 생성 예시 (이 세션 기준)

```
Refactor: SwiftUI 기반 Clean Architecture 전환 — 레거시 UIKit 제거 및 신규 구현

[레거시 제거]
- AppDelegate, SceneDelegate, HostingViewController 삭제
- Combine CurrentValueSubject 기반 옵저버 제거
- 구형 SeaWaterTemperature, PointScene 관련 뷰 정리

[Domain 레이어]
- Entity 신규: CurrentTemperature, WeeklyTemperature, Region, VersionStatus, FishingRecord
- Repository 인터페이스: OceanRepository, SplashRepository, FishingRecordRepository
- UseCase: OceanUseCase, SplashUseCase, FishingRecordUseCase

[Data 레이어]
- DTO 신규: RisaListDTO, RisaInfoDTO, RegionDTO, VersionCheckDTO
- Repository 구현체: DefaultOceanRepository, DefaultSplashRepository, DefaultFishingRecordRepository

[Infrastructure]
- NetworkService: URLSession 기반 async/await 전환
- Endpoint: baseURL 분리, 제네릭 응답 타입 적용

[Presentation]
- MainTabView, CurrentTemperatureView, SeaAnalysisView 신규
- FishingRecordView: KakaoMap UIViewControllerRepresentable 브릿징
- HistoryView, HistoryDetailView, HistoryImageViewer 신규

[DI]
- ApplicationDIContainer 신규: NIFS + OnBada 이중 NetworkService, 팩토리 메서드 전체
- AppConfiguration: apiNifsURL + apiOnbadaURL 이중 URL 관리

[빌드 설정]
- KakaoMapsSDK, Firebase 의존성 추가 (Podfile)
- KAKAO_APP_KEY, ApiOnbadaURL BuildConfig 추가 (Info.plist)

[프로젝트 가이드]
- CLAUDE.md, .agent/workflows/ 추가

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```
