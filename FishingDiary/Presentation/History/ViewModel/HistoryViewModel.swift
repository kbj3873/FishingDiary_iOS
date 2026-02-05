//
//  HistoryViewModel.swift
//  FishingDiary
//
//  Created by Gemini on 2/4/26.
//

import Foundation
import Combine

/// 히스토리 화면에 표시할 기록 모델
struct HistoryRecordItem: Identifiable {
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
    
    private let useCase: FishingRecordUseCase
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
        
        // 지점 수
        let pointCount = sortedRecords.count
        
        // 사진 수
        let photoCount = sortedRecords.reduce(0) { $0 + $1.imagePaths.count }
        
        // 소요 시간
        let durationInterval = lastRecord.date.timeIntervalSince(firstRecord.date)
        let hours = Int(durationInterval) / 3600
        let minutes = (Int(durationInterval) % 3600) / 60
        let seconds = Int(durationInterval) % 60
        
        let duration: String
        if hours >= 1 {
            // 1시간 이상: X시간 Y분
            duration = "\(hours)시간 \(minutes)분"
        } else if minutes >= 1 {
            // 1시간 미만, 1분 이상: mm분 ss초
            duration = "\(minutes)분 \(seconds)초"
        } else {
            // 1분 미만: ss초
            duration = "\(seconds)초"
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
}

