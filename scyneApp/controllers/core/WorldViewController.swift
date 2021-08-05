//
//  WorldViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import MapKit
import CoreLocation

class WorldViewController: UIViewController {
    
    //MARK: world view properties
    
    private var allSpots = [Post]()
    
    private var current: String = ""
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.masksToBounds = true
        return map
    }()
    
    private let AuthorizationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 2
        label.text = "please update your current location access to see spots"
        label.isHidden = true
        return label
    }()
    
    private let AuthorizationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "globe")
        imageView.tintColor = .label
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton()
        button.setTitle(" update ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
    private let currentState = true
    
    let childVC = SpotPreviewView()
    
    
    
    //MARK: authorization properties
    
    private var cameraAuthorizationStatus = RequestCameraAuthorizationController.getCameraAuthorizationStatus()
    
    private var MicrophoneAuthorizationStatus = RequestMicrophoneAuthorizationController.getMicrophoneAuthorizationStatus()
    
    
    private var PhotoLibraryAuthorizationStatus = RequestPhotoLiobraryAuthorizationController.getPhotoLibraryAuthorizationStatus()
    
    
    
    //MARK: view did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //basic
        title = "SPOTS"
        view.backgroundColor = .systemBackground
        view.addSubview(AuthorizationLabel)
        view.addSubview(AuthorizationImageView)
        view.addSubview(mapView)
        view.addSubview(updateButton)
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        childVC.view.alpha = 0
        childVC.view.isUserInteractionEnabled = false
        childVC.delegate = self
        updateButton.addTarget(self, action: #selector(didTapUpdate), for: .touchUpInside)
        mapView.delegate = self
        mapView.register(SpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        //top configuration
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "refresh", style: .done, target: self, action: #selector(grabSpots))
        
        //map configuration
        configureLocationServices()
        grabSpots()
        addAnnotations()
        
        
        let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(stopUpdating), userInfo: nil, repeats: false)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
        let height = view.height/2.2
        let imageSize = view.width/3
        let buttonSize: CGFloat = 150
        AuthorizationImageView.frame = CGRect(x: (view.width - imageSize)/2 , y: view.safeAreaInsets.top + 15, width: imageSize, height: imageSize)
        AuthorizationLabel.frame = CGRect(x: 25, y: AuthorizationImageView.bottom + 10, width: (view.width - 50), height: 50)
        updateButton.frame = CGRect(x:(view.width - buttonSize)/2 , y: AuthorizationLabel.bottom + 10, width: buttonSize, height: 50)
        childVC.view.frame = CGRect(x: 0, y: self.view.height - height - self.view.safeAreaInsets.bottom, width: self.view.width, height: height)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
        let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(stopUpdating), userInfo: nil, repeats: false)
        
    }
    
    //MARK: configure location services
    
    
    private func configureLocationServices() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        print(status)
        
        //if permissions not granted it will ask them to update location services
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        } else {
            DispatchQueue.main.async {
                self.mapView.isHidden = true
                self.AuthorizationLabel.isHidden = false
                self.AuthorizationImageView.isHidden = false
                self.updateButton.isHidden = false
                self.updateButton.isUserInteractionEnabled = true
            }
            
            
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = CLLocationManager.authorizationStatus()
        print(status)
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            DispatchQueue.main.async {
                self.mapView.isHidden = false
                self.updateButton.isHidden = true
                self.AuthorizationLabel.isHidden = true
                self.AuthorizationLabel.isHidden = true
                self.updateButton.isUserInteractionEnabled = false
            }
            let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(stopUpdating), userInfo: nil, repeats: false)
            
        } else {
            DispatchQueue.main.async {
                self.mapView.isHidden = true
                self.AuthorizationLabel.isHidden = false
                self.AuthorizationImageView.isHidden = false
                self.updateButton.isHidden = false
                self.updateButton.isUserInteractionEnabled = true
            }
        }
        
    }
    
    @objc func stopUpdating() {
        print("stopped")
        locationManager.stopUpdatingLocation()
    }
    
    @objc func didTapUpdate() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        configureLocationServices()
    }
    
    
    //MARK: zoom on map
    
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    //MARK: grab spots
    
    @objc func grabSpots() {
        print("functioned called")
        let center = mapView.region.center
        let lat = center.latitude
        let long = center.longitude
        DatabaseManager.shared.getAllSpotsForCenter(latitude: lat, longitude: long,  completion: { [weak self] spots in
            DispatchQueue.main.async {
                self?.allSpots.append(contentsOf: spots)
                self?.addAnnotations()
            }
        })
    }
    
    //MARK: add annotations
    
    private func addAnnotations() {
        
        for spot in allSpots {
            guard let nickname = spot.nickname else {return}
            guard let lat = spot.latitude else {return}
            guard let long = spot.longitude else {return}
            guard let type = spot.spotType else {return}
            
            
            let annotiation = spotAnnotation(nickName: nickname, spottype: type, model: spot, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
            mapView.addAnnotation(annotiation)
        }
            
    }
    
    private func animateSpot() {
        UIView.animate(withDuration: 0.4, animations: {
            self.childVC.view.alpha = 1
        })
        childVC.view.isUserInteractionEnabled = true
    }

    
    
    //MARK: uploading content
    
    
    @objc func didTapAdd() {
        let ac = UIAlertController(title: "select an upload option", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "upload a clip", style: .default) { [weak self] _ in

            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = ClipCheckPermisssionsViewController(spot: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = ClipAskForSpotViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload a spot", style: .default) { [weak self] _ in
            guard self?.cameraAuthorizationStatus == .granted else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard self?.MicrophoneAuthorizationStatus == .granted else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            
            let vc = SpotCameraViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload an item for local resale", style: .default) { [weak self] _ in
            guard self?.cameraAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard self?.MicrophoneAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
                
            }
            
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            let vc = GearCameraViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload a normal post", style: .default, handler: {
            [weak self] _ in
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = CheckNormalPhotoLibraryAccessViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = uploadNormalPostViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }))
            
            
        ac.addAction(UIAlertAction(title: "upload a full length", style: .default) { [weak self] _ in
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = CheckPhotoLibraryPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = FulllengthUploadViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        present(ac, animated: true)
    }

    
    
}

//MARK: delegates


extension WorldViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdate")
        guard let latestLocation = locations.first else {return}
        if currentLocation == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
            addAnnotations()
        }
        currentLocation = latestLocation.coordinate
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
            configureLocationServices()
            mapView.isHidden = false
            AuthorizationLabel.isHidden = true
            AuthorizationImageView.isHidden = true
            updateButton.isHidden = true
            updateButton.isUserInteractionEnabled = false
        } else {
            mapView.isHidden = true
            AuthorizationLabel.isHidden = false
            AuthorizationImageView.isHidden = false
            updateButton.isHidden = false
            updateButton.isUserInteractionEnabled = true
            
        }
    }

}

extension WorldViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //when they select an annotation show them a preview of the spots
        
        let current = view.annotation?.title! ?? ""
        self.current = current
        guard let selectedSpot = allSpots.firstIndex(where: { [weak self] SpotModel in
            SpotModel.nickname == self?.current
        }) else {return
            print("issue selecting spot")
        }
        let spotname = allSpots[selectedSpot].nickname
        let images = allSpots[selectedSpot].photoUrls
        guard let firstImage = images.first else {return}
        let imageUrl = URL(string: firstImage)
        childVC.spotName.text = spotname
        DispatchQueue.main.async {
            self.childVC.imageView.sd_setImage(with: imageUrl, completed: nil)
            self.animateSpot()
        }
    }
    
    
}

extension WorldViewController: SpotAnnotationViewDelegate {
    func SpoAnnotationViewDelegateDidTapButton(_ spotAnnotationView: SpotAnnotationView) {
        print("tapped")
        guard let selectedSpot = allSpots.firstIndex(where: { [weak self] SpotModel in
            SpotModel.nickname == self?.current
        }) else {return
        }
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        
        let spot = allSpots[selectedSpot]
        let saveStatus = spot.savers.contains(email)
        guard let type = spot.spotType else {return}
        guard let lat = spot.latitude else {return}
        guard let long = spot.longitude else {return}
        guard let nickname = spot.nickname else {return}
        guard let addy = spot.address else {return}
        guard let spotId = spot.spotId else {return}
        guard let info = spot.caption else {return}
       
        
        
        let vc = SpotDetailViewController(spot: SpotModel(location: addy, spotPhotoUrl: spot.photoUrls, spotType: type, nickName: nickname, postedBy: spot.posterUsername, latitude: lat, longitude: long, spotId: spotId, savers:spot.savers, spotInfo: info, isSaved: saveStatus), post: spot)
        vc.completion = {
            bool in
            NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
        }
        navigationController?.pushViewController(vc, animated: true)
    
    }
    
    
}

//MARK: spot preview

extension WorldViewController: SpotPreviewViewDelegate {
    func SpotPreviewViewDelegateDidTapMoreButton(_ SpotPreviewView: SpotPreviewView) {
        print(current)
        guard let selectedSpot = allSpots.firstIndex(where: { [weak self] SpotModel in
            SpotModel.nickname == self?.current
        }) else {
            print("something went wrong")
            return

        }
        var spot = allSpots[selectedSpot]
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        let saveStatus = spot.savers.contains(email)
        
        guard let type = spot.spotType else {return}
        guard let lat = spot.latitude else {return}
        guard let long = spot.longitude else {return}
        guard let nickname = spot.nickname else {return}
        guard let addy = spot.address else {return}
        guard let spotId = spot.spotId else {return}
        guard let info = spot.caption else {return}
        
        let vc = SpotDetailViewController(spot: SpotModel(location: addy, spotPhotoUrl: spot.photoUrls, spotType: type, nickName: nickname, postedBy: spot.posterUsername, latitude: lat, longitude: long, spotId: spotId, savers: spot.savers, spotInfo: info, isSaved: saveStatus), post: spot)
        vc.completion = { [weak self] bool in
            
            //if they saved the spot update the data
            
            if bool == true {
                guard let email = UserDefaults.standard.string(forKey: "email") else {return}
                if spot.savers.contains(email) {
                    spot.savers.removeAll { $0 == email }
                } else {
                    spot.savers.append(email)
                }
                self?.allSpots[selectedSpot] = spot
            }
            
            
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func SpotPreviewViewDelegateDidTapClose(_ SpotPreviewView: SpotPreviewView) {
        
        //close the preview
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, animations: {
                self.childVC.view.alpha = 0
            })
        }
        childVC.view.isUserInteractionEnabled = false
    }
}

