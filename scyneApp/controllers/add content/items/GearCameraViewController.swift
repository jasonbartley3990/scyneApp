//
//  GearCameraViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

class GearCameraViewController: UIViewController {
    
    private var images = [UIImage]()
    
    private var videoPreviewLayer = VideoPreviewView()
    
    private lazy var captureSessionController = CaptureSessionControllerForPhotoOnly()
    
    private var didLoad = false {
        didSet {
            hidNavBar()
        }
    }
    
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
        print("didLoad")
        view.backgroundColor = .black
        setUpNavBar()
        view.addSubview(videoPreviewLayer)
        view.addSubview(shutterButton)
        videoPreviewLayer.videoPreviewLayer.session = captureSessionController.getCaptureSession()
        shutterButton.addTarget(self, action: #selector(didTapShutter), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController!.tabBar.isHidden = true
        videoPreviewLayer.videoPreviewLayer.session = captureSessionController.getCaptureSession()
        captureSessionController.startRunnung()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationItem.rightBarButtonItem = nil
        captureSessionController.image = nil
        captureSessionController.stopRunning()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
    }
    
    private func hidNavBar() {
        tabBarController?.tabBar.isHidden = true
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
        let vc = GearAskForMorePhotoViewController(imageSelected: takenPhoto, images: self.images)
        self.images.append(takenPhoto)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
