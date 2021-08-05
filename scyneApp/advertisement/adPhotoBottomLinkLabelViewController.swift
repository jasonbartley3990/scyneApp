//
//  adPhotoBottomLinkLabelViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class adPhotoBottomLinkLabelViewController: UIViewController {

    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private let images: [UIImage]
    
    private let productLink: String
    
    let linkLabelField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = ""
        return field
    }()
    
    private let linkLabelLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.text = "enter what text label you would want attached to the product link. this will be at bottom of post\nEX: tap here to shop"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    
    init(company: String, logo: UIImage, link: String, images: [UIImage], product: String) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        self.images = images
        self.productLink = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(linkLabelLabel)
        view.addSubview(linkLabelField)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        
        if images.count == 8 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        linkLabelLabel.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: view.width - 40, height: 80)
        linkLabelField.frame = CGRect(x: 25, y: linkLabelLabel.bottom + 20, width: view.width - 50, height: 40)
    }
    
    @objc func didTapNext() {
        guard let textLabel = linkLabelField.text else {return}
        let vc = adPhotoCaptionViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, images: self.images, product: self.productLink, text: textLabel)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    

    


    

}
