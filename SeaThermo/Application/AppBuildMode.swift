//
//  AppBuildMode.swift
//  SeaThermo
//

import Foundation

enum AppBuildMode {
    static var isInternal: Bool {
        #if INTERNAL_BUILD
        return true
        #else
        return false
        #endif
    }

    static var isPublic: Bool {
        !isInternal
    }
}
