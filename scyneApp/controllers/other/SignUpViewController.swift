//
//  SignUpViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import JGProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let region: String
    
    private let image: UIImage
    
    private let nameField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "Enter your name"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
    private let usernameField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "Username"
        field.keyboardType = .default
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
    private let emailField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "Email address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
    
    private let passwordField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "Password"
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        field.isSecureTextEntry = true
        return field
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let userAgreementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.text = "By signing up you agree to our terms and conditions and privacy policy"
        label.numberOfLines = 2
        return label
    }()
    
    private let checkedButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let viewTermsButton: UIButton = {
        let button = UIButton()
        button.setTitle("view terms here", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        return button
    }()
    
    private var didAgree = false

    public var completion: (() -> Void)?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    init(region: String, image: UIImage) {
        self.region = region
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "SIGN UP"
        view.backgroundColor = .black
        //view.addSubview(profilePictureImageView)
        view.addSubview(nameField)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(userAgreementLabel)
        view.addSubview(checkedButton)
        view.addSubview(viewTermsButton)
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        checkedButton.addTarget(self, action: #selector(didTapAgree), for: .touchUpInside)
        viewTermsButton.addTarget(self, action: #selector(didTapViewTerms), for: .touchUpInside)
        addButtonActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let termsButtonWidth: CGFloat = 140
        nameField.frame = CGRect(x: 25, y: view.safeAreaInsets.top + 15, width: view.width-50, height: 45)
        usernameField.frame = CGRect(x: 25, y: nameField.bottom+10, width: view.width-50, height: 45)
        emailField.frame = CGRect(x:25, y: usernameField.bottom+10, width: view.width-50, height: 45)
        passwordField.frame = CGRect(x: 25, y: emailField.bottom+10, width: view.width-50, height: 45)
        signUpButton.frame = CGRect(x: 35, y: passwordField.bottom+17, width: view.width-70, height: 45)
        checkedButton.frame = CGRect(x: 25, y: signUpButton.bottom + 18.5, width: 35, height: 35)
        userAgreementLabel.frame = CGRect(x: 65, y: signUpButton.bottom + 16, width: view.width - 95, height: 40)
        viewTermsButton.frame = CGRect(x: (view.width - termsButtonWidth)/2 , y: userAgreementLabel.bottom + 8, width: termsButtonWidth, height: 25)

        
    }
    
    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignUp()
        }
        return true
    }
    
    @objc private func didTapAgree() {
        if didAgree == false {
            didAgree = true
            let checkedImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            DispatchQueue.main.async {
                self.checkedButton.setImage(checkedImage, for: .normal)
                self.checkedButton.tintColor = .systemGreen
            }
        } else {
            didAgree = false
            let checkedImage = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            DispatchQueue.main.async {
                self.checkedButton.setImage(checkedImage, for: .normal)
                self.checkedButton.tintColor = .white
            }
        }
        
        
    }
    
    @objc func didTapViewTerms() {
        let vc = TermsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapSignUp() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        spinner.show(in: view)
        
        //checks that the fields are not empty

        guard let email = emailField.text, let password = passwordField.text, var username = usernameField.text, let name = nameField.text,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            
            spinner.dismiss()
            
            let ac = UIAlertController(title: "Empty fields", message: "Please make sure all fields are filled out.", preferredStyle: .alert )
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
            return
            
        }
        
        //checks regexs
        
        let passwordResult = isValidPassword(password)
        
        let emailResult = isValidEmail(email)
        
        let usernameResult = isValidUsername(username)
        
        guard usernameResult else {
            spinner.dismiss()
            //username invalid
            let ac = UIAlertController(title: "Invalid username", message: "Usernames must only contain letters and numbers, or underscores, and must be between 2 and 14 characters in length", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
            return
        }
        
        username = username.lowercased()
        
        guard passwordResult else {
            spinner.dismiss()
            //password not valid
            let ac = UIAlertController(title: "Invalid password", message: "please make sure password is longer than 8 characters, and contains at least one number, and one uppercase letter. No special characters", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
            return
            
        }
        
        guard emailResult else {
            //invalid email
            DispatchQueue.main.async {
                self.spinner.dismiss()
                let ac = UIAlertController(title: "Invalid email", message: "Please make sure you entered a valid email", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(ac, animated: true)
            }
            return
        }
        
        guard didAgree else {
            //the user needs to agree to terms and conditions
            DispatchQueue.main.async {
                self.spinner.dismiss()
                let ac = UIAlertController(title: "Please agree to terms and conditions", message: "Please check the circle to agree to terms", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(ac, animated: true)
            }
            return
            
        }
        
        
        //checks if the username is already in use
        
        DatabaseManager.shared.findUser(with: email, completion: {
            [weak self] user in
            if user == nil {
                DatabaseManager.shared.findUserWithUsername(with: username, completion: {
                    [weak self] usernameIsFound in
                    if usernameIsFound == nil {
                        let data = self?.image.pngData()
                        
                        guard let region = self?.region else {return}
                        
                        //confirms that this is the username and password they want because they cannot change username or password in the first version
                        
                        let ac = UIAlertController(title: "Confirm", message: "Username and email cannot be changed once account is created, do you wish to continue", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "sign up", style: .default, handler: {
                            [weak self] _ in
                            //sign in with auth manager
                            AuthManager.shared.signUp(email: email, userName: username, password: password, profilePicture: data, region: region, completion: {
                                [weak self] result in
                                DispatchQueue.main.async {
                                    self?.spinner.dismiss()
                                    
                                    switch result {
                                    case .success(let user):
                                        let newInfo = UserInfo(name: name, bio: "", link: "")
                                        DatabaseManager.shared.setUserInfoWithEmail(userInfo: newInfo, email: email, completion: {
                                            success in
                                            if success {
                                                print("success in setting data")
                                            } else {
                                                print("no success")
                                            }})
                                        
                                        
                                        UserDefaults.standard.setValue(user.email, forKey: "email")
                                        UserDefaults.standard.setValue(user.username, forKey: "username")
                                        UserDefaults.standard.setValue(user.region, forKey: "region")
                                        self?.navigationController?.popToRootViewController(animated: true)
                                        self?.completion?()
                                    case .failure(let error):
                                        print("\n\nsign up error: \(error)")
                                    }
                                    
                                }
                            })
                            
                            
                        }))
                        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        DispatchQueue.main.async {
                            self?.present(ac, animated: true, completion: nil)
                        }
                        
                    } else {
                        //username already in use
                        DispatchQueue.main.async {
                            self?.spinner.dismiss()
                            let ac = UIAlertController(title: "Username already in use", message: "Pick another username", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                            DispatchQueue.main.async {
                                self?.present(ac, animated: true)
                            }
                        }
                    }
                })
            } else {
                //email already in use
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    let ac = UIAlertController(title: "Email in use", message: "Pick another email", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    DispatchQueue.main.async {
                        self?.present(ac, animated: true)
                    }
                }
            }
        })
                
        
        
    }
    
    //MARK: Regexs
    

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$"
        
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let RegEx = "\\w{2,14}"
        let usernamePred = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return usernamePred.evaluate(with: username)
    }


}
