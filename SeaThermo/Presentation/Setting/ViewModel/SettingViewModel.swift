//
//  SettingViewModel.swift
//  SeaThermo
//
//  Created for Figma Feature Implementation
//

import Foundation
import Combine

final class SettingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedMapType: MapType
    @Published var showRecordingBlockedPopup: Bool = false

    // MARK: - Properties

    private var appManager: FDAppManager

    // MARK: - Init

    init(appManager: FDAppManager = .shared) {
        self.appManager = appManager
        self.selectedMapType = appManager.mapTp
    }

    // MARK: - Methods

    func updateMapType(_ type: MapType) {
        guard type != selectedMapType else { return }

        if appManager.isRecording {
            showRecordingBlockedPopup = true
            return
        }

        self.selectedMapType = type
        self.appManager.mapTp = type
    }

    func dismissRecordingBlockedPopup() {
        showRecordingBlockedPopup = false
    }
}
