//
//  SeaRegionRowView.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct SeaRegionRowView: View {
    let observatory: ObservatoryInfo
    let onTap: (() -> Void)?

    init(observatory: ObservatoryInfo, onTap: (() -> Void)? = nil) {
        self.observatory = observatory
        self.onTap = onTap
    }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack {
                Text(observatory.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .tracking(-0.31)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "C7C7CC"))
            }
            .padding(.horizontal, 16)
            .frame(height: 62)
            .background(Color(hex: "F2F2F7"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        SeaRegionRowView(observatory: ObservatoryInfo(from: Region(
            regionGroup: "남해", regionCode: "gi086", regionName: "거제 일운",
            latitude: "34.7", longitude: "128.6",
            hasSurface: true, hasMiddle: false, hasBottom: false,
            surfaceDepth: "2", middleDepth: "", bottomDepth: ""
        )))
        SeaRegionRowView(observatory: ObservatoryInfo(from: Region(
            regionGroup: "남해", regionCode: "fnm5b", regionName: "남해 미조",
            latitude: "34.7", longitude: "127.9",
            hasSurface: true, hasMiddle: false, hasBottom: false,
            surfaceDepth: "2", middleDepth: "", bottomDepth: ""
        )))
    }
    .padding(16)
    .background(Color.white)
}
