//
//  SeaAnalysisDetailViewModel.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import Foundation
import Combine
import SwiftUI

final class SeaAnalysisDetailViewModel: ObservableObject {
    private let oceanUseCase: OceanUseCase
    private let station: ObservatoryInfo
    private var cancellables = Set<AnyCancellable>()
    
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
    
    // Visibility Flags
    @Published var hasSurfaceData: Bool = false
    @Published var hasMiddleData: Bool = false
    @Published var hasBottomData: Bool = false
    
    var hasAnyData: Bool {
        hasSurfaceData || hasMiddleData || hasBottomData
    }
    
    // Graph Data
    @Published var graphData: [GraphData] = []
    @Published var graphDates: [String] = []
    
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
        let query = OceanQuery(
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
        
        oceanUseCase.excute(requestValue: .init(query: query)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.processResponse(response.list)
                case .failure(let error):
                    print("Error fetching data: \(error)")
                    // Handle error state or retry logic if needed
                }
            }
        }
    }
    
    private func processResponse(_ list: [Ocean]) {
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
        
        // Map Response Data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        
        var dataMap: [Date: Ocean] = [:]
        for item in sortedList {
            let dateStr = String(item.dateT)
            if let date = dateFormatter.date(from: dateStr) {
                dataMap[date] = item
            }
        }
        
        // Helper for Linear Interpolation
        func interpolate(dates: [Date], valuePath: KeyPath<Ocean, Float>) -> [CGFloat] {
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
        
        // 3. Extract Dates for X-Axis Labels (7 Days)
        var dates: [String] = []
        let labelFormatter = DateFormatter()
        labelFormatter.dateFormat = "MM/dd"
        
        // Generate labels for D0 to D6
        for i in 0..<7 {
            if let d = calendar.date(byAdding: .day, value: i, to: startDate) {
                dates.append(labelFormatter.string(from: d))
            }
        }
        
        self.graphDates = dates
        
        self.graphData = [
            GraphData(values: surfaceValues, color: .blue),
            GraphData(values: middleValues, color: .purple),
            GraphData(values: bottomValues, color: .green)
        ]
        
        // 4. Update Cards (Latest Data) & Calculate Min/Max & Visibility
        if let last = sortedList.last {
            // Surface
            let validSurface = surfaceValues.filter { $0 > 0 }
            hasSurfaceData = !validSurface.isEmpty
            if hasSurfaceData {
                surfaceTemp = String(format: "%.1f°", last.wtrTempS)
                surfaceMax = String(format: "%.1f", validSurface.max() ?? 0)
                surfaceMin = String(format: "%.1f", validSurface.min() ?? 0)
            } else {
                surfaceTemp = "-"
                surfaceMax = "-"
                surfaceMin = "-"
            }
            
            // Middle
            let validMiddle = middleValues.filter { $0 > 0 }
            hasMiddleData = !validMiddle.isEmpty
            if hasMiddleData {
                middleTemp = String(format: "%.1f°", last.wtrTempM)
                middleMax = String(format: "%.1f", validMiddle.max() ?? 0)
                middleMin = String(format: "%.1f", validMiddle.min() ?? 0)
            } else {
                middleTemp = "-"
                middleMax = "-"
                middleMin = "-"
            }
            
            // Bottom
            let validBottom = bottomValues.filter { $0 > 0 }
            hasBottomData = !validBottom.isEmpty
            if hasBottomData {
                bottomTemp = String(format: "%.1f°", last.wtrTempB)
                bottomMax = String(format: "%.1f", validBottom.max() ?? 0)
                bottomMin = String(format: "%.1f", validBottom.min() ?? 0)
            } else {
                bottomTemp = "-"
                bottomMax = "-"
                bottomMin = "-"
            }
        }
    }
}
