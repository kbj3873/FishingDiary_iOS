---
description: Figma에서 SVG 에셋을 가져와 투명 배경 PNG로 변환하는 워크플로우
---

# Figma Asset Import Workflow

이 워크플로우는 Figma에서 벡터(SVG) 아이콘을 가져와 프로젝트 표준인 `Assets.xcassets`에 @2x, @3x PNG 형식으로 변환하여 추가하는 과정을 설명합니다.

## 1. Figma에서 에셋 가져오기
1.  Figma에서 내보낼 아이콘(Node)을 선택합니다.
2.  `get_design_context` 도구를 사용하여 선택된 노드의 정보를 가져옵니다.
3.  SVG URL이 확인되면 `read_url_content`로 SVG 원본 코드를 읽습니다.
4.  **검증**: 읽어온 SVG 코드가 예상한 아이콘 모양인지(예: path 데이터 간략 확인) 반드시 **시각적 또는 코드 레벨에서 검증**합니다. 잘못된 아이콘을 가져오는 실수를 방지하기 위함입니다.

## 2. Assets 폴더 구성 (분석 및 사용자 질의)
1.  **폴더 분석**: `SeaThermo/Assets.xcassets/` 내부를 확인하여 적절한 폴더(Category)가 있는지 분석합니다.
    *   예: `FishingRecord`, `History`, `SeaAnalysis` 등.
2.  **사용자 질의**: 적절한 폴더가 불분명하거나 새로운 기능인 경우, **"새 폴더를 생성할까요, 아니면 기존 폴더 중 어디에 저장할까요?"** 라고 사용자에게 먼저 물어봅니다.
3.  결정된 위치(`[Category]`) 하위에 `[asset_name].imageset` 폴더를 생성합니다.
2.  읽어온 SVG 코드를 해당 폴더 내에 `[asset_name].svg` 파일로 저장합니다.
    *   **주의**: 원본 SVG에 `fill="none"` 속성이 있거나 배경이 투명한지 확인하세요.

## 3. 변환 스크립트 업데이트
1.  `convert_to_png.sh` 파일을 엽니다.
2.  스크립트 하단에 새로운 에셋 변환 명령을 추가합니다.
    ```bash
    # 예시: 아이콘 이름 "ic_new_icon", 기준 사이즈 20pt
    convert_and_update "ic_new_icon" 20
    ```
3.  **참고**: 이 스크립트는 `rsvg-convert`를 사용하여 투명 배경을 완벽하게 유지하며 PNG를 생성합니다.

## 4. 변환 실행 및 검증
1.  터미널에서 스크립트를 실행합니다.
    ```bash
    ./convert_to_png.sh
    ```
2.  **검증**:
    *   각 `.imageset` 폴더에 `contents.json`, `[asset_name]@2x.png`, `[asset_name]@3x.png` 파일이 생성되었는지 확인합니다.
    *   생성된 PNG 파일이 흰색 배경 없이 **투명한지** 확인합니다.

## 5. 정리 (Cleanup) - **필수**
1.  변환이 성공적으로 완료되면, `.imageset` 폴더 내의 원본 **`.svg` 파일은 반드시 삭제**합니다.
    *   `convert_to_png.sh` 스크립트 실행 시 자동으로 삭제되도록 로직이 포함되어 있습니다.
    *   수동으로 진행할 경우 `rm` 명령어로 삭제하십시오.
    *   **이유**: Xcode 빌드 시 불필요한 파일을 제거하고 용량을 최적화하기 위함입니다.