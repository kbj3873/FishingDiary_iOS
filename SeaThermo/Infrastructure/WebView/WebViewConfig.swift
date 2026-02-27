//
//  WebViewConfig.swift
//  SeaThermo
//

import Foundation

/// 온바다 서버 웹뷰 페이지 정의
enum WebPage: String, Identifiable {
    case notices  = "http://3.35.210.133:3000/notices-page/"  // 공지사항
    case licenses = "http://3.35.210.133:3000/licenses/"      // 오픈소스 라이선스
    
    var id: String { rawValue }
    
    /// 페이지 타이틀 (내비게이션 바 표시용)
    var title: String {
        switch self {
        case .notices:  return "공지사항"
        case .licenses: return "오픈소스 라이선스"
        }
    }
    
    var url: URL {
        URL(string: rawValue)!
    }
}
