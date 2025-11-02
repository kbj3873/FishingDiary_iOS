//
//  SeaWaterTemperatureView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/30/25.
//

import SwiftUI

struct SeaWaterTemperatureView: View {
    @StateObject var viewModel: SeaWaterTemperatureViewModel
    
    @State private var selectedSea: Sea = .none
    @State private var selectedObserv: String = "선택"
    @State private var selectedObservCd: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // picker section
                pickerSection
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView("수온 정보 조회중...")
                        .padding()
                }
                
                // 그래프
                if !viewModel.tempuratureItems.isEmpty {
                    graphsSection
                }
            }
        }
        .navigationTitle("해수 수온")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - picker section
    private var pickerSection: some View {
        VStack(spacing: 16) {
            // 바다 선택
            HStack {
                Text("바다")
                    .frame(width: 60, alignment: .leading)
                
                Picker("바다 선택", selection: $selectedSea) {
                    ForEach(Array(Sea.allCases), id: \.self) { sea in
                        Text(sea.rawValue).tag(sea)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedSea) { _ in
                    // 바다 변경 시 관측소 초기화
                    selectedObserv = "선택"
                    selectedObservCd = ""
                }
            }
            
            // 관측소 선택
            HStack {
                Text("관측소")
                    .frame(width: 60, alignment: .leading)
                
                observPicker
            }
            
            // 조회 버튼
            Button(action: {
                if !selectedSea.id.isEmpty && !selectedObservCd.isEmpty {
                    viewModel.fetchTempuratureData(gruNam: selectedSea.id, staCde: selectedObservCd)
                }
                    
            }) {
                Text("조회")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedSea != .none && !selectedObservCd.isEmpty ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(selectedSea == .none || selectedObservCd.isEmpty)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var observPicker: some View {
        switch selectedSea {
        case .none:
            Text("선택")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .west:
            observPickerMenu(list: WestObserv.allCases)
        case .east:
            observPickerMenu(list: EastObserv.allCases)
        case .south:
            observPickerMenu(list: SouthObserv.allCases)
        }
    }
    
    private func observPickerMenu<T: Observ & CaseIterable>(list: [T]) -> some View {
        Menu {
            ForEach(Array(list), id: \.cd) { observ in
                Button(observ.title) {
                    selectedObserv = observ.title
                    selectedObservCd = observ.cd
                }
            }
        } label: {
            HStack {
                Text(selectedObserv)
                    .foregroundColor(selectedObserv == "선택" ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Graphs Section
    private var graphsSection: some View {
        VStack(spacing: 24) {
            // 표층수온
            temperatureGraph(
                title: "표층수온",
                depList: viewModel.tempuratureItems.map { $0.surDep },
                tempList: viewModel.tempuratureItems.map { $0.surTemp },
                color: .blue
            )
            
            // 중층수온
            temperatureGraph(
                title: "중층수온",
                depList: viewModel.tempuratureItems.map { $0.midDep },
                tempList: viewModel.tempuratureItems.map { $0.midTemp },
                color: .blue
            )
            
            // 저층수온
            temperatureGraph(
                title: "저층수온",
                depList: viewModel.tempuratureItems.map { $0.botDep },
                tempList: viewModel.tempuratureItems.map { $0.botTemp },
                color: .blue
            )
        }
    }
    
    private func temperatureGraph(title: String, depList: [Float], tempList: [CGFloat], color: Color) -> some View {
        let validTemps = tempList.filter { $0 > 0 }
        let depth = depList.first(where: { $0 > 0 }) ?? -1
        let currentTemp = validTemps.last ?? 0
        
        return VStack(alignment: .leading, spacing: 8) {
            // 제목
            Text(depth < 0 ? title : String(format: "\(title) (수심 %.1fm)", depth))
                .font(.headline)
            
            // 현재 수온
            if currentTemp > 0 {
                Text(String(format: "수온 %.1f°C", currentTemp))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // 그래프
            if !validTemps.isEmpty {
                TemperatureLineGraphView(
                    values: tempList,
                    color: color
                )
                .frame(height: 150)
                
                // 날짜 라벨
                dateLabelsView(dateList: viewModel.tempuratureItems.map { String($0.dateTime) })
            } else {
                Text("수온정보가 없습니다")
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func dateLabelsView(dateList: [String]) -> some View {
        let dayTimes = dateList.filter { $0.hasSuffix("0000") }
        
        return HStack(spacing: 0) {
            ForEach(Array(dayTimes.enumerated()), id: \.offset) { index, day in
                if day.count >= 8 {
                    let month = Int(day.subStrings(from: 4, to: 5)) ?? 0
                    let dayNum = Int(day.subStrings(from: 6, to: 7)) ?? 0
                    
                    Text("\(month)/\(dayNum)")
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - temperature line graph view
struct TemperatureLineGraphView: View {
    let values: [CGFloat]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let validValues = values.filter { $0 > 0 }
            
            if validValues.isEmpty {
                EmptyView()
            } else {
                ZStack(alignment: .topLeading) {
                    // 배경 그리드
                    graphBackground(in: geometry.size, values: validValues)
                    
                    // 라인 그래프
                    lineGraph(in: geometry.size)
                    
                    // 최고/최저 레벨
                    tempLabels(in: geometry.size, validValues: validValues)
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private func graphBackground(in size: CGSize, values: [CGFloat]) -> some View {
        let min = Int(values.min()!) - 1
        let max = Int(values.max()!) + 1
        let lineCount = max - min + 1
        let spacing = size.height / CGFloat(lineCount - 1)
        
        return ZStack {
            ForEach(0..<lineCount, id: \.self) { i in
                let y = CGFloat(i) * spacing
                
                // 가로선
                Path { path in
                    path.move(to: CGPoint(x: 20, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                
                // 온도라벨
                Text("\(max - i)")
                    .font(.system(size: 10))
                    .position(x: 10, y: y)
            }
        }
    }
    
    private func lineGraph(in size: CGSize) -> some View {
        let validValues = values.filter { $0 > 0 }
        guard !validValues.isEmpty else { return AnyView(EmptyView()) }
        
        let min = Int(validValues.min()!) - 1
        let max = Int(validValues.max()!) + 1
        let lineCount = max - min + 1
        let graphWeight = size.height / CGFloat(lineCount - 1)
        let xOffset = size.width / CGFloat(values.count)
        
        return AnyView(
            Path { path in
                var currentX: CGFloat = 0
                var validPoint = false
                
                for (index, value) in values.enumerated() {
                    currentX = CGFloat(index) * xOffset
                    
                    if value >= 0 {
                        let y = size.height - ((value - CGFloat(min)) * graphWeight)
                        let newPosition = CGPoint(x: currentX, y: y)
                        
                        if !validPoint {
                            print("\(value) move x:\(newPosition.x) y:\(newPosition.y)")
                            path.move(to: newPosition)
                        } else {
                            print("\(value) add x:\(newPosition.x) y:\(newPosition.y)")
                            path.addLine(to: newPosition)
                        }
                        validPoint = true
                    } else if value == -90 { // > 중간에 시간 누락된 데이터
                        if validPoint {
                            let newPosition: CGPoint = CGPoint(x: currentX,
                                                               y: path.cgPath.currentPoint.y)
                            path.addLine(to: newPosition)
                        }
                    } else {
                        print("\(value) non valid")
                        validPoint = false
                    }
                }
            }
            .stroke(color, lineWidth: 2.5)
        )
    }
    
    private func tempLabels(in size: CGSize, validValues: [CGFloat]) -> some View {
        let minTemp = validValues.min() ?? 0
        let maxTemp = validValues.max() ?? 0
        
        return VStack {
            HStack {
                Spacer()
                Text(String(format: "주간최고: %.1f", maxTemp))
                    .font(.system(size: 12))
                    .padding(4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text(String(format: "주간최저: %.1f", minTemp))
                    .font(.system(size: 12))
                    .padding(4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
            }
        }
        .padding(4)
    }
}
