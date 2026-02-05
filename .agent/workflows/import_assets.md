---
description: Figma에서 SVG 에셋을 가져와 투명 배경 PNG로 변환하는 워크플로우
---

# Figma Asset Import Workflow

이 워크플로우는 Figma에서 벡터(SVG) 아이콘을 가져와 프로젝트 표준인 `Assets.xcassets`에 @2x, @3x PNG 형식으로 변환하여 추가하는 과정을 설명합니다.

## 1. Figma에서 에셋 가져오기
1.  Figma에서 내보낼 아이콘(Node)을 선택합니다.
2.  `get_design_context` 도구를 사용하여 선택된 노드의 정보를 가져옵니다.
3.  SVG URL이 확인되면 `read_url_content`로 SVG 원본 코드를 읽습니다.

## 2. Assets 폴더 구성
1.  `FishingDiary/Assets.xcassets/FishingRecord/` (또는 적절한 카테고리 폴더) 하위에 `[asset_name].imageset` 폴더를 생성합니다.
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

## 5. 정리 (Cleanup)
1.  변환이 성공적으로 완료되면, `.imageset` 폴더 내의 원본 **`.svg` 파일은 삭제**합니다.
    *   이유: Xcode가 이미지를 처리할 때 PNG를 우선 사용하도록 하고, 불필요한 파일 용량을 줄이기 위함입니다.
