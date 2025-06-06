//
//  FDBaseViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/01/24.
//

import Foundation
import UIKit

class FDBaseViewController: UIViewController {
    @IBOutlet var keyboardSpacing: NSLayoutConstraint!
    
    var editTextFieldFrame: CGRect?
    var keyboardRecognizer: FDKeyboardRecognizer?
    
    /// 키보드사용 여부
    var usingKeyboard: Bool {
        get {
            if keyboardRecognizer != nil {
                return true
            }else {
                return false
            }
        }
        set(info) {
            if keyboardRecognizer != nil {
                keyboardRecognizer = nil
            }
            if info {
                keyboardRecognizer = FDKeyboardRecognizer.init(with: self)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension FDBaseViewController: FDKeyboardRecognizerDelegate {
    func keyboardWillShow(height: CGFloat, duration: Double, curve: UIView.AnimationCurve) {
        guard let frame = editTextFieldFrame else { return }
        
        let keyboardY = UIScreen.main.bounds.height - height
        let textFieldUnderY = frame.origin.y + frame.height
        print("keyY: \(keyboardY) textFieldY: \(textFieldUnderY)")
        
        if textFieldUnderY > keyboardY {
            keyboardSpacing?.constant = textFieldUnderY - keyboardY
            view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(duration: Double, curve: UIView.AnimationCurve) {
        keyboardSpacing?.constant = 0
    }
}
