//
//  SCPrivacy.swift
//  SamsungCard
//
//  Created by Y5004219 on 2021/08/17.
//  Copyright © 2021 삼성카드. All rights reserved.
//
//	SCPrivacy sample code
//	SCPrivacy.checkContacts(access: true) { status in
//		print("status : \(status)")
//	} moveSetting: { settingHandler in
//		self.showAlertMessage(msg: "설정에서 연락처 권한을 허용해주세요.", "설정으로 가기") { confirm in
//			settingHandler?(.move)
//		}
//	}


import UIKit
import AVFAudio
import Photos
import Contacts
import Speech

enum SCPermissionStatus {
	case denined		// 사용불가 선택
	case use			// 사용 선택
	case notDetermined	// 선택되지 않음
	case dontUse		// 사용할 수 없음
    //
    //@available(iOS 14, *)
    case limited // User has authorized this application for limited photo library access. Add PHPhotoLibraryPreventAutomaticLimitedAccessAlert = YES to the application's Info.plist to prevent the automatic alert to update the users limited library selection. Use -[PHPhotoLibrary(PhotosUISupport) presentLimitedLibraryPickerFromViewController:] from PhotosUI/PHPhotoLibrary+PhotosUISupport.h to manually present the limited library picker.
}

enum SCGoSettingType {
	case dontMove	// 이동안함
	case move		// 설정앱으로 이동
}

typealias SCPrivacyHandler = ((_ status: SCPermissionStatus) -> Void)?
typealias SCPrivacySettingHandler = ((_ type: SCGoSettingType) -> Void)?
typealias SCMoveSettingHandler = ((_ handler: SCPrivacySettingHandler) -> Void)?


class SCPrivacy: NSObject {
	// MARK: - Variables
	static var privacy: SCPrivacy?
	
	var foregroundHandler: (() -> Void)?
	
	// MARK: - Class functions
	
	/// 설정앱으로 이동
	/// - Parameter foreground: 앱이 활성화되었을 때 처리해야할 코드
	class func openApplicationSetting(foreground: (() -> Void)?) {
		guard let url = URL(string: UIApplication.openSettingsURLString) else {
			return
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
		privacy = SCPrivacy()
		privacy?.foregroundHandler = foreground
		NotificationCenter.default.addObserver(privacy!, selector: #selector(enterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
		
	}
	
	@objc func enterForeground(_ notification: Notification) {
		DispatchQueue.main.async {
			if let handler = self.foregroundHandler {
				handler()
			}
			if let privacy = SCPrivacy.privacy {
				NotificationCenter.default.removeObserver(privacy)
				SCPrivacy.privacy = nil
			}
			self.foregroundHandler = nil
		}
	}
	
	
	// MARK: Privacy - Camera Usage
	class func checkCamera(access: Bool, permission: SCPrivacyHandler, moveSetting: SCMoveSettingHandler) {
		guard let inputDevice = AVCaptureDevice.default(for: .video), inputDevice.hasMediaType(.video) else {
			permission?(.dontUse)
			return
		}
		
		let status = AVCaptureDevice.authorizationStatus(for: .video)
		switch status {
		case .denied:
			// 거절한 상태
			if access {
				let settingHandler: SCPrivacySettingHandler = { settingType in
					if settingType == .move {
						self.openApplicationSetting {
							self.checkCamera(access: false, permission: permission, moveSetting: nil)
						}
					}else {
						permission?(.denined)
					}
				}
				DispatchQueue.main.async {
					moveSetting?(settingHandler)
				}
			}else {
				permission?(.denined)
			}
			
		case .restricted:
			// 사용할 수 없는 상태
			permission?(.dontUse)
			
		case .notDetermined:
			// 아직 결정되지 않음
			if access {
				AVCaptureDevice.requestAccess(for: .video) { granted in
					DispatchQueue.main.async {
						if granted {
							permission?(.use)
						}else {
							permission?(.denined)
						}
					}
				}
			}else {
				permission?(.notDetermined)
			}
            
		default:
			// 허용됨
			permission?(.use)
		}
	}
	
	
	// MARK: Privacy - Photo Library Usage
	class func checkPhoto(access: Bool, permission: SCPrivacyHandler, moveSetting: SCMoveSettingHandler) {
        var status: PHAuthorizationStatus = .notDetermined
        if #available(iOS 14.0, *) {
            let accessLevel: PHAccessLevel = .readWrite
            status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        /// Deprecated and replaced by authorizationStatusForAccessLevel:, will return \c PHAuthorizationStatusAuthorized if the user has chosen limited photo library access
		//switch PHPhotoLibrary.authorizationStatus() {
        switch status {
		case .denied:
			// 거절한 상태
			if access {
				let settingHandler: SCPrivacySettingHandler = { settingType in
					if settingType == .move {
						self.openApplicationSetting {
							self.checkPhoto(access: false, permission: permission, moveSetting: nil)
						}
					}else {
						permission?(.denined)
					}
				}
				DispatchQueue.main.async {
					moveSetting?(settingHandler)
				}
			}else {
				permission?(.denined)
			}
			
		case .restricted:
			// 사용할 수 없는 상태
			permission?(.dontUse)
			
		case .notDetermined:
			// 아직 결정되지 않음
			if access {
				PHPhotoLibrary.requestAuthorization { status in
					DispatchQueue.main.async {
						if status == .authorized {
							permission?(.use)
						}else {
							permission?(.denined)
						}
					}
				}
			}else {
				permission?(.notDetermined)
			}
            
        case .limited:
            // 선택한 사진 @available(iOS 14, *)
            print("status: .limited : 선택한 사진 : @available(iOS 14, *)")
            permission?(.limited)
			
		default:
			// 허용됨
			permission?(.use)
		}
	}
	
	
	// MARK: Privacy - Location Usage
	class func checkLocation(access: Bool, permission: SCPrivacyHandler, moveSetting: SCMoveSettingHandler) {
		var status: CLAuthorizationStatus = .denied
		if #available(iOS 14.0, *) {
			status = CLLocationManager().authorizationStatus
		} else {
			status = CLLocationManager.authorizationStatus()
		}
		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			// 허용
			permission?(.use)
		case .restricted:
			// 사용할 수 없음
			permission?(.dontUse)
		case .notDetermined:
			// 결정전
			permission?(.notDetermined)
		case .denied:
			// 거부 - 설정으로 이동 유도
			if access {
				let settingHandler: SCPrivacySettingHandler = { settingType in
					if settingType == .move {
						self.openApplicationSetting {
							self.checkLocation(access: false, permission: permission, moveSetting: nil)
						}
					}else {
						permission?(.denined)
					}
				}
				DispatchQueue.main.async {
					moveSetting?(settingHandler)
				}
			}else {
				permission?(.denined)
			}
		@unknown default:
			break
		}
	}
	
	// MARK: Privacy - Contacts Usage
	class func checkContacts(access: Bool, permission: SCPrivacyHandler, moveSetting: SCMoveSettingHandler) {
		// 연락처 접근 권한 정보 가져오기
		let contactStore = CNContactStore.authorizationStatus(for: .contacts)
		
		switch contactStore {
		case .denied:
			// 거절한 상태
			if access {
				let settingHandler: SCPrivacySettingHandler = { settingType in
					if settingType == .move {
						self.openApplicationSetting {
							self.checkContacts(access: false, permission: permission, moveSetting: nil)
						}
					}else {
						permission?(.denined)
					}
				}
				DispatchQueue.main.async {
					moveSetting?(settingHandler)
				}
			}else {
				permission?(.denined)
			}
			
		case .restricted:
			// 사용할 수 없는 상태
			permission?(.dontUse)
			
		case .notDetermined:
			// 아직 결정되지 않음
			if access {
				let contacts = CNContactStore()
				contacts.requestAccess(for: .contacts) { granted, error in
					DispatchQueue.main.async {
						if granted {
							permission?(.use)
						}else {
							permission?(.denined)
						}
					}
				}
			}else {
				permission?(.notDetermined)
			}
			
		default:
			// 허용됨
			permission?(.use)
		}
	}
	
	
	// MARK: Privacy - Microphone Usage
	class func checkMicrophone(access: Bool, permission: SCPrivacyHandler, moveSetting: SCMoveSettingHandler) {
		AVAudioSession.sharedInstance().requestRecordPermission { granted in
			if granted {
				permission?(.use)
			}else {
				if access {
					let settingHandler: SCPrivacySettingHandler = { settingType in
						if settingType == .move {
							self.openApplicationSetting {
								self.checkMicrophone(access: false, permission: permission, moveSetting: nil)
							}
						}else {
							permission?(.denined)
						}
					}
					DispatchQueue.main.async {
						moveSetting?(settingHandler)
					}
				}else {
					permission?(.denined)
				}
			}
		}
	}
	
	
	// MARK: Privacy - Speech Recognition Usage
	class func checkSpeech(access: Bool, permission: SCPrivacyHandler, moveSetting: SCMoveSettingHandler) {
		SFSpeechRecognizer.requestAuthorization { status in
			switch status {
			case .authorized:
				// 허용됨
				permission?(.use)
			case .denied:
				// 거절한 상태
				if access {
					let settingHandler: SCPrivacySettingHandler = { settingType in
						if settingType == .move {
							self.openApplicationSetting {
								self.checkSpeech(access: false, permission: permission, moveSetting: nil)
							}
						}else {
							permission?(.denined)
						}
					}
					DispatchQueue.main.async {
						moveSetting?(settingHandler)
					}
				}else {
					permission?(.denined)
				}
				
			case .restricted:
				// 사용할 수 없는 상태
				permission?(.dontUse)
				
			case .notDetermined:
				// 아직 결정되지 않음
				permission?(.notDetermined)
				
			@unknown default:
				print("speech authorization unknown")
				permission?(.dontUse)
			}
		}
	}
}
