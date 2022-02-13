//
//  AdTypeViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class AdTypeViewController: UIViewController {
    
    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private let videoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "video ad"
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let multiPhotoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "multi photo ad"
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    
    init(company: String, logo: UIImage, link: String) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(multiPhotoLabel)
        view.addSubview(videoLabel)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapVideo))
        videoLabel.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        multiPhotoLabel.addGestureRecognizer(tap2)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoLabel.frame = CGRect(x: 25, y: (view.height - 100)/2, width: view.width - 50, height: 40)
        multiPhotoLabel.frame = CGRect(x: 25, y: videoLabel.bottom + 20, width: view.width - 50, height: 40)
        
    }
    
    @objc func didTapVideo() {
        let vc = adVideoSelectorViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapPhoto() {
        let vc = adPhotoSelectorViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, images: [])
        navigationController?.pushViewController(vc, animated: true)
    }
    

    

}
