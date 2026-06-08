//
//  HistoryViewModel.swift
//  SeaThermo
//
//  Created by Gemini on 2/4/26.
//

import Foundation
import Combine
import UIKit
import SwiftUI

/// 히스토리 화면에 표시할 기록 모델
struct HistoryRecordItem: Identifiable, Hashable {
    let id: String
    let date: Date
    let startTime: String          // "17:38 출발" 형식
    let pointCount: Int            // 저장 지점 수
    let photoCount: Int            // 사진 수
    let duration: String           // "0시간 2분" 형식
    let thumbnailPath: String?     // 첫 번째 사진 경로
    
    /// 날짜 포맷 (2026.01.21)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var records: [HistoryRecordItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var path = NavigationPath() // iOS 16+
    
    public let useCase: FishingRecordUseCase
    
    init(useCase: FishingRecordUseCase) {
        self.useCase = useCase
    }
    
    func loadRecords() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fishingRecords = try await useCase.fetchAllRecords()
                self.isLoading = false
                self.records = self.groupAndConvert(fishingRecords)
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// 세션 ID별로 기록들을 그룹화하여 HistoryRecordItem으로 변환
    /// 세션 ID가 없는 기존 데이터는 날짜별로 그룹화
    private func groupAndConvert(_ records: [FishingRecord]) -> [HistoryRecordItem] {
        let calendar = Calendar.current
        
        // 세션 ID가 있는 기록과 없는 기록 분리
        var groupedBySession: [String: [FishingRecord]] = [:]
        var groupedByDate: [Date: [FishingRecord]] = [:]
        
        for record in records {
            if !record.sessionId.isEmpty {
                // 세션 ID가 있는 경우: 세션별로 그룹화
                if groupedBySession[record.sessionId] == nil {
                    groupedBySession[record.sessionId] = []
                }
                groupedBySession[record.sessionId]?.append(record)
            } else {
                // 세션 ID가 없는 경우 (기존 데이터): 날짜별로 그룹화
                let startOfDay = calendar.startOfDay(for: record.date)
                if groupedByDate[startOfDay] == nil {
                    groupedByDate[startOfDay] = []
                }
                groupedByDate[startOfDay]?.append(record)
            }
        }
        
        var items: [HistoryRecordItem] = []
        
        // 세션별 아이템 생성
        for (sessionId, sessionRecords) in groupedBySession {
            if let item = createHistoryItem(from: sessionRecords, id: sessionId) {
                items.append(item)
            }
        }
        
        // 날짜별 아이템 생성 (기존 데이터용)
        for (date, dayRecords) in groupedByDate {
            let dateId = "legacy_\(date.timeIntervalSince1970)"
            if let item = createHistoryItem(from: dayRecords, id: dateId) {
                items.append(item)
            }
        }
        
        // 날짜 내림차순 정렬 (최신순)
        return items.sorted { $0.date > $1.date }
    }
    
    /// 기록 배열로부터 HistoryRecordItem 생성
    private func createHistoryItem(from records: [FishingRecord], id: String) -> HistoryRecordItem? {
        let sortedRecords = records.sorted { $0.date < $1.date }
        
        guard let firstRecord = sortedRecords.first,
              let lastRecord = sortedRecords.last else { return nil }
        
        // 출발 시간
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let startTime = "\(timeFormatter.string(from: firstRecord.date)) 출발"
        
        // 지점 수 (시작/종료 + 상태 마커 + 사진 마커)
        // 상태 마커는 live 기록 화면과 동일하게 시작 record를 제외하고,
        // 이동중 -> 탐색/낚시 전환만 지점으로 계산한다.
        var stateMarkerCount = 0
        var lastState: Int?
        
        for (index, record) in sortedRecords.enumerated() {
            guard index > 0 else { continue }

            if let last = lastState, last == 0, record.state != 0 {
                stateMarkerCount += 1
            }
            lastState = record.state
        }
        
        // 2. 사진 마커 수 (이미지가 있는 레코드 수 * 각 레코드의 이미지 수 -> 사실상 전체 이미지 수)
        // HistoryDetailViewModel에서는 각 이미지마다 마커를 생성하므로 전체 이미지 개수와 동일
        let photoCount = sortedRecords.reduce(0) { $0 + $1.imagePaths.count }
        
        // 총 지점 수 = 시작/종료 + 상태 변경 + 사진 개수
        let boundaryMarkerCount = sortedRecords.count > 1 ? 2 : 1
        let pointCount = boundaryMarkerCount + stateMarkerCount + photoCount
        
        // 소요 시간 (hh시간 mm분 포맷으로 통일)
        let durationInterval = lastRecord.date.timeIntervalSince(firstRecord.date)
        let hours = Int(durationInterval) / 3600
        let minutes = (Int(durationInterval) % 3600) / 60
        
        let duration: String
        if hours > 0 {
            duration = String(format: "%d시간 %d분", hours, minutes)
        } else {
            duration = String(format: "%d분", minutes)
        }
        
        // 첫 번째 사진 경로
        let thumbnailPath = sortedRecords.first(where: { !$0.imagePaths.isEmpty })?.imagePaths.first
        
        return HistoryRecordItem(
            id: id,
            date: firstRecord.date,
            startTime: startTime,
            pointCount: pointCount,
            photoCount: photoCount,
            duration: duration,
            thumbnailPath: thumbnailPath
        )
    }


    // MARK: - Test Data
    func generateTestData() {
        isLoading = true
        
        // 1. 기존 데이터 하나 가져오기 (없으면 가짜 데이터 생성)
        Task {
            do {
                let records = try await useCase.fetchAllRecords()
                var baseRecord: FishingRecord
                
                if let first = records.first(where: { !$0.imagePaths.isEmpty }) ?? records.first {
                    baseRecord = first
                } else {
                    baseRecord = FishingRecord(
                        id: UUID().uuidString,
                        sessionId: UUID().uuidString,
                        date: Date(),
                        location: (37.5665, 126.9780),
                        speed: 0.0,
                        state: 2,
                        imagePaths: []
                    )
                }
                
                // 이미지 데이터 준비
                var dummyImageData: Data?
                
                if let firstPath = baseRecord.imagePaths.first {
                    let fullPath = self.getFullImagePath(from: firstPath)
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) {
                        dummyImageData = data
                    }
                }
                
                if dummyImageData == nil {
                    dummyImageData = self.createDummyImage()
                }
                
                guard let imageData = dummyImageData else {
                    self.createSessionsWithoutPhotos(baseRecord: baseRecord)
                    return
                }
                
                let calendar = Calendar.current
                
                for i in 1...3 {
                    let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
                    let sessionId = UUID().uuidString
                    
                    for j in 0..<3 {
                        let pointDate = date.addingTimeInterval(Double(j * 600))
                        
                        self.useCase.savePoint(
                            sessionId: sessionId,
                            latitude: baseRecord.location.latitude + Double.random(in: -0.01...0.01),
                            longitude: baseRecord.location.longitude + Double.random(in: -0.01...0.01),
                            speed: Double.random(in: 0...10),
                            state: Int.random(in: 0...2),
                            timestamp: pointDate
                        )
                    }
                    
                    for _ in 0..<4 {
                        _ = self.useCase.savePhoto(
                            sessionId: sessionId,
                            image: imageData,
                            location: (baseRecord.location.latitude, baseRecord.location.longitude),
                            state: 2
                        )
                    }
                }
                
                self.loadRecords()
            } catch {
                self.isLoading = false
            }
        }
    }
    
    private func createSessionsWithoutPhotos(baseRecord: FishingRecord) {
        // 이미지가 없을 경우 위와 동일한 로직(사진 저장 제외) 실행 or 그냥 리턴
        // 복잡도 줄이기 위해 여기서는 구현 생략하고 메인 로직에 통합
    }
    
    private func getFullImagePath(from path: String) -> String {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return path }
        let fileName = (path as NSString).lastPathComponent
        return documentsURL.appendingPathComponent(fileName).path
    }
    
    private func createDummyImage() -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let image = renderer.image { ctx in
            // 랜덤 색상
            UIColor(
                red: CGFloat.random(in: 0...1),
                green: CGFloat.random(in: 0...1),
                blue: CGFloat.random(in: 0...1),
                alpha: 1.0
            ).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
            
            // 텍스트 추가
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20),
                .foregroundColor: UIColor.white
            ]
            "Test Image".draw(at: CGPoint(x: 50, y: 90), withAttributes: attrs)
        }
        return image.jpegData(compressionQuality: 0.8)
    }
}
