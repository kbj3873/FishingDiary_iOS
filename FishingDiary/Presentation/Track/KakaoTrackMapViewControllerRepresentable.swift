//
//  KakaoTrackMapViewControllerRepresentable.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/29/25.
//

import SwiftUI
import UIKit

struct KakaoTrackMapViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: KakaoTrackMapViewModel
    @Binding var shouldCleanup: Bool
    
    @Binding var coordinator: Coordinator?
    
    func makeUIViewController(context: Context) -> KakaoTrackMapViewController {
        let viewController = KakaoTrackMapViewController.create(with: viewModel)
        context.coordinator.viewController = viewController
        
        DispatchQueue.main.async {
            coordinator = context.coordinator
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: KakaoTrackMapViewController, context: Context) {
        if shouldCleanup {
            context.coordinator.cleanup()
            return
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: KakaoTrackMapViewControllerRepresentable
        weak var viewController: KakaoTrackMapViewController?
        private var isCleanedUp = false
        
        init(_ parent: KakaoTrackMapViewControllerRepresentable) {
            self.parent = parent
        }
        
        func cleanup() {
            guard !isCleanedUp, let vc = viewController else { return }
            
            print("KakaoTrackMap 리소스 정리")
            
            vc.controller.stopRendering()
            
            isCleanedUp = true
            print("KakaoTrackMap 리소스 정리 완료")
        }
        
        deinit {
            cleanup()
            print("KakaoTrackMapViewControllerRepresentable.Coordinator deinit")
        }
    }
}
