//
//  SinglePinViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/3/21.
//

import UIKit
import MapKit

class SinglePinViewController: UIViewController {
    
    private var spot: Post
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.masksToBounds = true
        return map
    }()
    
    let childVC = SpotPreviewView()
    
    private var current: String = ""
    
    init(spot: Post) {
        self.spot = spot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        childVC.view.alpha = 0
        childVC.view.isUserInteractionEnabled = false
        childVC.delegate = self
        
        mapView.delegate = self
        mapView.register(SpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        zoom()
        createAnnotation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
        let height = view.height/2.2
        childVC.view.frame = CGRect(x: 0, y: self.view.height - height - self.view.safeAreaInsets.bottom, width: self.view.width, height: height)
    }
    
    private func createAnnotation() {
        guard let nickname = spot.nickname else {return}
        guard let lat = spot.latitude else {return}
        guard let long = spot.longitude else {return}
        guard let type = spot.spotType else {return}
        
        
        let annotiation = spotAnnotation(nickName: nickname, spottype: type, model: spot, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        mapView.addAnnotation(annotiation)
        
    }
    
    private func zoom() {
        
        guard let lat = spot.latitude else {
            print("failed")
            return}
        guard let long = spot.longitude else {
            print("failed")
            return}
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
    }
    
    private func animateSpot() {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.childVC.view.alpha = 1
        })
        childVC.view.isUserInteractionEnabled = true
    }


}

extension SinglePinViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let spotname = spot.nickname else {return}
        let images = spot.photoUrls
        guard let firstImage = images.first else {return}
        let imageUrl = URL(string: firstImage)
        childVC.spotName.text = spotname
        childVC.imageView.sd_setImage(with: imageUrl, completed: nil)
        animateSpot()
       
    }
}

extension SinglePinViewController: SpotPreviewViewDelegate {
    func SpotPreviewViewDelegateDidTapMoreButton(_ SpotPreviewView: SpotPreviewView) {
        print(current)
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        guard let type = spot.spotType else {return}
        guard let lat = spot.latitude else {return}
        guard let long = spot.longitude else {return}
        guard let nickname = spot.nickname else {return}
        guard let addy = spot.address else {return}
        guard let spotId = spot.spotId else {return}
        guard let info = spot.caption else {return}
        let saveStatus = spot.savers.contains(email)
        
        let vc = SpotDetailViewController(spot: SpotModel(location: addy, spotPhotoUrl: spot.photoUrls, spotType: type, nickName: nickname, postedBy: spot.posterUsername, latitude: lat, longitude: long, spotId: spotId, savers: spot.savers, spotInfo: info, isSaved: saveStatus), post: spot)
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func SpotPreviewViewDelegateDidTapClose(_ SpotPreviewView: SpotPreviewView) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.4, animations: {
                self?.childVC.view.alpha = 0
            })
        }
        childVC.view.isUserInteractionEnabled = false
        
    
    
}
}

