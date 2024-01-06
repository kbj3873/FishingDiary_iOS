//
//  FDAlertViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit

class FDAlertViewController: UIViewController {
    // MARK: - Variables
    typealias actionHandler = ((FDAlertViewController) -> (Void))
    typealias resultHandler = ((FDAlertViewController, Bool) -> Void)
    var boolHandler: resultHandler?
    var stringTitle: String = ""
    var stringMessage: String = ""
    var confirmHandler: actionHandler?
    var cancelHandler: actionHandler?
    var isMultiAction: Bool = false
    var confirmTitle: String = ""
    var cancelTitle: String = ""
    var alertWindow: UIWindow?
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var messageTop: NSLayoutConstraint!
    
    
    // MARK: - IBActions
    @IBAction func actionCancel(_ sender: UIButton?) {
        self.dismiss(animated: false) {
            if let handler = self.cancelHandler {
                handler(self)
                self.cancelHandler = nil
            }
        }
    }
    
    @IBAction func actionConfirm(_ sender: UIButton?) {
        self.dismiss(animated: false) {
            if let handler = self.confirmHandler {
                handler(self)
                self.confirmHandler = nil
            }
        }
    }
    
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelTitle.text = stringTitle
        labelMessage.text = stringMessage
        if !isMultiAction {
            buttonCancel.isHidden = true
        }
        if confirmTitle.count > 0 {
            buttonConfirm.setTitle(confirmTitle, for: .normal)
        }
        if cancelTitle.count > 0 {
            buttonCancel.setTitle(cancelTitle, for: .normal)
        }
        
        if stringTitle.count == 0 {
            messageTop.constant = 0
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.isHidden = true
        alertWindow = nil
    }

}

// MARK: - Show Alert
extension UIViewController {
    func showAlert(title: String = "", msg: String, _ confirmTitle: String = "", completion: ((FDAlertViewController) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "FDAlertViewController") as! FDAlertViewController
        alert.stringTitle = title
        alert.stringMessage = msg
        alert.isMultiAction = false
        alert.confirmHandler = completion
        alert.confirmTitle = confirmTitle
        alert.modalPresentationStyle = .overFullScreen
        alert.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            /*
            if SCUserDefaults.userInterfaceStyle == "dark" {
                alert.alertWindow?.overrideUserInterfaceStyle = .dark
            }
            else if SCUserDefaults.userInterfaceStyle == "light" {
                alert.alertWindow?.overrideUserInterfaceStyle = .light
            }
            else {
                alert.alertWindow?.overrideUserInterfaceStyle = .unspecified
            }
            */
            // 항상 light
            alert.alertWindow?.overrideUserInterfaceStyle = .light
        }
        alert.alertWindow?.rootViewController = UIViewController()
        alert.alertWindow?.windowLevel = .alert + 1
        alert.alertWindow?.makeKeyAndVisible()
        alert.alertWindow?.rootViewController?.present(alert, animated: false, completion: nil)
    }
    
    func showAlertConfirm(title: String = "", msg: String, _ confirmTitle: String = "", completion: ((FDAlertViewController) -> Void)? = nil) {
        self.showAlertConfirm(title: title, msg: msg, confirmTitle, completion: completion, cancel: nil)
    }
    
    /// 공통웹뷰에서 bool 값 호출시
    func showAlertConfirm(title: String = "", msg: String, _ confirmTitle: String = "", _ cancelTitle: String = "", completion: @escaping ((FDAlertViewController, Bool) -> Void)) {
        self.showAlertConfirm(title: title, msg: msg, confirmTitle, completion: { confirm in
            completion(confirm, true)
        }, cancel: { cancel in
            completion(cancel, false)
        })
    }

    func showAlertConfirm(title: String = "", msg: String, _ confirmTitle: String = "", _ cancelTitle: String = "", completion: ((FDAlertViewController) -> Void)? = nil, cancel: ((FDAlertViewController) -> Void)?) {
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Common", bundle: nil)
            let alert = storyboard.instantiateViewController(withIdentifier: "FDAlertViewController") as! FDAlertViewController
            alert.stringTitle = title
            alert.stringMessage = msg
            alert.isMultiAction = true
            alert.confirmHandler = completion
            alert.cancelHandler = cancel
            alert.confirmTitle = confirmTitle
            alert.cancelTitle = cancelTitle
            alert.modalPresentationStyle = .overFullScreen
            alert.alertWindow = UIWindow(frame: UIScreen.main.bounds)
            if #available(iOS 13.0, *) {
                /*
                if SCUserDefaults.userInterfaceStyle == "dark" {
                    alert.alertWindow?.overrideUserInterfaceStyle = .dark
                }
                else if SCUserDefaults.userInterfaceStyle == "light" {
                    alert.alertWindow?.overrideUserInterfaceStyle = .light
                }
                else {
                    alert.alertWindow?.overrideUserInterfaceStyle = .unspecified
                }
                */
                // 항상 light
                alert.alertWindow?.overrideUserInterfaceStyle = .light
                
            }
            alert.alertWindow?.rootViewController = UIViewController()
            alert.alertWindow?.windowLevel = .alert + 1
            alert.alertWindow?.makeKeyAndVisible()
            alert.alertWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        }
    }
    
}
