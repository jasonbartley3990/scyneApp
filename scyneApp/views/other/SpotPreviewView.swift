//
//  SpotScrollUpView.swift
//  scyneApp
//
//  Created by Jason bartley on 5/12/21.
//

import UIKit

protocol SpotPreviewViewDelegate: AnyObject {
    func SpotPreviewViewDelegateDidTapClose(_ SpotPreviewView: SpotPreviewView)
    func SpotPreviewViewDelegateDidTapMoreButton(_ SpotPreviewView: SpotPreviewView)
}

class SpotPreviewView: UIViewController {
    
    weak var delegate: SpotPreviewViewDelegate?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let noSpotSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = "no spot selected"
        return label
    }()
    
    var spotName: UILabel = {
        let label = UILabel()
        label.text = "brooklyn banks"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("see more", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let closeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "xmark.circle.fill")
        imageView.layer.masksToBounds = true
        imageView.tintColor = .black
        imageView.backgroundColor = .white
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()

    
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(closeImage)
        view.addSubview(moreButton)
        view.addSubview(imageView)
        view.addSubview(spotName)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapClose))
        closeImage.addGestureRecognizer(tap)
        closeImage.isUserInteractionEnabled = true
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        view.addSubview(noSpotSelectedLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize = view.height/1.7
        let closeSize = view.height/7.9
        let buttonWidth = view.width/2
        imageView.frame = CGRect(x: (view.width - imageSize)/2, y: view.safeAreaInsets.top + 10, width: imageSize, height: imageSize)
        closeImage.frame = CGRect(x: (view.width - closeSize - 10), y: view.safeAreaInsets.top + 10, width: closeSize, height: closeSize)
        closeImage.layer.cornerRadius = closeSize
        spotName.frame = CGRect(x: 20, y: imageView.bottom + 7, width: (view.width - 40), height: 40)
        moreButton.frame = CGRect(x: (view.width - buttonWidth)/2, y: spotName.bottom + 5, width: buttonWidth, height: 30)
        
    }
    
    @objc func didTapClose() {
        delegate?.SpotPreviewViewDelegateDidTapClose(self)
    }
    
    @objc func didTapMoreButton() {
        delegate?.SpotPreviewViewDelegateDidTapMoreButton(self)
    }
}
