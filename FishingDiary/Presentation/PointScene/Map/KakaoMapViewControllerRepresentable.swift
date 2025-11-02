//
//  KakaoMapViewControllerRepresentable.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/28/25.
//

import UIKit
import SwiftUI

struct KakaoMapViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: KakaoPointMapViewModel
    @Binding var selectedPin: KakaoMapPin?
    @Binding var shouldCleanup: Bool
    
    func makeUIViewController(context: Context) -> KakaoPointMapViewController {
        let viewController = KakaoPointMapViewController.create(with: viewModel)
        
        // 콜백 설정 (POI 선택 이벤트를 SwiftUI로 전달
        viewController.onPinSelected = { pin in
            DispatchQueue.main.async {
                context.coordinator.parent.selectedPin = pin
            }
        }
        
        // Coordinator에 ViewController 참조 저장
        context.coordinator.viewController = viewController
        
        print("KakaoMapViewController 생성")
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: KakaoPointMapViewController, context: Context) {
        // cleanup 플래그가 true면 즉시 정리
        if shouldCleanup {
            context.coordinator.cleanup()
            return
        }
        
        // 필요한 경우 viewController 업데이트
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: KakaoMapViewControllerRepresentable
        weak var viewController: KakaoPointMapViewController?
        private var isCleanedUp = false
        
        init(_ parent: KakaoMapViewControllerRepresentable) {
            self.parent = parent
        }
        
        // 명시적 정리
        func cleanup() {
            guard !isCleanedUp, let vc = viewController else { return }
            
            print("Kakao Map 리소스 정리 시작")
            
            // 지도 렌더링 중지
            vc.controller.stopRendering()
            
            // Info View 숨김
            vc.infoView?.isHidden = true
            
            isCleanedUp = true
            print("Kakao Map 리소스 정리 완료")
        }
        
        deinit {
            cleanup()
            print("KakaoMapViewControllerRepresentable.Coordinator deinit")
        }
    }
}
