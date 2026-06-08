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

struct GraphAxisTick: Identifiable, Equatable {
    let sampleIndex: Int
    let label: String

    var id: Int { sampleIndex }
}

enum GraphTimeScale: String, CaseIterable, Identifiable {
    case daily
    case twelveHours
    case sixHours
    case threeHours

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "날짜별"
        case .twelveHours: return "12시간"
        case .sixHours: return "6시간"
        case .threeHours: return "3시간"
        }
    }

    var subtitle: String {
        switch self {
        case .daily: return "일별 수온 추이 분석"
        case .twelveHours: return "12시간 단위 수온 추이 분석"
        case .sixHours: return "6시간 단위 수온 추이 분석"
        case .threeHours: return "3시간 단위 수온 추이 분석"
        }
    }

    var hourInterval: Int {
        switch self {
        case .daily: return 24
        case .twelveHours: return 12
        case .sixHours: return 6
        case .threeHours: return 3
        }
    }

    var minimumTickSpacing: CGFloat {
        switch self {
        case .daily: return 0
        case .twelveHours: return 76
        case .sixHours: return 68
        case .threeHours: return 58
        }
    }
}

struct TemperatureLineGraphView: View {
    let dataSets: [GraphData]
    let ticks: [GraphAxisTick]
    let timeScale: GraphTimeScale

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
    private let topPadding: CGFloat = 16
    private let bottomPadding: CGFloat = 48
    private let yAxisWidth: CGFloat = 38
    private let plotLeftPadding: CGFloat = 0
    private let plotRightPadding: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            let validValues = allValues.filter { $0 > 0 }
            
            if validValues.isEmpty {
                emptyView
            } else {
                let plotVisibleWidth = Swift.max(geometry.size.width - yAxisWidth, 1)
                let plotContentWidth = scrollContentWidth(for: plotVisibleWidth)

                HStack(spacing: 0) {
                    yAxisLabels(in: geometry.size)
                        .frame(width: yAxisWidth, height: geometry.size.height)

                    if timeScale == .daily {
                        plotArea(in: CGSize(width: plotVisibleWidth, height: geometry.size.height))
                            .frame(width: plotVisibleWidth, height: geometry.size.height)
                    } else {
                        ScrollView(.horizontal, showsIndicators: true) {
                            plotArea(in: CGSize(width: plotContentWidth, height: geometry.size.height))
                                .frame(width: plotContentWidth, height: geometry.size.height)
                        }
                        .frame(width: plotVisibleWidth, height: geometry.size.height)
                    }
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

    private func plotArea(in size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            graphBackground(in: size)

            ForEach(0..<dataSets.count, id: \.self) { index in
                lineGraph(in: size, data: dataSets[index])
            }

            dateLabels(in: size)
        }
    }

    private func yAxisLabels(in size: CGSize) -> some View {
        let min = floor(minTemp)
        let max = ceil(maxTemp)
        let range = Swift.max(max - min, 1)
        let graphHeight = size.height - topPadding - bottomPadding

        return ZStack {
            ForEach(0..<5) { i in
                let ratio = CGFloat(i) / 4.0
                let y = (size.height - bottomPadding) - (ratio * graphHeight)
                let tempValue = min + (range * ratio)

                Text(String(format: "%.1f", tempValue))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: yAxisWidth - 6, alignment: .trailing)
                    .position(x: (yAxisWidth - 6) / 2, y: y)
            }
        }
    }

    private func graphBackground(in size: CGSize) -> some View {
        let graphHeight = size.height - topPadding - bottomPadding
        let sampleCount = primarySampleCount
        
        return ZStack {
            let graphRightX = size.width - plotRightPadding
            
            // Horizontal Guidelines (dashed/solid based on design)
            // Drawing 5 lines roughly distribution
            ForEach(0..<5) { i in
                let ratio = CGFloat(i) / 4.0 // 0.0 to 1.0
                let y = (size.height - bottomPadding) - (ratio * graphHeight)
                
                // Line
                Path { path in
                    path.move(to: CGPoint(x: plotLeftPadding, y: y))
                    path.addLine(to: CGPoint(x: graphRightX, y: y))
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5) // Increased visibility
            }
            
            // Vertical Guidelines
            ForEach(ticks) { tick in
                let x = xPosition(for: tick.sampleIndex, in: size, sampleCount: sampleCount)
                
                Path { path in
                    path.move(to: CGPoint(x: x, y: topPadding))
                    path.addLine(to: CGPoint(x: x, y: size.height - bottomPadding))
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            }

            Path { path in
                path.move(to: CGPoint(x: graphRightX, y: topPadding))
                path.addLine(to: CGPoint(x: graphRightX, y: size.height - bottomPadding))
            }
            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        }
    }
    
    private func dateLabels(in size: CGSize) -> some View {
        let sampleCount = primarySampleCount
        let labelY = size.height - (bottomPadding / 2)
        
        return ForEach(ticks) { tick in
            let x = xPosition(for: tick.sampleIndex, in: size, sampleCount: sampleCount)
            let labelWidth: CGFloat = 58
            let shouldAlignLeading = timeScale != .daily && tick.sampleIndex == 0
            let labelX = shouldAlignLeading ? Swift.max(x, labelWidth / 2) : x
            let textAlignment: TextAlignment = shouldAlignLeading ? .leading : .center
            let frameAlignment: Alignment = shouldAlignLeading ? .leading : .center
            Text(tick.label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(textAlignment)
                .lineLimit(2)
                .frame(width: labelWidth, alignment: frameAlignment)
                .position(x: labelX, y: labelY)
        }
    }
    
    private func lineGraph(in size: CGSize, data: GraphData) -> some View {
        let validData = data.values
        let min = floor(minTemp)
        let max = ceil(maxTemp)
        let range = Swift.max(max - min, 1)
        
        // Drawing Area Calculation
        let graphHeight = size.height - topPadding - bottomPadding
        let sampleCount = Swift.max(validData.count, 1)
        
        return Path { path in
            var startPointFound = false
            
            for (index, value) in validData.enumerated() {
                let x = xPosition(for: index, in: size, sampleCount: sampleCount)
                
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

    private var primarySampleCount: Int {
        dataSets.map { $0.values.count }.max() ?? 1
    }

    private func xPosition(for sampleIndex: Int, in size: CGSize, sampleCount: Int) -> CGFloat {
        let graphWidth = Swift.max(size.width - plotLeftPadding - plotRightPadding, 1)
        let maxIndex = Swift.max(sampleCount - 1, 1)
        let clampedIndex = Swift.min(Swift.max(sampleIndex, 0), maxIndex)
        return plotLeftPadding + (CGFloat(clampedIndex) / CGFloat(maxIndex)) * graphWidth
    }

    private func scrollContentWidth(for visiblePlotWidth: CGFloat) -> CGFloat {
        guard timeScale != .daily else {
            return visiblePlotWidth
        }

        let tickCount = Swift.max(ticks.count, 2)
        let width = CGFloat(tickCount - 1) * timeScale.minimumTickSpacing + plotLeftPadding + plotRightPadding
        return Swift.max(visiblePlotWidth, width)
    }
}
