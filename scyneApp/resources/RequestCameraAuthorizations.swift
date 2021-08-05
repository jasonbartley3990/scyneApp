//
//  RequestCameraAuthorizations.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation
import AVFoundation

enum CameraAuthorizationStatus {
    case granted
    case notRequested
    case unAuthorized
}

typealias RequestCameraAuthorizationCompletionHandler = (CameraAuthorizationStatus) -> Void

class RequestCameraAuthorizationController {
    static func requestCameraAuthorization(completionHandler: @escaping RequestCameraAuthorizationCompletionHandler) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
            guard granted else {
                completionHandler(.unAuthorized)
                return
            }
            completionHandler(.granted)
        }
    }
        
        
}
    static func getCameraAuthorizationStatus() -> CameraAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unAuthorized
        }
    }
}
