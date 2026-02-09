//
//  SeaRegionListView.swift
//  SeaThermo
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct SeaRegionListView: View {
    @StateObject private var viewModel: SeaRegionListViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Callback for selection
    var onStationSelected: ((ObservatoryInfo) -> Void)?

    init(sea: Sea, onStationSelected: ((ObservatoryInfo) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: SeaRegionListViewModel(sea: sea))
        self.onStationSelected = onStationSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            dragHandle
                .padding(.top, 8)

            // Header
            headerSection
                .padding(.top, 16)
                .padding(.horizontal, 16)

            // Observatory List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.observatories) { observatory in
                        SeaRegionRowView(observatory: observatory) {
                            // Call the callback if provided, otherwise just print
                            print("Selected: \(observatory.name) (\(observatory.id))")
                            onStationSelected?(observatory)
                            // dismiss() is called by the parent via binding or simply here if that's the design
                            // But usually if we want parent to navigate, we might let parent handle dismiss or dismiss here.
                            // In this plan, parent handles sheet state, but sheet can also dismiss itself.
                            // However, if we dismiss here immediately, parent's onChange might trigger.
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        Capsule()
            .fill(Color(hex: "C6C6C8"))
            .frame(width: 36, height: 5)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .tracking(-0.12)

                Text(viewModel.subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .tracking(-0.23)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("닫기")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "2563EB"))
                    .tracking(-0.43)
            }
        }
    }
}

#Preview {
    SeaRegionListView(sea: .south)
}
