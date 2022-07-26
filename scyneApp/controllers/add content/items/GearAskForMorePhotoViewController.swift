//
//  GearAskForMorePhotoViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import UIKit

class GearAskForMorePhotoViewController: UIViewController {
    
    private var image: UIImage
    
    private var images = [UIImage]()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let retakeButton: UIButton = {
        let button = UIButton()
        button.setTitle("retake", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let askLabel: UILabel = {
        let label = UILabel()
        label .textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.text = "do you wish to retake the photo?\notherwise press next"
        label.numberOfLines = 2
        return label
    }()
    
    init(imageSelected: UIImage, images: [UIImage]) {
        self.image = imageSelected
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(askLabel)
        view.addSubview(retakeButton)
        retakeButton.addTarget(self, action: #selector(didTapRetake), for: .touchUpInside)
        imageView.image = image
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))

    }
    
    override func viewDidLayoutSubviews() {
        let imageSize = view.width/2
        let labelSize = view.width - 40
        let buttonSize: CGFloat = 120
        imageView.frame = CGRect(x: (view.width - imageSize)/2 , y: view.safeAreaInsets.top + 10, width: imageSize, height: imageSize)
        askLabel.frame = CGRect(x: (view.width - labelSize)/2, y: imageView.bottom + 10, width: labelSize, height: 50)
        retakeButton.frame = CGRect(x: (view.width - 120)/2 , y: askLabel.bottom + 15, width: buttonSize, height: 40)
    }
    
    @objc func didTapNext() {
        self.images.append(self.image)
        if self.images.count == 8 {
            let vc = AskingPriceViewController(image: self.images)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = GearMultiImageViewController(images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapRetake() {
        let vc = GearCameraViewController(images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

   

}
