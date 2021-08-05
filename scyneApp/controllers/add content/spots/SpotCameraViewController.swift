//
//  SpotCameraViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import CoreLocation

class SpotCameraViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    private var locationWhenPhotoTaken: CLLocationCoordinate2D?
    private var latitude: Double?
    private var longitude: Double?
    private var address = ""

    private var images = [UIImage]()
    
    private var videoPreviewLayer = VideoPreviewView()
    
    private lazy var captureSessionController = CaptureSessionControllerForPhotoOnly()
    
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = nil
        return button
    }()
    
    init(images: [UIImage]) {
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "take photo"
        view.backgroundColor = .black
        setUpNavBar()
        view.addSubview(videoPreviewLayer)
        view.addSubview(shutterButton)
        videoPreviewLayer.videoPreviewLayer.session = captureSessionController.getCaptureSession()
        shutterButton.addTarget(self, action: #selector(didTapShutter), for: .touchUpInside)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        videoPreviewLayer.videoPreviewLayer.session = captureSessionController.getCaptureSession()
        captureSessionController.startRunnung()

    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationItem.rightBarButtonItem = nil
        captureSessionController.image = nil
        captureSessionController.stopRunning()
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let buttonSize = view.width/5
        shutterButton.frame = CGRect(x: (view.width - buttonSize)/2, y: view.safeAreaInsets.top + view.width + 100, width: buttonSize, height: buttonSize)
        shutterButton.layer.cornerRadius = buttonSize/2
        
    }
    
    private func setUpNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc func didTapShutter() {
        captureSessionController.photoTaken()
        self.locationWhenPhotoTaken = currentLocation
        self.latitude = locationWhenPhotoTaken?.latitude
        self.longitude = locationWhenPhotoTaken?.longitude
        lookUpCurrentLocation { placemark in
            
            let street = placemark?.name! ?? ""
            self.address = street
            
            
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
    }
    
    @objc func didTapClose() {
        captureSessionController.stopRunning()
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
        let vc = HomeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapNext() {
        guard let takenPhoto = self.captureSessionController.image else {return
            print("opps")
        }
        guard let long = longitude else {return}
        guard let lat = latitude else {return}
        
        locationManager.stopUpdatingLocation()
        
        let vc = SpotAskForMorePhotosViewController(imageSelected: takenPhoto, latitude: lat, longitude: long, addressString: address, images: self.images)
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}

extension SpotCameraViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got current location")
        
        guard let latestLocation = locations.first else {return}
        print(latestLocation)
        currentLocation = latestLocation.coordinate
    }
}

extension SpotCameraViewController {
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }}

