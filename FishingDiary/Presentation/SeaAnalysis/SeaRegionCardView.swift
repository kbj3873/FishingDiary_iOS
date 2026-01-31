//
//  SeaRegionCardView.swift
//  FishingDiary
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct SeaRegionCardView: View {
    let region: SeaRegionInfo
    let onTap: (() -> Void)?

    init(region: SeaRegionInfo, onTap: (() -> Void)? = nil) {
        self.region = region
        self.onTap = onTap
    }

    var body: some View {
        Button(action: { onTap?() }) {
            ZStack(alignment: .leading) {
                // Background Image
                backgroundLayer

                // Gradient Overlay
                gradientOverlay

                // Content
                contentLayer
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 0.5, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        Image(region.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 180)
    }

    // MARK: - Gradient Overlay

    private var gradientOverlay: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0),
                Color.black.opacity(0.3),
                Color.black.opacity(0.6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Content Layer

    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title & Subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(region.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(-0.094)

                Text(region.subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .tracking(-0.234)
            }
            .padding(.top, 24)
            .padding(.leading, 24)

            Spacer()

            // Station Count Badge
            HStack {
                Spacer()
                stationCountBadge
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Station Count Badge

    private var stationCountBadge: some View {
        HStack(spacing: 4) {
            Text("\(region.stationCount)개 지역")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .tracking(-0.076)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.25))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        SeaRegionCardView(
            region: SeaRegionInfo(
                id: "W",
                sea: .west,
                title: "서해",
                subtitle: "황해 연안 지역",
                imageName: "sea_west",
                stationCount: 48
            )
        )

        SeaRegionCardView(
            region: SeaRegionInfo(
                id: "E",
                sea: .east,
                title: "동해",
                subtitle: "동해안 지역",
                imageName: "sea_east",
                stationCount: 17
            )
        )
    }
    .padding(16)
    .background(Color(hex: "F2F2F7"))
}
