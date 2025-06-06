//
//  FDKeyboardRecognizer.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/01/23.
//

import Foundation
import UIKit

protocol FDKeyboardRecognizerDelegate: UIViewController {
    func keyboardWillShow(height: CGFloat, duration: Double, curve: UIView.AnimationCurve)
    func keyboardWillHide(duration: Double, curve: UIView.AnimationCurve)
}

class FDKeyboardRecognizer: NSObject {
    weak var delegate: FDKeyboardRecognizerDelegate?
    
    override init() {
        super.init()
        self.addNotification()
    }
    
    convenience init(with delegate: FDKeyboardRecognizerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        if let durationNumber = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
           let keyboardCurveNumber = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            let keyboardDuration = durationNumber.doubleValue
            let keyboardCurve = keyboardCurveNumber.uintValue
            self.delegate?.keyboardWillShow(height: keyboardFrame.height, duration: keyboardDuration, curve: UIView.AnimationCurve(rawValue: UIView.AnimationCurve.RawValue(keyboardCurve))!)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        if let durationNumber = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
           let keyboardCurveNumber = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            let keyboardDuration = durationNumber.doubleValue
            let keyboardCurve = keyboardCurveNumber.uintValue
            self.delegate?.keyboardWillHide(duration: keyboardDuration, curve: UIView.AnimationCurve(rawValue: UIView.AnimationCurve.RawValue(keyboardCurve))!)
        }
    }
}
