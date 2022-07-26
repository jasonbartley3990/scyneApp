//
//  GearPermissionsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/7/21.
//

import UIKit

class GearPermissionsViewController: UIViewController {

    private var cameraAuthorizationStatus = RequestCameraAuthorizationController.getCameraAuthorizationStatus() {
        didSet {
            setUpViewForNextAuthorizationRequest()
        }
    }
    
    private var MicrophoneAuthorizationStatus = RequestMicrophoneAuthorizationController.getMicrophoneAuthorizationStatus() {
        didSet {
            setUpViewForNextAuthorizationRequest()
        }
    }
    
    private var PhotoLibraryAuthorizationStatus = RequestPhotoLiobraryAuthorizationController.getPhotoLibraryAuthorizationStatus() {
        didSet {
            setUpViewForNextAuthorizationRequest()
        }
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo.on.rectangle.fill")
        imageView.tintColor = .label
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "please update photo library access"
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle(" update ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private var didCallNext = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(button)
        view.addSubview(label)
        view.addSubview(imageView)
        button.addTarget(self, action: #selector(didTapUpdate), for: .touchUpInside)
        setUpViewForNextAuthorizationRequest()
        

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = 150
        label.sizeToFit()
        button.sizeToFit()
        imageView.frame = CGRect(x: (view.width - size)/2, y: (view.height - size)/2 - 40, width: size, height: size)
        label.frame = CGRect(x: (view.width - (view.width - 20))/2, y: imageView.bottom + 10, width: (view.width - 20), height: 40)
        button.frame = CGRect(x: (view.width - button.width)/2, y: label.bottom + 10, width: button.width, height: button.height)
    }
    
    private func setUpViewForNextAuthorizationRequest() {
        
        //check what permissions have been granted and displays images accordingly
        
        guard cameraAuthorizationStatus == .granted else {
            DispatchQueue.main.async {
                self.label.text = "update access to use camera"
                self.imageView.image = UIImage(systemName: "camera.fill")
                
            }
            if cameraAuthorizationStatus == nil {
                configureForDeniedCamera()
            }
            
            if cameraAuthorizationStatus == .unAuthorized {
                configureForDeniedCamera()
            }
            return
        }
        
        guard MicrophoneAuthorizationStatus == .granted else {
            DispatchQueue.main.async {
                self.label.text = "update access to use microphone"
                self.imageView.image = UIImage(systemName: "mic.fill")
                
            }
            
            if MicrophoneAuthorizationStatus == nil {
                configureForDeniedMicrophone()
            }
            if MicrophoneAuthorizationStatus == .unAuthorized {
                configureForDeniedMicrophone()
            }
            return
        }
        print("photo librabry request")
        
        guard PhotoLibraryAuthorizationStatus == .granted else {
            DispatchQueue.main.async {
                self.label.text = "please update photo library access"
                self.imageView.image = UIImage(systemName: "photo.on.rectangle.fill")
            }
            
            if PhotoLibraryAuthorizationStatus == nil {
                configureForPhotoLibraryDenied()
            }
            if PhotoLibraryAuthorizationStatus == .unAuthorized {
                configureForPhotoLibraryDenied()
            }
            return
            
        }
        if didCallNext == false {
            didCallNext = true
            nextViewController()
            
        }
       
        
}
    
    @objc func didTapUpdate() {
        
        //after a permission has been updated checks what is next
        
        if cameraAuthorizationStatus == .notRequested {
            RequestCameraAuthorizationController.requestCameraAuthorization { [weak self] status in
                self?.cameraAuthorizationStatus = status
                
            }
            return
        }
        
        if cameraAuthorizationStatus == .unAuthorized {
            openSettings()
            return
            
        
            
    }
    
        if MicrophoneAuthorizationStatus == .notRequested {
            RequestMicrophoneAuthorizationController.requestMicrophoneAuthorization { [weak self] status in
                self?.MicrophoneAuthorizationStatus = status
                
            }
            return
            
        }
        
        if MicrophoneAuthorizationStatus == .unAuthorized {
            openSettings()
            return
            
    }
        
        if PhotoLibraryAuthorizationStatus == .notRequested {
            RequestPhotoLiobraryAuthorizationController.requestPhotoLibraryAuthorizationAuthorization { [weak self] status in
                self?.PhotoLibraryAuthorizationStatus = status
                if self?.PhotoLibraryAuthorizationStatus == .granted {
                    if self?.didCallNext == false {
                        self?.didCallNext = true
                        self?.nextViewController()
                        
                    }
                    
                }
            }
            return
        }
        
        if PhotoLibraryAuthorizationStatus == .unAuthorized {
            openSettings()
            return
        }
        
    }
    
    private func configureForDeniedCamera() {
        DispatchQueue.main.async {
            self.label.text = "go to settings to update camera access"
            self.imageView.image = UIImage(systemName: "camera.fill")
        }
    }
    
    private func configureForDeniedMicrophone() {
        DispatchQueue.main.async {
            self.label.text = "go to settings to update microphone access"
            self.imageView.image = UIImage(systemName: "mic.fill")
        }
    }
    
    private func configureForPhotoLibraryDenied() {
        DispatchQueue.main.async {
            self.label.text = "go to settings to update photo library access"
            self.imageView.image = UIImage(systemName: "photo.on.rectangle.fill")
        }
    }

    
    private func openSettings() {
        let settingsURLString = UIApplication.openSettingsURLString
        if let settingsURL = URL(string: settingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }

    private func nextViewController() {
        let vc = GearCameraViewController(images: [])
        navigationController?.pushViewController(vc, animated: true)
    }

}

