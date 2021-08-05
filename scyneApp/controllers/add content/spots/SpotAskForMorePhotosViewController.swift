//
//  SpotAskForMorePhotosViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/9/21.
//

import UIKit
import CoreLocation

class SpotAskForMorePhotosViewController: UIViewController {

    private var image: UIImage
    
    let longitude: Double
    
    let latitude: Double
    
    let address: String
    
    private var allImages = [UIImage]()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let askLabel: UILabel = {
        let label = UILabel()
        label .textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.text = "do you wish to retake the photo?\notherwise press next"
        label.numberOfLines = 2
        return label
    }()
    
    init(imageSelected: UIImage, latitude: Double, longitude: Double, addressString: String, images: [UIImage]) {
        self.image = imageSelected
        self.latitude = latitude
        self.longitude = longitude
        self.address = addressString
        self.allImages = images
        super.init(nibName: nil, bundle: nil)
    }
    
    private let retakeButton: UIButton = {
        let button = UIButton()
        button.setTitle("retake", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(askLabel)
        view.addSubview(retakeButton)
        imageView.image = image
        retakeButton.addTarget(self, action: #selector(didTapRetake), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))

    }
    
    override func viewDidLayoutSubviews() {
        let imageSize = view.width/3.33
        let labelSize = view.width - 40
        let buttonSize: CGFloat = 120
        imageView.frame = CGRect(x: (view.width - imageSize)/2 , y: view.safeAreaInsets.top + 10, width: imageSize, height: imageSize)
        askLabel.frame = CGRect(x: (view.width - labelSize)/2, y: imageView.bottom + 10, width: labelSize, height: 50)
        retakeButton.frame = CGRect(x: (view.width - buttonSize)/2 , y: askLabel.bottom + 10, width: buttonSize, height: 40)
    }
    
    @objc func didTapNext() {
        self.allImages.append(image)
        if self.allImages.count == 8 {
            if address == "" {
                let vc = spotAddressNotFoundViewController(images: self.allImages, latitude: latitude, longitude: longitude, address: address)
                navigationController?.pushViewController(vc, animated: true)
                return
            } else {
                let vc = SpotTypeViewController(images: self.allImages, longitude: longitude, latitude: latitude, address: address)
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        let vc = SpotMultiPhotoViewController(images: allImages, latitude: latitude, longitude: longitude, address: address)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func didTapRetake() {
        let vc = SpotCameraViewController(images: self.allImages)
        navigationController?.pushViewController(vc, animated: true)
    }

   
}


