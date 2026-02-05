---
description: 프로젝트 도메인 구조, 엔티티, 및 기존 컴포넌트 요약
---

# Project Structure & Context

이 문서는 프로젝트의 도메인 지식과 기존 컴포넌트 현황을 요약합니다. 구현 전 중복 방지를 위해 확인하세요.

## 1. Domain Entities (핵심 데이터)

*   **Ocean**: 해양 측정소 정보 (`surTempurature`(표층), `midTempurature`(중층) 등).
*   **PointMap**: 지도 표시용 데이터. `MapPin`(Apple), `KakaoMapPin`(Kakao) 존재.
*   **LocationData**: 위도/경도, 속도, 시간 정보.
*   **PointDate/PointData**: 날짜별/개별 포인트 파일 관리 구조.

## 2. Component Index (UI 컴포넌트)

### Main Scene
*   `MainView`: 메인 수온 리스트.
*   `OceanSelectView`: 측정소 선택 화면.

### Point Scene (지도)
*   `ApplePointMapView` / `KakaoPointMapView`: 듀얼 맵 시스템 지원.
*   `PointInfoView`: 지도 위 팝업 패널.
*   `PointDateListUIView`: 포인트 날짜 목록.

### Sea Water Temperature
*   `SeaWaterTemperatureView`: 수온 상세 및 그래프 화면.

## 3. Architecture Pattern
*   **MVVM + Clean Architecture**: `View` -> `ViewModel` -> `UseCase` -> `Repository`
*   **DI**: `DIContainer`를 통해 의존성 주입.
