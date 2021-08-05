//
//  AdvertismentMenuViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/11/21.
//

import UIKit

class AdvertismentMenuViewController: UIViewController, UITextFieldDelegate {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "please enter password for advertisement account"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let passwordTextField: ScyneTextField = {
        let textfield = ScyneTextField()
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.returnKeyType = .continue
        textfield.placeholder = "password"
        return textfield
    }()
    
    private let contactButton: UIButton = {
        let button = UIButton()
        button.setTitle("contact scyne", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("submit", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        return button
    }()
    
    
    private let contactLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.text = "if you want to run ads on this app, contact us to discuss advertisement models. However only companies relevant to skateboarding will be accepted"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(passwordTextField)
        view.addSubview(label)
        view.addSubview(contactButton)
        view.addSubview(submitButton)
        view.addSubview(contactLabel)
        contactButton.addTarget(self, action: #selector(didTapContact), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        passwordTextField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.width - 20, height: 40)
        passwordTextField.frame = CGRect(x: 20, y: label.bottom + 10, width: view.width - 40, height: 40)
        submitButton.frame = CGRect(x: 20, y: passwordTextField.bottom + 10, width: view.width - 40, height: 40)
        contactLabel.frame = CGRect(x: 12, y: submitButton.bottom + 10, width: view.width - 24, height: 60)
        contactButton.frame = CGRect(x: 20, y: contactLabel.bottom + 10, width: view.width - 40, height: 40)
        
    }
    
    @objc func didTapContact() {
        let vc = ContactScyneViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapSubmitButton() {
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        guard let password = passwordTextField.text else {return}
        passwordTextField.text = nil
        
        DatabaseManager.shared.verifyAdvertisementAccount(password: password, email: email, completion: {
            [weak self] success in
            if success {
                let vc = createAdvertismentViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let ac = UIAlertController(title: "wrong password or no account establish", message: "please try again", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true)
            }
        })
        
        
        
        
        
    }
    

   

}
