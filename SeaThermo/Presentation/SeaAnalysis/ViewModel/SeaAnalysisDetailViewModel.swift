//
//  SeaAnalysisDetailViewModel.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class SeaAnalysisDetailViewModel: ObservableObject {
    private let oceanUseCase: OceanUseCase
    private let station: ObservatoryInfo
    
    // UI State
    @Published var stationName: String
    // Card Data
    @Published var surfaceTemp: String = "-"
    @Published var middleTemp: String = "-"
    @Published var bottomTemp: String = "-"
    
    // Min/Max Data
    @Published var surfaceMax: String = "-"
    @Published var surfaceMin: String = "-"
    @Published var middleMax: String = "-"
    @Published var middleMin: String = "-"
    @Published var bottomMax: String = "-"
    @Published var bottomMin: String = "-"
    
    // 수심 데이터
    @Published var surfaceDepth: String = "-"
    @Published var middleDepth: String = "-"
    @Published var bottomDepth: String = "-"
    
    // Visibility Flags
    @Published var hasSurfaceData: Bool = false
    @Published var hasMiddleData: Bool = false
    @Published var hasBottomData: Bool = false
    
    var hasAnyData: Bool {
        hasSurfaceData || hasMiddleData || hasBottomData
    }
    
    // Graph Data
    @Published var graphData: [GraphData] = []
    @Published var graphTicks: [GraphAxisTick] = []
    @Published var selectedGraphTimeScale: GraphTimeScale = .daily {
        didSet {
            updateGraphTicks()
        }
    }

    var graphSubtitle: String {
        selectedGraphTimeScale.subtitle
    }

    private var graphSampleDates: [Date] = []
    
    init(oceanUseCase: OceanUseCase, station: ObservatoryInfo) {
        self.oceanUseCase = oceanUseCase
        self.station = station
        self.stationName = station.name
    }
    
    func fetchTemperatureData() {
        // Calculate date range using shared extensions (yyyy-MM-dd)
        let obsFrom = Date.startTempDateString()
        let obsTo = Date.endTempDateString()
        
        // Use station info for query
        let query = SeaAnalysisQuery(
            id: "risaInfo",
            gruNam: station.sea.id, // "W", "E", "S"
            useYn: "Y",
            staCde: station.id,     // Specific Station Code
            dataCnt: "",
            ord: "1",
            ordType: "A",
            obsFrom: obsFrom,
            obsTo: obsTo
        )
        
        Task {
            do {
                let weeklyTemperatures = try await oceanUseCase.fetchTemperature(query)
                self.processResponse(weeklyTemperatures)
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    private func processResponse(_ list: [WeeklyTemperature]) {
        guard !list.isEmpty else { return }
        
        // 1. Sort by Date
        let sortedList = list.sorted { $0.dateT < $1.dateT }
        
        // 2. Extract Data for Graph (Time-Based Filling with Interpolation)
        let now = Date()
        let calendar = Calendar.current
        
        // Calculate Date Range (Last 7 Days ~ Today End)
        // Ensure Start is 00:00:00
        let todayStart = calendar.startOfDay(for: now)
        // Start: 6 days ago 00:00
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: todayStart) else { return }
        
        // Generate Expected Timestamps (Every 30 mins)
        // Total points = 7 days * 48 points/day + 1 (last 00:00) = 337 points
        var expectedDates: [Date] = []
        for i in 0..<337 {
            if let date = calendar.date(byAdding: .minute, value: i * 30, to: startDate) {
                expectedDates.append(date)
            }
        }
        self.graphSampleDates = expectedDates
        
        // Map Response Data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        
        var dataMap: [Date: WeeklyTemperature] = [:]
        for item in sortedList {
            let dateStr = String(item.dateT)
            if let date = dateFormatter.date(from: dateStr) {
                dataMap[date] = item
            }
        }
        
        // Helper for Linear Interpolation
        func interpolate(dates: [Date], valuePath: KeyPath<WeeklyTemperature, Float>) -> [CGFloat] {
            var result: [CGFloat] = []
            
            // Temporary array with nils
            var rawValues: [CGFloat?] = dates.map { date in
                if let item = dataMap[date] {
                    return CGFloat(item[keyPath: valuePath])
                }
                return nil
            }
            
            // Perform Interpolation
            for i in 0..<rawValues.count {
                if rawValues[i] != nil {
                    // Valid data, keep it
                    continue
                }
                
                // If it's future data, fill with -99 (Hidden)
                if dates[i] > now {
                    rawValues[i] = -99.0
                    continue
                }
                
                // Missing past data: Interpolate
                // Find previous valid index
                var prevIndex: Int? = nil
                for p in stride(from: i - 1, through: 0, by: -1) {
                    if let val = rawValues[p], val != -99.0, val != -90.0 {
                        prevIndex = p
                        break
                    }
                }
                
                // Find next valid index
                var nextIndex: Int? = nil
                for n in (i + 1)..<rawValues.count {
                    if let val = rawValues[n], val != -99.0, val != -90.0 { // Don't interpolate with future dummy or gaps
                        nextIndex = n
                        break
                    }
                    if dates[n] > now { // Stop searching if we hit future
                        break
                    }
                }
                
                if let p = prevIndex, let n = nextIndex, let pVal = rawValues[p], let nVal = rawValues[n] {
                    // Check Threshold (12 hours = 24 points)
                    if (n - p) > 24 {
                        rawValues[i] = -90.0 // Too far apart, do not interpolate
                    } else {
                        // Linear Interpolation
                        let totalSteps = CGFloat(n - p)
                        let currentStep = CGFloat(i - p)
                        let interpolated = pVal + (nVal - pVal) * (currentStep / totalSteps)
                        rawValues[i] = interpolated
                    }
                } else if let p = prevIndex, let pVal = rawValues[p] {
                     // No next value (end of data but before now)
                     // If distance is explicitly far (e.g. data stopped long ago), cut it.
                     if (i - p) > 24 {
                         rawValues[i] = -90.0
                     } else {
                         rawValues[i] = pVal
                     }
                } else if let n = nextIndex, let nVal = rawValues[n] {
                    // No previous value (start of chart)
                    if (n - i) > 24 {
                         rawValues[i] = -90.0
                     } else {
                         rawValues[i] = nVal
                     }
                } else {
                    // No data at all nearby
                    rawValues[i] = -90.0 // Fallback to gap
                }
            }
            
            return rawValues.compactMap { $0 }
        }
        
        let surfaceValues = interpolate(dates: expectedDates, valuePath: \.wtrTempS)
        let middleValues = interpolate(dates: expectedDates, valuePath: \.wtrTempM)
        let bottomValues = interpolate(dates: expectedDates, valuePath: \.wtrTempB)
        
        self.graphData = [
            GraphData(values: surfaceValues, color: .blue),
            GraphData(values: middleValues, color: .purple),
            GraphData(values: bottomValues, color: .green)
        ]
        updateGraphTicks(referenceDate: now)
        
        // 4. 카드 데이터 업데이트 (최신 유효 데이터) & 최고/최저 & 가시성
        if !sortedList.isEmpty {
            // 각 수층별 마지막 유효 데이터 찾기 (API에서 -99.0은 데이터 없음을 의미)
            let lastValidSurface = sortedList.last(where: { $0.wtrTempS > 0 })
            let lastValidMiddle = sortedList.last(where: { $0.wtrTempM > 0 })
            let lastValidBottom = sortedList.last(where: { $0.wtrTempB > 0 })
            
            let validSurface = surfaceValues.filter { $0 > -10.0 && $0 < 50.0 } // -99.0 이나 -90.0 같은 더미/오류 데이터 필터링
            hasSurfaceData = !validSurface.isEmpty
            if hasSurfaceData, let validData = lastValidSurface {
                surfaceTemp = String(format: "%.1f°", validData.wtrTempS)
                surfaceMax = String(format: "%.1f", validSurface.max() ?? 0)
                surfaceMin = String(format: "%.1f", validSurface.min() ?? 0)
                surfaceDepth = validData.surDep > 0 ? "수심 \(Int(validData.surDep))m" : "-"
            } else {
                surfaceTemp = "-"
                surfaceMax = "-"
                surfaceMin = "-"
                surfaceDepth = "-"
            }
            
            // Middle (중층)
            let validMiddle = middleValues.filter { $0 > -10.0 && $0 < 50.0 }
            hasMiddleData = !validMiddle.isEmpty
            if hasMiddleData, let validData = lastValidMiddle {
                middleTemp = String(format: "%.1f°", validData.wtrTempM)
                middleMax = String(format: "%.1f", validMiddle.max() ?? 0)
                middleMin = String(format: "%.1f", validMiddle.min() ?? 0)
                middleDepth = validData.midDep > 0 ? "수심 \(Int(validData.midDep))m" : "-"
            } else {
                middleTemp = "-"
                middleMax = "-"
                middleMin = "-"
                middleDepth = "-"
            }
            
            // Bottom (저층)
            let validBottom = bottomValues.filter { $0 > -10.0 && $0 < 50.0 }
            hasBottomData = !validBottom.isEmpty
            if hasBottomData, let validData = lastValidBottom {
                bottomTemp = String(format: "%.1f°", validData.wtrTempB)
                bottomMax = String(format: "%.1f", validBottom.max() ?? 0)
                bottomMin = String(format: "%.1f", validBottom.min() ?? 0)
                bottomDepth = validData.botDep > 0 ? "수심 \(Int(validData.botDep))m" : "-"
            } else {
                bottomTemp = "-"
                bottomMax = "-"
                bottomMin = "-"
                bottomDepth = "-"
            }
        }
    }

    private func updateGraphTicks(referenceDate: Date = Date()) {
        guard !graphSampleDates.isEmpty else {
            graphTicks = []
            return
        }

        let samplesPerHour = 2
        let step = max(selectedGraphTimeScale.hourInterval * samplesPerHour, 1)
        let dailyFormatter = DateFormatter()
        dailyFormatter.locale = Locale(identifier: "ko_KR")
        dailyFormatter.dateFormat = "M/d"

        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.locale = Locale(identifier: "ko_KR")
        dateTimeFormatter.dateFormat = "M/d\nHH시"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "HH시"

        let calendar = Calendar.current

        var ticks: [GraphAxisTick] = []
        for index in stride(from: 0, to: graphSampleDates.count, by: step) {
            let date = graphSampleDates[index]
            if date > referenceDate {
                if selectedGraphTimeScale != .daily,
                   calendar.isDate(date, inSameDayAs: referenceDate) {
                    ticks.append(GraphAxisTick(
                        sampleIndex: index,
                        label: tickLabel(for: date,
                                         calendar: calendar,
                                         dailyFormatter: dailyFormatter,
                                         dateTimeFormatter: dateTimeFormatter,
                                         timeFormatter: timeFormatter)
                    ))
                }
                break
            }

            ticks.append(GraphAxisTick(
                sampleIndex: index,
                label: tickLabel(for: date,
                                 calendar: calendar,
                                 dailyFormatter: dailyFormatter,
                                 dateTimeFormatter: dateTimeFormatter,
                                 timeFormatter: timeFormatter)
            ))
        }

        if ticks.isEmpty {
            ticks.append(GraphAxisTick(
                sampleIndex: 0,
                label: tickLabel(for: graphSampleDates[0],
                                 calendar: calendar,
                                 dailyFormatter: dailyFormatter,
                                 dateTimeFormatter: dateTimeFormatter,
                                 timeFormatter: timeFormatter)
            ))
        }

        graphTicks = ticks
    }

    private func tickLabel(for date: Date,
                           calendar: Calendar,
                           dailyFormatter: DateFormatter,
                           dateTimeFormatter: DateFormatter,
                           timeFormatter: DateFormatter) -> String {
        if selectedGraphTimeScale == .daily {
            return dailyFormatter.string(from: date)
        }

        if calendar.component(.hour, from: date) == 0 {
            return dateTimeFormatter.string(from: date)
        }

        return timeFormatter.string(from: date)
    }
}
