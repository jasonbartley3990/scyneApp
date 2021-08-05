//
//  createAdvertismentViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class createAdvertismentViewController: UIViewController {
    
    private let createLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "create ad"
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let viewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "view current ad"
        label.textAlignment = .center
        label.textColor = .white
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(createLabel)
        view.addSubview(viewLabel)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapCreateButton))
        createLabel.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapViewButton))
        viewLabel.addGestureRecognizer(tap2)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createLabel.frame = CGRect(x: 25, y: (view.height - 100)/2, width: view.width - 50, height: 40)
        viewLabel.frame = CGRect(x: 25, y: createLabel.bottom + 20, width: view.width - 50, height: 40)
    }
    
    @objc func didTapCreateButton() {
        let vc = companyNameViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapViewButton() {
        let vc = viewAdViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
    

}
