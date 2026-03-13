#!/bin/bash

# convert_to_png.sh
# Requires: rsvg-convert (brew install librsvg)

# 스크립트의 현재 위치(.agent/workflows)를 기준으로 프로젝트 루트 디렉토리 동적 계산
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

ASSET_DIR="$PROJECT_ROOT/SeaThermo/Assets.xcassets"

# Function to convert SVG to PNG
convert_and_update() {
    local category=$1
    local asset_name=$2
    local width_pt=$3
    local height_pt=${4:-$width_pt}
    
    local svg_path="$ASSET_DIR/$category/$asset_name.imageset/$asset_name.svg"
    local imageset_dir="$ASSET_DIR/$category/$asset_name.imageset"
    
    if [ ! -f "$svg_path" ]; then
        echo "Error: SVG file not found at $svg_path"
        return
    fi
    
    echo "Converting $asset_name to PNGs (${width_pt}x${height_pt}pt)..."
    
    # Calculate pixel sizes for @2x and @3x
    local width_2x=$(($width_pt * 2))
    local height_2x=$(($height_pt * 2))
    
    local width_3x=$(($width_pt * 3))
    local height_3x=$(($height_pt * 3))
    
    # Convert to @2x PNG
    rsvg-convert -w $width_2x -h $height_2x -f png -o "$imageset_dir/${asset_name}@2x.png" "$svg_path"
    
    # Convert to @3x PNG
    rsvg-convert -w $width_3x -h $height_3x -f png -o "$imageset_dir/${asset_name}@3x.png" "$svg_path"
    
    # Update Contents.json
    cat > "$imageset_dir/Contents.json" <<EOF
{
  "images" : [
    {
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "${asset_name}@2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "${asset_name}@3x.png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    
    echo "Done: $asset_name"
    
    # Remove SVG file after conversion
    rm "$svg_path"
    echo "Ref: SVG file removed"
}

# Add asset conversions below
# Usage: convert_and_update "Folder" "Asset_Name" Width [Height]
convert_and_update "History" "trash_icon" 24
convert_and_update "History" "clock_icon" 16
convert_and_update "History" "distance_icon" 16
convert_and_update "History" "photo_icon" 16

# Map markers (Standard size 28x42)
convert_and_update "FishingRecord" "ic_map_marker_blue" 28 42
convert_and_update "FishingRecord" "ic_map_marker_orange" 28 42
convert_and_update "FishingRecord" "ic_map_marker_red" 28 42

# Onboarding guide icons (80pt - 파란색 원 안에 넣을 아이콘)
convert_and_update "Onboarding" "ic_onboarding_thermometer" 80
convert_and_update "Onboarding" "ic_onboarding_trending" 80
convert_and_update "Onboarding" "ic_onboarding_mappin" 80
convert_and_update "Onboarding" "ic_onboarding_history" 80
