//
//  RequestPhotoLibraryAuthorization.swift
//  scyneApp
//
//  Created by Jason bartley on 5/7/21.
//

import Foundation
import AVFoundation
import Photos

enum RequestPhotoLibraryAuthorizationStatus {
    case granted
    case notRequested
    case unAuthorized
}

typealias RequestPhotoLibraryAuthorizationCompletionHandler = (RequestPhotoLibraryAuthorizationStatus) -> Void

class RequestPhotoLiobraryAuthorizationController {
    static func requestPhotoLibraryAuthorizationAuthorization(completionHandler: @escaping RequestPhotoLibraryAuthorizationCompletionHandler) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized else {
                    completionHandler(.unAuthorized)
                    return
                }
                completionHandler(.granted)
            }
    }
}
    static func getPhotoLibraryAuthorizationStatus() -> RequestPhotoLibraryAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unAuthorized
        }
    }
}
