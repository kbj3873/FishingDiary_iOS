//
//  HistoryRecordCardView.swift
//  FishingDiary
//
//  Created by Gemini on 2/4/26.
//

import SwiftUI

/// 히스토리 리스트의 개별 카드 뷰
struct HistoryRecordCardView: View {
    let item: HistoryRecordItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 썸네일 이미지
            thumbnailView
            
            // 정보 영역
            VStack(alignment: .leading, spacing: 4) {
                // 날짜 + 출발시간
                HStack(spacing: 8) {
                    Text(item.formattedDate)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1F2937"))
                    
                    Text("•")
                        .foregroundColor(Color(hex: "9CA3AF"))
                    
                    Text(item.startTime)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                
                // 메타데이터
                HStack(spacing: 8) {
                    // 지점 수
                    Label {
                        Text("\(item.pointCount)지점")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B7280"))
                    } icon: {
                        Image(systemName: "mappin.circle")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9CA3AF"))
                    }
                    
                    // 사진 수
                    Label {
                        Text("\(item.photoCount)장")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B7280"))
                    } icon: {
                        Image(systemName: "photo")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9CA3AF"))
                    }
                    
                    // 소요 시간
                    Label {
                        Text(item.duration)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B7280"))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    } icon: {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9CA3AF"))
                    }
                }
            }
            
            Spacer()
            
            // 화살표
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "D1D5DB"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Thumbnail View
    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnailPath = item.thumbnailPath,
           let image = loadImage(from: thumbnailPath) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            // 기본 플레이스홀더
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "E5E7EB"))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "fish")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "9CA3AF"))
            }
        }
    }
    
    // MARK: - Helper
    private func loadImage(from path: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(path)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

#Preview {
    HistoryRecordCardView(item: HistoryRecordItem(
        id: "1",
        date: Date(),
        startTime: "17:38 출발",
        pointCount: 30,
        photoCount: 2,
        duration: "0시간 2분",
        thumbnailPath: nil
    ))
    .padding()
    .background(Color(hex: "F2F2F7"))
}
