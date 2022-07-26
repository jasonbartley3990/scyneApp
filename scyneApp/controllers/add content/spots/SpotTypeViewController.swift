//
//  SpotTypeViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/9/21.
//

import UIKit
import CoreLocation

class SpotTypeViewController: UIViewController {
    
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.text = "location saved"
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "what type of spot is it?"
        return label
    }()
    
    private let ledgeButton: UIButton = {
        let button = UIButton()
        button.setTitle(" ledge ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let skateparkButton: UIButton = {
        let button = UIButton()
        button.setTitle(" skatepark ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let DIYButton: UIButton = {
        let button = UIButton()
        button.setTitle(" DIY ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let plazaButton: UIButton = {
        let button = UIButton()
        button.setTitle(" plaza ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let stairButton: UIButton = {
        let button = UIButton()
        button.setTitle(" stairs ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let railButton: UIButton = {
        let button = UIButton()
        button.setTitle(" rail ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let schoolButton: UIButton = {
        let button = UIButton()
        button.setTitle(" school ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let otherButton: UIButton = {
        let button = UIButton()
        button.setTitle(" other ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private var selected = "none" {
        didSet {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
            
        }
    }
    
    private let latitude: Double
    
    private let longitude: Double
    
    private let image: [UIImage]
    
    private let address: String
    
    init(images: [UIImage], longitude: Double, latitude: Double, address: String) {
        self.image = images
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
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(questionLabel)
        view.addSubview(skateparkButton)
        view.addSubview(ledgeButton)
        view.addSubview(schoolButton)
        view.addSubview(DIYButton)
        view.addSubview(railButton)
        view.addSubview(stairButton)
        view.addSubview(otherButton)
        view.addSubview(plazaButton)
        skateparkButton.addTarget(self, action: #selector(didTapSkatepark), for: .touchUpInside)
        plazaButton.addTarget(self, action: #selector(didTapPlaza), for: .touchUpInside)
        otherButton.addTarget(self, action: #selector(didTapOther), for: .touchUpInside)
        stairButton.addTarget(self, action: #selector(didTapStairs), for: .touchUpInside)
        railButton.addTarget(self, action: #selector(didTapRail), for: .touchUpInside)
        DIYButton.addTarget(self, action: #selector(didTapDIY), for: .touchUpInside)
        schoolButton.addTarget(self, action: #selector(didTapSchool), for: .touchUpInside)
        ledgeButton.addTarget(self, action: #selector(didTapLedge), for: .touchUpInside)
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize = view.width/4
        let buttonSize: CGFloat = (view.width - 60)/2
        imageView.frame = CGRect(x: (view.width - imageSize)/2, y: view.safeAreaInsets.top + 10, width: imageSize, height: imageSize)
        label.frame = CGRect(x: (view.width - 200)/2 , y: imageView.bottom + 4, width: 200, height: 40)
        questionLabel.frame = CGRect(x: (view.width - 300)/2, y: label.bottom + 10, width: 300, height: 50)
        skateparkButton.frame = CGRect(x: 20, y: questionLabel.bottom + 10, width: buttonSize, height: 40)
        DIYButton.frame = CGRect(x: skateparkButton.right + 20, y: questionLabel.bottom + 10, width: buttonSize, height: 40)
        plazaButton.frame = CGRect(x: 20, y: skateparkButton.bottom + 10, width: buttonSize, height: 40)
        schoolButton.frame = CGRect(x: plazaButton.right + 20, y: DIYButton.bottom + 10, width: buttonSize, height: 40)
        railButton.frame = CGRect(x: 20, y: plazaButton.bottom + 10, width: buttonSize, height: 40)
        ledgeButton.frame = CGRect(x: railButton.right + 20, y: schoolButton.bottom + 10, width: buttonSize, height: 40)
        stairButton.frame = CGRect(x: 20, y: railButton.bottom + 10, width: buttonSize, height: 40)
        otherButton.frame = CGRect(x: stairButton.right + 20, y: ledgeButton.bottom + 10, width: buttonSize, height: 40)
        
    }
    
    @objc func didTapNext() {
        let vc = SpotDescriptionViewController(spotType: selected, images: image, latitude: latitude, longitude: longitude, address: address)
        navigationController?.pushViewController(vc, animated: true)

    }
    
    
    @objc func didTapSkatepark() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemTeal
            self.ledgeButton.backgroundColor = .systemGreen
            self.DIYButton.backgroundColor = .systemGreen
            self.railButton.backgroundColor = .systemGreen
            self.plazaButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.schoolButton.backgroundColor = .systemGreen
            self.stairButton.backgroundColor = .systemGreen
        }
        selected = "skatepark"
        
    }
    
    @objc func didTapDIY() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemGreen
            self.ledgeButton.backgroundColor = .systemGreen
            self.DIYButton.backgroundColor = .systemTeal
            self.railButton.backgroundColor = .systemGreen
            self.plazaButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.schoolButton.backgroundColor = .systemGreen
            self.stairButton.backgroundColor = .systemGreen
        }
        
        selected = "DIY"
        
    }
    
    @objc func didTapPlaza() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemGreen
            self.ledgeButton.backgroundColor = .systemGreen
            self.DIYButton.backgroundColor = .systemGreen
            self.railButton.backgroundColor = .systemGreen
            self.plazaButton.backgroundColor = .systemTeal
            self.otherButton.backgroundColor = .systemGreen
            self.schoolButton.backgroundColor = .systemGreen
            self.stairButton.backgroundColor = .systemGreen
        }
       
        selected = "plaza"
        
    }
    
    @objc func didTapLedge() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemGreen
            self.ledgeButton.backgroundColor = .systemTeal
            self.DIYButton.backgroundColor = .systemGreen
            self.railButton.backgroundColor = .systemGreen
            self.plazaButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.schoolButton.backgroundColor = .systemGreen
            self.stairButton.backgroundColor = .systemGreen
        }
        
        selected = "ledge"
    }
    
    @objc func didTapRail() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemGreen
            self.ledgeButton.backgroundColor = .systemGreen
            self.DIYButton.backgroundColor = .systemGreen
            self.railButton.backgroundColor = .systemTeal
            self.plazaButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.schoolButton.backgroundColor = .systemGreen
            self.stairButton.backgroundColor = .systemGreen
            
        }
        
        selected = "rail"
    }
    
    @objc func didTapStairs() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemGreen
            self.ledgeButton.backgroundColor = .systemGreen
            self.DIYButton.backgroundColor = .systemGreen
            self.railButton.backgroundColor = .systemGreen
            self.plazaButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.schoolButton.backgroundColor = .systemGreen
            self.stairButton.backgroundColor = .systemTeal
        }
        
        selected = "stairs"
    }
    
    @objc func didTapSchool() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemGreen
            self.ledgeButton.backgroundColor = .systemGreen
            self.DIYButton.backgroundColor = .systemGreen
            self.railButton.backgroundColor = .systemGreen
            self.plazaButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.schoolButton.backgroundColor = .systemTeal
            self.stairButton.backgroundColor = .systemGreen
        }
        
        selected = "school"
    }
    
    @objc func didTapOther() {
        DispatchQueue.main.async {
            self.skateparkButton.backgroundColor = .systemGreen
            self.ledgeButton.backgroundColor = .systemGreen
            self.DIYButton.backgroundColor = .systemGreen
            self.railButton.backgroundColor = .systemGreen
            self.plazaButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemTeal
            self.schoolButton.backgroundColor = .systemGreen
            self.stairButton.backgroundColor = .systemGreen
        }
        
        selected = "other"
        
    }
}

