//
//  captureSessionControllerForPhotoOnly.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import Foundation
import Foundation
import AVFoundation
import UIKit

class CaptureSessionControllerForPhotoOnly: NSObject {
    
    private lazy var captureSession = AVCaptureSession()
    
    var image: UIImage? {
        didSet {
            print("twas set")
        }
    }
    
    private var output = AVCapturePhotoOutput()

    override init() {
        super.init()
        
        initializeCaputeSessionForPhotoOnly()
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func stopRunning() {
        captureSession.stopRunning()
        print("heyyyy ya")
        
    }
    
    func photoTaken()  {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
    }
    
    func returnPhoto(image: UIImage) -> UIImage {
        return image
    }
    
    func startRunnung() {
        captureSession.startRunning()
    }
    
}

private extension CaptureSessionControllerForPhotoOnly {
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
        
    
    func initializeCaputeSessionForPhotoOnly() {
        guard let captureDevice = getVideoCaptureDevice() else {return}
        guard let captureDeviceInput = getCaptureDeviceImput(captureDevice: captureDevice) else {return}
        guard captureSession.canAddInput(captureDeviceInput) else {return}
        captureSession.addInput(captureDeviceInput)
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        captureSession.startRunning()
        
    }
    
}

extension CaptureSessionControllerForPhotoOnly: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {return}
        stopRunning()
        
        guard let image = UIImage(data: data) else {return}
        guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 640, height: 640), scaleMode: .aspectFill) else { return }
        self.image = returnPhoto(image: resizedImage)
        
        
    }
}
