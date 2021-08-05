//
//  CheckSpotPermissionsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/7/21.
//

import UIKit
import CoreLocation

class CheckSpotPermissionsViewController: UIViewController, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
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
    
    
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo.on.rectangle.fill")
        imageView.tintColor = .white
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        view.addSubview(label)
        view.addSubview(imageView)
        view.backgroundColor = .black
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
        
            
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
            configureForLocationDenied()
            return
        }
        
        
        nextViewController()
        
}
    
    @objc func didTapUpdate() {
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
        
        if CLLocationManager.authorizationStatus() == .denied {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if CLLocationManager.authorizationStatus() == .restricted {
            openSettings()
            return
        }
        
        nextViewController()
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = CLLocationManager.authorizationStatus()
        print(status)
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            let vc = SpotCameraViewController(images: [])
            navigationController?.pushViewController(vc, animated: true)
            
        } else {
           
            
        }
}
    
    
    
    
    @objc private func checkStatusForLocation() {
        print("timer called")
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            nextViewController()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            nextViewController()
        }
    }
    
    
    private func configureForLocationDenied() {
        self.label.text = "update location access"
        self.imageView.image = UIImage(systemName: "globe")
    }
    
    private func nextViewController() {
        let vc = SpotCameraViewController(images: [])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openSettings() {
        let settingsURLString = UIApplication.openSettingsURLString
        if let settingsURL = URL(string: settingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }

    


}

