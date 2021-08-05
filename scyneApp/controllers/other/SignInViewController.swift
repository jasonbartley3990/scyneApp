//
//  SignInViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import JGProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    private let scyneImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "scyneLogo")
        imageView.backgroundColor = .black
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let emailField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "email address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
    private let passwordField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "password"
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        field.isSecureTextEntry = true
        return field
    }()
    
    private let signIButton: UIButton = {
        let button = UIButton()
        button.setTitle("sign in", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("create account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "sign in"
        view.backgroundColor = .black
        view.addSubview(scyneImage)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(createAccountButton)
        view.addSubview(signIButton)
        
        emailField.delegate = self
        passwordField.delegate = self
        addButtonActions()
        // Do any additional setup after loading the view.
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scyneImage.frame = CGRect(x: (view.width - ((view.height)/3.2))/2, y: view.safeAreaInsets.top - 30, width: (view.height)/3.2, height: (view.height)/3.2)
        emailField.frame = CGRect(x: 25, y: scyneImage.bottom - 30, width: view.width-50, height: 50)
        passwordField.frame = CGRect(x:25, y: emailField.bottom+10, width: view.width-50, height: 50)
        signIButton.frame = CGRect(x:35, y: passwordField.bottom+20, width: view.width-70, height: 50)
        createAccountButton.frame = CGRect(x: 35, y: signIButton.bottom+10, width: view.width-70, height: 50)
        
    }
    
    private func addButtonActions() {
        signIButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignIn()
        }
        
        return true
    }
    
    @objc func didTapSignIn() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        //makes sure fields have valid input
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, password.count >= 8 else {
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "invalid fields", message: "please make sure all fields are filled out correctly", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(ac, animated: true)
            }
            return
        }
        
        spinner.show(in: view)
        
        //sign in with auth manager
        AuthManager.shared.signIn(email: email, password: password) {
            [weak self] result in
            DispatchQueue.main.async {
                self?.spinner.dismiss()
                
                switch result {
                case .success:
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    DispatchQueue.main.async {
                        self?.present(vc, animated: true)
                    }
                case .failure(let error):
                    let ac = UIAlertController(title: "wrong username or password", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    DispatchQueue.main.async {
                        self?.present(ac, animated: true)
                    }
                    print(error)
                }
            }
        }
        
        
    }
    
    @objc func didTapCreateAccount() {
        
        let vc = SelectRegionViewController(name: "hi")
        navigationController?.pushViewController(vc, animated: true)
        

    }
    
    
}

