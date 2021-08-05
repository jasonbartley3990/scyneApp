//
//  ItemTypeViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/10/21.
//

import UIKit

class ItemTypeViewController: UIViewController {
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "what type of item is it?"
        return label
    }()
    
    private let shoeButton: UIButton = {
        let button = UIButton()
        button.setTitle(" shoe ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let deckButton: UIButton = {
        let button = UIButton()
        button.setTitle(" deck ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let wheelButton: UIButton = {
        let button = UIButton()
        button.setTitle(" wheel ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let truckButton: UIButton = {
        let button = UIButton()
        button.setTitle(" truck ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let shirtButton: UIButton = {
        let button = UIButton()
        button.setTitle(" shirt ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let pantsButton: UIButton = {
        let button = UIButton()
        button.setTitle(" pants ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 7
        return button
    }()
    
    private let headwareButton: UIButton = {
        let button = UIButton()
        button.setTitle(" head gear ", for: .normal)
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
    
    private let image: [UIImage]
    
    private let price: String
    
    init(images: [UIImage], price: String) {
        self.image = images
        self.price = price
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(questionLabel)
        view.addSubview(shoeButton)
        view.addSubview(deckButton)
        view.addSubview(wheelButton)
        view.addSubview(truckButton)
        view.addSubview(shirtButton)
        view.addSubview(pantsButton)
        view.addSubview(otherButton)
        view.addSubview(headwareButton)
        deckButton.addTarget(self, action: #selector(didTapDeck), for: .touchUpInside)
        wheelButton.addTarget(self, action: #selector(didTapWheel), for: .touchUpInside)
        otherButton.addTarget(self, action: #selector(didTapOther), for: .touchUpInside)
        shirtButton.addTarget(self, action: #selector(didTapShirt), for: .touchUpInside)
        pantsButton.addTarget(self, action: #selector(didTapPants), for: .touchUpInside)
        headwareButton.addTarget(self, action: #selector(didTapHeadware), for: .touchUpInside)
        shoeButton.addTarget(self, action: #selector(didTapShoe), for: .touchUpInside)
        truckButton.addTarget(self, action: #selector(didTapTruck), for: .touchUpInside)
        
        //we dont want users to post more than 8 photos so dont allow them to go back
        if image.count == 8 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let buttonSize: CGFloat = (view.width - 60)/2
        questionLabel.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: (view.width - 40), height: 40)
        deckButton.frame = CGRect(x: 20, y: questionLabel.bottom + 10, width: buttonSize, height: 40)
        wheelButton.frame = CGRect(x: deckButton.right + 20, y: questionLabel.bottom + 10, width: buttonSize, height: 40)
        truckButton.frame = CGRect(x: 20, y: deckButton.bottom + 10, width: buttonSize, height: 40)
        shoeButton.frame = CGRect(x: truckButton.right + 20, y: wheelButton.bottom + 10, width: buttonSize, height: 40)
        shirtButton.frame = CGRect(x: 20, y: truckButton.bottom + 10, width: buttonSize, height: 40)
        pantsButton.frame = CGRect(x: shirtButton.right + 20, y: shoeButton.bottom + 10, width: buttonSize, height: 40)
        headwareButton.frame = CGRect(x: 20, y: shirtButton.bottom + 10, width: buttonSize, height: 40)
        otherButton.frame = CGRect(x: headwareButton.right + 20, y: pantsButton.bottom + 10, width: buttonSize, height: 40)
        
    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    @objc func didTapNext() {
        let vc = ItemDescriptionViewController(asking: price, image: image, itemType: selected)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapDeck() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemTeal
            self.shoeButton.backgroundColor = .systemGreen
            self.wheelButton.backgroundColor = .systemGreen
            self.truckButton.backgroundColor = .systemGreen
            self.shirtButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.pantsButton.backgroundColor = .systemGreen
            self.headwareButton.backgroundColor = .systemGreen
        }
        selected = "deck"
        
    }
    
    @objc func didTapShoe() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemGreen
            self.shoeButton.backgroundColor = .systemTeal
            self.wheelButton.backgroundColor = .systemGreen
            self.truckButton.backgroundColor = .systemGreen
            self.shirtButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.pantsButton.backgroundColor = .systemGreen
            self.headwareButton.backgroundColor = .systemGreen
        }
    
        selected = "shoe"
        
    }
    
    @objc func didTapTruck() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemGreen
            self.shoeButton.backgroundColor = .systemGreen
            self.wheelButton.backgroundColor = .systemGreen
            self.truckButton.backgroundColor = .systemTeal
            self.shirtButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.pantsButton.backgroundColor = .systemGreen
            self.headwareButton.backgroundColor = .systemGreen
        }
        
        selected = "truck"
        
    }
    
    @objc func didTapWheel() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemGreen
            self.shoeButton.backgroundColor = .systemGreen
            self.wheelButton.backgroundColor = .systemTeal
            self.truckButton.backgroundColor = .systemGreen
            self.shirtButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.pantsButton.backgroundColor = .systemGreen
            self.headwareButton.backgroundColor = .systemGreen
        }
        
        selected = "wheel"
        
    }
    
    @objc func didTapPants() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemGreen
            self.shoeButton.backgroundColor = .systemGreen
            self.wheelButton.backgroundColor = .systemGreen
            self.truckButton.backgroundColor = .systemGreen
            self.shirtButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.pantsButton.backgroundColor = .systemTeal
            self.headwareButton.backgroundColor = .systemGreen
        }
        
        selected = "pants"
        
    }
    
    @objc func didTapShirt() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemGreen
            self.shoeButton.backgroundColor = .systemGreen
            self.wheelButton.backgroundColor = .systemGreen
            self.truckButton.backgroundColor = .systemGreen
            self.shirtButton.backgroundColor = .systemTeal
            self.otherButton.backgroundColor = .systemGreen
            self.pantsButton.backgroundColor = .systemGreen
            self.headwareButton.backgroundColor = .systemGreen
        }
        
        selected = "shirt"
        
    }
    
    @objc func didTapOther() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemGreen
            self.shoeButton.backgroundColor = .systemGreen
            self.wheelButton.backgroundColor = .systemGreen
            self.truckButton.backgroundColor = .systemGreen
            self.shirtButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemTeal
            self.pantsButton.backgroundColor = .systemGreen
            self.headwareButton.backgroundColor = .systemGreen
        }
        
        selected = "other"
        
    }
    
    @objc func didTapHeadware() {
        DispatchQueue.main.async {
            self.deckButton.backgroundColor = .systemGreen
            self.shoeButton.backgroundColor = .systemGreen
            self.wheelButton.backgroundColor = .systemGreen
            self.truckButton.backgroundColor = .systemGreen
            self.shirtButton.backgroundColor = .systemGreen
            self.otherButton.backgroundColor = .systemGreen
            self.pantsButton.backgroundColor = .systemGreen
            self.headwareButton.backgroundColor = .systemTeal
            
        }
        selected = "headgear"
        
    }
}

    
    

