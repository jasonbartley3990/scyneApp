//
//  editProfileViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/11/21.
//

import UIKit

class editProfileViewController: UIViewController {

    public var completion: (() -> Void)?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "bio"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        label.text = "link"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    let nameField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "name..."
        return field
    }()
    
    let linkField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = "link..."
        return field
    }()
    
    
    let bioTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.secondaryLabel.cgColor
        textView.layer.cornerRadius = 8
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "edit profile"
        view.addSubview(nameField)
        view.addSubview(bioTextView)
        view.addSubview(nameLabel)
        view.addSubview(bioLabel)
        view.addSubview(linkLabel)
        view.addSubview(linkField)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .done, target: self, action: #selector(didTapSave))
        view.backgroundColor = .systemBackground
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        DatabaseManager.shared.getUserInfo(email: email) {
            [weak self] info in
            DispatchQueue.main.async {
                if let info = info {
                    self?.nameField.text = info.name
                    self?.bioTextView.text = info.bio
                    self?.linkField.text = info.link
                }
            }
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameLabel.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 5, width: 200, height: 30)
        nameField.frame = CGRect(x: 20, y: nameLabel.bottom + 5, width: view.width - 40, height: 30)
        bioLabel.frame = CGRect(x: 20, y: nameField.bottom + 5, width: 200, height: 30)
        bioTextView.frame = CGRect(x:20, y: bioLabel.bottom + 7, width: view.width - 40, height: 80)
        linkLabel.frame = CGRect(x: 20, y: bioTextView.bottom + 5, width: view.width - 40, height: 40)
        linkField.frame = CGRect(x: 20, y: linkLabel.bottom + 5, width: view.width - 40, height: 30)
    }
    
    @objc func didTapSave() {
        let name = nameField.text ?? ""
        let bio = bioTextView.text ?? ""
        let link = linkField.text ?? ""
        
        guard !(bio.count > 300) else {
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "max 300 characters", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self.present(ac, animated: true)
            }
            return
            
        }
        
        let newInfo = UserInfo(name: name, bio: bio, link: link)
        DatabaseManager.shared.setUserInfo(userInfo: newInfo) {
            [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.didTapClose()
                    self?.completion?()
                }
            
        }
    }
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
        
        
}
