//
//  UIApplication.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit

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
