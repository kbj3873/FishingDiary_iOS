//
//  SeaThermoWebView.swift
//  SeaThermo
//

import SwiftUI
import WebKit

/// 온바다 서버 웹 콘텐츠용 공통 WebView
/// - User-Agent: SeaThermo 식별자 포함
/// - appBridge close 메시지 수신 시 → navigation pop
struct SeaThermoWebView: View {
    let page: WebPage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        _SeaThermoWebViewRepresentable(url: page.url, onPop: { dismiss() })
            .ignoresSafeArea()
            .navigationBarHidden(true)
    }
}

// MARK: - UIViewRepresentable

private struct _SeaThermoWebViewRepresentable: UIViewRepresentable {
    let url: URL
    let onPop: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPop: onPop)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // ── 1. WKWebView 설정 ──────────────────────────────────
        let config = WKWebViewConfiguration()
        
        // 앱 브릿지 핸들러 등록 (JS → Native)
        config.userContentController.add(context.coordinator, name: "appBridge")
        
        // User-Agent: 기본 UA 뒤에 SeaThermo 식별자 추가
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let osVersion  = UIDevice.current.systemVersion
        config.applicationNameForUserAgent = "SeaThermo/\(appVersion) iOS/\(osVersion)"
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        // ── 2. 첫 요청 (앱 정보 헤더 포함) ─────────────────────
        var request = URLRequest(url: url)
        AppInfoHeaders.make().forEach { request.setValue($1, forHTTPHeaderField: $0) }
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

// MARK: - Coordinator

extension _SeaThermoWebViewRepresentable {
    
    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private let onPop: () -> Void
        
        init(onPop: @escaping () -> Void) {
            self.onPop = onPop
        }
        
        // MARK: WKScriptMessageHandler — JS → Native
        // window.webkit.messageHandlers.appBridge.postMessage("close")
        
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "appBridge",
                  let body = message.body as? String else { return }
            
            switch body {
            case "close":
                // 웹뷰에서 닫기 요청 → navigation pop
                DispatchQueue.main.async { self.onPop() }
            default:
                break  // 향후 share, login 등 메시지 추가 가능
            }
        }
        
        // MARK: WKNavigationDelegate — 에러 처리
        
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            printIfDebug("WebView 로드 실패: \(error.localizedDescription)")
        }
    }
}
