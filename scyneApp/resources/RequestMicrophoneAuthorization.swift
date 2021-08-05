//
//  RequestMicrophoneAuthorization.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation
import AVFoundation

enum MicrophoneAuthorizationStatus {
    case granted
    case notRequested
    case unAuthorized
}

typealias RequestMicrophoneAuthorizationCompletionHandler = (MicrophoneAuthorizationStatus) -> Void

class RequestMicrophoneAuthorizationController {
    static func requestMicrophoneAuthorization(completionHandler: @escaping RequestMicrophoneAuthorizationCompletionHandler) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
            guard granted else {
                completionHandler(.unAuthorized)
                return
            }
            completionHandler(.granted)
        }
    }
        
        
}
    static func getMicrophoneAuthorizationStatus() -> MicrophoneAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unAuthorized
        }
    }
}
