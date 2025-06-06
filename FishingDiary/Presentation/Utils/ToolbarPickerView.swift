//
//  ToolbarPickerView.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/16/24.
//

import UIKit

protocol ToolbarPickerViewDelegate: NSObject {
    func didTapDone(pickerView: ToolbarPickerView)
    func didTapCancel(pickerView: ToolbarPickerView)
}

class ToolbarPickerView: UIPickerView {
    public private(set) var toolbar: UIToolbar?
    public weak var toolbarDelegate: ToolbarPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBtn = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(self.cancelTapped))
        
        toolBar.setItems([cancelBtn, spaceBtn, doneBtn], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        self.toolbar = toolBar
    }
    
    @objc func doneTapped() {
        self.toolbarDelegate?.didTapDone(pickerView: self)
    }
    
    @objc func cancelTapped() {
        self.toolbarDelegate?.didTapCancel(pickerView: self)
    }
}
