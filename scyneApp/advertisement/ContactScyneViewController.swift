//
//  ContactScyneViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/24/21.
//

import UIKit

class ContactScyneViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "contact the email below, with your number, name and some general info, we will get back to you shortly to create your account"
        label.textColor = .white
        label.numberOfLines = 3
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "scyneskateapp@gmail.com"
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(emailLabel)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 15, y: view.safeAreaInsets.top + 10, width: view.width - 30, height: 70)
        emailLabel.frame = CGRect(x: 15, y: label.bottom + 20, width: view.width - 30, height: 30)
    }
    

   

}
