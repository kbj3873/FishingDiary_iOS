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

final class HistoryViewModel: ObservableObject {
    @Published var records: [HistoryRecordItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var path = NavigationPath() // iOS 16+
    
    public let useCase: FishingRecordUseCase
    private var cancellable: Cancellable?
    
    init(useCase: FishingRecordUseCase) {
        self.useCase = useCase
    }
    
    func loadRecords() {
        isLoading = true
        errorMessage = nil
        
        cancellable = useCase.fetchAllRecords { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let fishingRecords):
                    self?.records = self?.groupAndConvert(fishingRecords) ?? []
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
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
        
        // 지점 수 (상태 마커 + 사진 마커)
        // 1. 상태 변경 마커 수 계산 (HistoryDetailViewModel 로직 참조)
        var stateMarkerCount = 0
        var lastState: Int?
        
        for record in sortedRecords {
            if let last = lastState, last != record.state {
                stateMarkerCount += 1
            }
            lastState = record.state
        }
        
        // 2. 사진 마커 수 (이미지가 있는 레코드 수 * 각 레코드의 이미지 수 -> 사실상 전체 이미지 수)
        // HistoryDetailViewModel에서는 각 이미지마다 마커를 생성하므로 전체 이미지 개수와 동일
        let photoCount = sortedRecords.reduce(0) { $0 + $1.imagePaths.count }
        
        // 총 지점 수 = 상태 변경 횟수 + 사진 개수
        let pointCount = stateMarkerCount + photoCount
        
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
        cancellable = useCase.fetchAllRecords { [weak self] result in
            guard let self = self else { return }
            
            var baseRecord: FishingRecord
            
            if case .success(let records) = result, let first = records.first(where: { !$0.imagePaths.isEmpty }) ?? records.first {
                baseRecord = first
            } else {
                // 데이터가 하나도 없으면 기본값으로 생성
                baseRecord = FishingRecord(
                    id: UUID().uuidString,
                    sessionId: UUID().uuidString,
                    date: Date(),
                    location: (37.5665, 126.9780),
                    speed: 0.0,
                    state: 2, // Fishing
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
            
            // 이미지가 없으면 임의의 컬러 이미지 생성
            if dummyImageData == nil {
                dummyImageData = self.createDummyImage()
            }
            
            guard let imageData = dummyImageData else {
                // 이미지 생성 실패 시 그냥 진행
                self.createSessionsWithoutPhotos(baseRecord: baseRecord)
                return
            }
            
            // 2. 20개의 세션 생성
            let calendar = Calendar.current
            
            // 비동기로 저장 (UI 멈춤 방지) -> Realm 쓰기가 메인쓰레드 블락할 수 있으므로 주의.
            // 여기서는 단순함을 위해 for문으로 처리하되, 사진 저장은 약간의 딜레이나 동기 처리가 섞일 수 있음.
            
            DispatchQueue.global(qos: .userInitiated).async {
                for i in 1...3 {
                    // 날짜를 하루씩 뺌
                    let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
                    let sessionId = UUID().uuidString
                    
                    // 각 세션당 3개의 기록 포인트 생성
                    for j in 0..<3 {
                        // 시간차를 조금씩 둠
                        let pointDate = date.addingTimeInterval(Double(j * 600)) // 10분 간격
                        
                        self.useCase.savePoint(
                            sessionId: sessionId,
                            latitude: baseRecord.location.latitude + Double.random(in: -0.01...0.01),
                            longitude: baseRecord.location.longitude + Double.random(in: -0.01...0.01),
                            speed: Double.random(in: 0...10),
                            state: Int.random(in: 0...2),
                            timestamp: pointDate
                        )
                    }
                    
                    // 사진 4장 추가
                    for _ in 0..<4 {
                        _ = self.useCase.savePhoto(
                            sessionId: sessionId,
                            image: imageData,
                            location: (baseRecord.location.latitude, baseRecord.location.longitude),
                            state: 2
                        )
                    }
                }
                
                // 3. 완료 후 리로드
                DispatchQueue.main.async {
                    self.loadRecords()
                }
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

