//
//  UIApplication.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit
import SwiftUI

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    /// 디바이스 SafeArea Bottom 영역을 반환
    class func safeAreaBottom() -> CGFloat {
        let window = UIDevice.getApplicationKeyWindow() ?? UIApplication.shared.windows.first
        let bottomPadding: CGFloat
        bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        return bottomPadding
    }
    
    /// 디바이스 SafeAreaTop 영역을 반환
    class func safeAreaTop() -> CGFloat {
        let window = UIDevice.getApplicationKeyWindow() ?? UIApplication.shared.windows.first
        let topPadding: CGFloat
        topPadding = window?.safeAreaInsets.top ?? 0.0
        return topPadding
    }
}

// MARK: - Figma Hex Color Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
