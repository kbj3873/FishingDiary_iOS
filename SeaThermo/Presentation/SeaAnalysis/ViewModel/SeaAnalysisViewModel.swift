//
//  SeaAnalysisViewModel.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class SeaAnalysisViewModel: ObservableObject {
    private let oceanUseCase: OceanUseCase
    
    // UI State
    @Published var stationName: String = "완도 청산"
    
    // Card Data
    @Published var surfaceTemp: String = "17.0°"
    @Published var middleTemp: String = "16.1°"
    @Published var bottomTemp: String = "15.6°"
    
    // Graph Data
    @Published var graphData: [GraphData] = []
    @Published var graphDates: [String] = []
    
    init(oceanUseCase: OceanUseCase, stationName: String = "완도 청산") {
        self.oceanUseCase = oceanUseCase
        self.stationName = stationName
    }
    
    func fetchTemperatureData(gruNam: String = "S", staCde: String = "223") {
        // Calculate date range using shared extensions (yyyy-MM-dd)
        let obsFrom = Date.startTempDateString()
        let obsTo = Date.endTempDateString()
        
        let query = OceanQuery(
            id: "risaInfo",
            gruNam: gruNam,
            useYn: "Y",
            staCde: staCde,
            dataCnt: "",
            ord: "1",
            ordType: "A",
            obsFrom: obsFrom,
            obsTo: obsTo
        )
        
        Task {
            do {
                let response = try await oceanUseCase.fetchTemperature(query: query)
                self.processResponse(response.list)
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    private func processResponse(_ list: [Ocean]) {
        guard !list.isEmpty else { return }
        
        // 1. Sort by Date
        let sortedList = list.sorted { $0.dateT < $1.dateT }
        
        // 2. Extract Data for Graph
        // Using all data points for smooth curve, or sampling if too many
        // Assuming list contains 30-min interval data
        
        let surfaceValues = sortedList.map { CGFloat($0.wtrTempS) }
        let middleValues = sortedList.map { CGFloat($0.wtrTempM) }
        let bottomValues = sortedList.map { CGFloat($0.wtrTempB) }
        
        // 3. Extract Dates for X-Axis (Unique Days)
        var dates: [String] = []
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "M/d"
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMddHHmm"
        
        let uniqueDays = Set(sortedList.map { String(String($0.dateT).prefix(8)) }).sorted()
        
        for dayStr in uniqueDays {
             if let date = DateFormatter().date(from: dayStr) { // Simplified parsing
                 // Logic to format date string if needed, or just take substring
                 let month = dayStr.dropFirst(4).prefix(2)
                 let day = dayStr.dropFirst(6).prefix(2)
                 dates.append("\(Int(month)!)/\(Int(day)!)")
             } else {
                 // Manual fallback
                 let month = dayStr.dropFirst(4).prefix(2)
                 let day = dayStr.dropFirst(6).prefix(2)
                 dates.append("\(Int(month)!)/\(Int(day)!)")
             }
        }
        
        self.graphDates = dates
        
        self.graphData = [
            GraphData(values: surfaceValues, color: .blue),
            GraphData(values: middleValues, color: .purple),
            GraphData(values: bottomValues, color: .green)
        ]
        
        // 4. Update Cards (Latest Data)
        if let last = sortedList.last {
            surfaceTemp = String(format: "%.1f°", last.wtrTempS)
            middleTemp = String(format: "%.1f°", last.wtrTempM)
            bottomTemp = String(format: "%.1f°", last.wtrTempB)
        }
    }
}
