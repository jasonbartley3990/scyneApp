//
//  CheckAllPermisssionsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/7/21.
//

import UIKit

class ClipCheckPermisssionsViewController: UIViewController {
    
    private var PhotoLibraryAuthorizationStatus = RequestPhotoLiobraryAuthorizationController.getPhotoLibraryAuthorizationStatus() {
        didSet {
            setUpViewForNextAuthorizationRequest()
        }
    }
    
    private let spotId: String?
    
    init(spot: String?) {
        self.spotId = spot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        label.numberOfLines = 0
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
        view.backgroundColor = .black
        view.addSubview(button)
        view.addSubview(label)
        view.addSubview(imageView)
        setUpViewForNextAuthorizationRequest()
        button.addTarget(self, action: #selector(didTapUpdate), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        let size: CGFloat = 150
        label.sizeToFit()
        button.sizeToFit()
        imageView.frame = CGRect(x: (view.width - size)/2, y: (view.height - size)/2 - 40, width: size, height: size)
        label.frame = CGRect(x: (view.width - (view.width - 20))/2, y: imageView.bottom + 10, width: (view.width - 20), height: 40)
        button.frame = CGRect(x: (view.width - button.width)/2, y: label.bottom + 10, width: button.width, height: button.height)
        
    }
    
    @objc func didTapUpdate() {

        if PhotoLibraryAuthorizationStatus == .notRequested {
            RequestPhotoLiobraryAuthorizationController.requestPhotoLibraryAuthorizationAuthorization { [weak self] status in
                self?.PhotoLibraryAuthorizationStatus = status
                if self?.PhotoLibraryAuthorizationStatus == .granted {
                    self?.nextViewController()
                }
            }
            return
        }
        
        if PhotoLibraryAuthorizationStatus == .unAuthorized {
            openSettings()
            return
        }
        
    }
    
    private func setUpViewForNextAuthorizationRequest() {
        print(PhotoLibraryAuthorizationStatus)
        guard PhotoLibraryAuthorizationStatus == .granted else {
            label.text = "please update photo library access"
            if PhotoLibraryAuthorizationStatus == nil {
                configureForPhotoLibraryDenied()
            }
            if PhotoLibraryAuthorizationStatus == .unAuthorized {
                configureForPhotoLibraryDenied()
            }
            return
        }
        
        nextViewController()
    }
    
    func configureForPhotoLibraryDenied() {
        label.text = "photo library denied go to settings to update"
    }
    
    private func openSettings() {
        let settingsURLString = UIApplication.openSettingsURLString
        if let settingsURL = URL(string: settingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    private func nextViewController() {
        print("made it")
        let vc = ClipAskForSpotViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
