//
//  WebViewConfig.swift
//  SeaThermo
//

import Foundation

/// 온바다 서버 웹뷰 페이지 정의
enum WebPage: String, Identifiable {
    case notices  = "/notices-page/"  // 공지사항
    case licenses = "/licenses/"      // 오픈소스 라이선스
    
    var id: String { rawValue }
    var path: String { rawValue }
}
