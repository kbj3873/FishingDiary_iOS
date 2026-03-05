//
//  OceanRegionCardView.swift
//  SeaThermo
//
//  Created by Claude on 1/29/26.
//

import SwiftUI

struct OceanRegionCardView: View {
    let station: OceanStationModel
    let backgroundImage: Image?

    init(station: OceanStationModel, backgroundImage: Image? = nil) {
        self.station = station
        self.backgroundImage = backgroundImage
    }

    var body: some View {
        ZStack {
            // Background
            backgroundLayer

            // Content
            contentLayer
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }

    // MARK: - Background Layer

    @ViewBuilder
    private var backgroundLayer: some View {
        if let image = backgroundImage {
            // Image background with gradient overlay
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        } else {
            // Gradient background (when no image)
            LinearGradient(
                colors: [
                    Color(hex: "4A7C9E"),
                    Color(hex: "5A8CAE"),
                    Color(hex: "6A9CBE")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Content Layer

    private var contentLayer: some View {
        HStack(alignment: .top) {
            // Left side - Temperature info
            VStack(alignment: .leading, spacing: 0) {
                temperatureSection
                Spacer()
                subTemperatureSection
            }

            Spacer()

            // Right side - Location info
            locationSection
        }
        .padding(20)
    }

    // MARK: - Temperature Section

    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("표층")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))

            Text(formattedSurfaceTemperature)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
        }
    }

    private var subTemperatureSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 중층
            if station.midTempurature.isEmpty || station.midTempurature == "0" {
                Text("중층: 데이터 없음")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                HStack(spacing: 0) {
                    Text("중층: ")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.95))
                    
                    Text(formattedMidTemperature)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
            }

            // 저층
            if station.botTempurature.isEmpty || station.botTempurature == "0" {
                Text("저층: 데이터 없음")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                HStack(spacing: 0) {
                    Text("저층: ")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.95))

                    Text(formattedBotTemperature)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
            }
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(station.stationName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)

            Text(seaRegionName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }

    // MARK: - Computed Properties

    private var formattedSurfaceTemperature: String {
        guard !station.surTempurature.isEmpty else { return "-°" }
        return "\(station.surTempurature)°"
    }

    private var formattedMidTemperature: String {
        guard !station.midTempurature.isEmpty && station.midTempurature != "0" else { return "-°" }
        return "\(station.midTempurature)°"
    }

    private var formattedBotTemperature: String {
        guard !station.botTempurature.isEmpty && station.botTempurature != "0" else { return "-°" }
        return "\(station.botTempurature)°"
    }

    private var seaRegionName: String {
        // 지역명으로 해역 추정
        let name = station.stationName
        let westSeaKeywords = ["서산", "목포", "군산", "인천", "태안", "보령", "부안", "영광", "무안", "신안", "백령도", "서천"]
        let southSeaKeywords = ["여수", "통영", "거제", "남해", "완도", "고흥", "진도", "해남", "장흥", "강진", "사천", "서제주", "제주", "추자도", "보성", "진해"]
        let eastSeaKeywords = ["울산", "포항", "동해", "강릉", "속초", "삼척", "울진", "영덕", "경주", "부산", "양양", "고성", "기장", "나곡", "덕천", "온양", "진하", "구룡포", "고리"]

        for keyword in westSeaKeywords {
            if name.contains(keyword) { return "서해" }
        }
        for keyword in southSeaKeywords {
            if name.contains(keyword) { return "남해" }
        }
        for keyword in eastSeaKeywords {
            if name.contains(keyword) { return "동해" }
        }

        return "해역"
    }
}

#Preview {
    VStack(spacing: 12) {
        OceanRegionCardView(
            station: OceanStationModel(
                stationCode: "001",
                stationName: "서산 창리",
                surTempurature: "13.2",
                midTempurature: "12.4",
                botTempurature: ""
            )
        )

        OceanRegionCardView(
            station: OceanStationModel(
                stationCode: "002",
                stationName: "통영 사량",
                surTempurature: "17.3",
                midTempurature: "16.6",
                botTempurature: "15.5"
            )
        )
    }
    .padding()
    .background(Color(hex: "F2F2F7"))
}
