//
//  captureSessionController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import Foundation
import AVFoundation

class CaptureSessionController: NSObject {
    
    private lazy var captureSession = AVCaptureSession()
    
    override init() {
        super.init()
        
        initializeCaptureSession()
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func stopRunning() {
        captureSession.stopRunning()
        
    }
}

private extension CaptureSessionController {
    func getVideoCaptureDevice() -> AVCaptureDevice? {
        
        if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            return tripleCamera
        }
        
        if let dualWideCamera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
            return dualWideCamera
        }
        
        if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return dualCamera
        }
        
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        
        return nil
        
    }
    
    func getCaptureDeviceImput(captureDevice: AVCaptureDevice) -> AVCaptureDeviceInput? {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            return captureDeviceInput
        } catch let error {
            print("failed to get capture device unput with error \(error)")
        }
        return nil
    }
        
    
    func initializeCaptureSession() {
        guard let captureDevice = getVideoCaptureDevice() else {return}
        guard let captureDeviceInput = getCaptureDeviceImput(captureDevice: captureDevice) else {return}
        guard captureSession.canAddInput(captureDeviceInput) else {return}
        captureSession.addInput(captureDeviceInput)
        captureSession.startRunning()
        
    }
    
}
