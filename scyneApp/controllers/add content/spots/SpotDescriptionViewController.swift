//
//  SpotDescriptionViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/9/21.
//

import UIKit
import CoreLocation

class SpotDescriptionViewController: UIViewController, UITextViewDelegate {
    
    private let images: [UIImage]
    
    private let spotType: String
    
    private let longitude: Double
    
    private let latitude: Double
    
    private let address: String
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "(optional) write some info on the spot, to give a heads up to skaters viewing it"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = .systemFont(ofSize: 18, weight: .light)
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.white.cgColor
        return textView
    }()
    
    init(spotType: String, images: [UIImage], latitude: Double, longitude: Double, address: String) {
        self.spotType = spotType
        self.images = images
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(textView)
        view.addSubview(label)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        if images.count == 8 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 25, y: view.safeAreaInsets.top + 15, width: (view.width - 50), height: 50)
        textView.frame = CGRect(x: 20, y: label.bottom + 15, width: view.width - 40, height: 100)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "add some info" {
            textView.text = nil
        }
    }
    
    @objc func didTapNext() {
        guard !(textView.text.count > 300) else {
            let ac = UIAlertController(title: "max 300 characters", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel))
            present(ac, animated: true)
            return
            
        }
        let vc = SpotNicknameViewController(spotType: spotType, images: images, spotInfo: textView.text, latitude: latitude, longitude: longitude, address: address)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
        
    }

}


