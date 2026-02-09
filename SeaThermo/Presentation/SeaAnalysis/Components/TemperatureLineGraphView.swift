//
//  TemperatureLineGraphView.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct GraphData {
    let values: [CGFloat]
    let color: Color
}

struct TemperatureLineGraphView: View {
    let dataSets: [GraphData]
    let dates: [String] // X-axis labels
    
    // Dynamic calculation for scale
    private var allValues: [CGFloat] {
        dataSets.flatMap { $0.values }
    }
    
    private var minTemp: CGFloat {
        allValues.filter { $0 > 0 }.min() ?? 0
    }
    
    private var maxTemp: CGFloat {
        allValues.max() ?? 20
    }
    
    // Padding constants for design alignment
    private let topPadding: CGFloat = 2
    private let bottomPadding: CGFloat = 36
    
    var body: some View {
        GeometryReader { geometry in
            let validValues = allValues.filter { $0 > 0 }
            
            if validValues.isEmpty {
                emptyView
            } else {
                ZStack(alignment: .topLeading) {
                    // 1. Background Grid & Axis
                    graphBackground(in: geometry.size)
                    
                    // 2. Lines
                    ForEach(0..<dataSets.count, id: \.self) { index in
                        lineGraph(in: geometry.size, data: dataSets[index])
                    }
                    
                    // 3. X-Axis Labels (Dates)
                    dateLabels(in: geometry.size)
                }
                .background(Color.clear) // Container background handled by parent
            }
        }
    }
    
    private var emptyView: some View {
        Text("데이터가 없습니다.")
            .foregroundColor(.white.opacity(0.5))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func graphBackground(in size: CGSize) -> some View {
        let min = floor(minTemp)
        let max = ceil(maxTemp)
        let range = max - min
        let graphHeight = size.height - topPadding - bottomPadding
        
        return ZStack {
            // Vertical Guidelines (Dates)
            let xStep = (size.width - 40) / CGFloat(dates.count)
            let lastX = 30 + CGFloat(dates.count) * xStep
            
            // Horizontal Guidelines (dashed/solid based on design)
            // Drawing 5 lines roughly distribution
            ForEach(0..<5) { i in
                let ratio = CGFloat(i) / 4.0 // 0.0 to 1.0
                let y = (size.height - bottomPadding) - (ratio * graphHeight)
                
                // Line
                Path { path in
                    path.move(to: CGPoint(x: 30, y: y))
                    path.addLine(to: CGPoint(x: lastX, y: y))
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5) // Increased visibility
                
                // Y-Axis Labels
                let tempValue = min + (range * ratio)
                Text(String(format: "%.1f", tempValue))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7)) // Slightly increased opacity
                    .position(x: 15, y: y)
            }
            
            // Vertical Guidelines (Dates) with closing line
            ForEach(0...dates.count, id: \.self) { i in
                let x = 30 + CGFloat(i) * xStep
                
                Path { path in
                    path.move(to: CGPoint(x: x, y: topPadding))
                    path.addLine(to: CGPoint(x: x, y: size.height - bottomPadding))
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            }
        }
    }
    
    private func dateLabels(in size: CGSize) -> some View {
        let xStep = (size.width - 40) / CGFloat(dates.count)
        let labelY = size.height - (bottomPadding / 2) // Center in bottom padding area
        
        return ForEach(0..<dates.count, id: \.self) { i in
            let x = 30 + CGFloat(i) * xStep
            Text(dates[i])
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
                .position(x: x, y: labelY)
        }
    }
    
    private func lineGraph(in size: CGSize, data: GraphData) -> some View {
        let validData = data.values
        let min = floor(minTemp)
        let max = ceil(maxTemp)
        let range = max - min
        
        // Drawing Area Calculation
        let graphHeight = size.height - topPadding - bottomPadding
        let xStep = (size.width - 40) / CGFloat(validData.count - 1)
        
        return Path { path in
            var startPointFound = false
            
            for (index, value) in validData.enumerated() {
                let x = 30 + CGFloat(index) * xStep
                
                if value > 0 { // Valid data check
                    let ratio = (value - min) / range
                    // Calculate Y based on safe area
                    // ratio 0 -> bottom line (size.height - bottomPadding)
                    // ratio 1 -> top line (topPadding)
                    let y = (size.height - bottomPadding) - (ratio * graphHeight)
                    
                    let point = CGPoint(x: x, y: y)
                    
                    if !startPointFound {
                        path.move(to: point)
                        startPointFound = true
                    } else {
                         path.addLine(to: point)
                    }
                } else {
                    // Gap handling: break the path
                    startPointFound = false 
                }
            }
        }
        .stroke(data.color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }
}
