//
//  adVideoCaptionViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit
import JGProgressHUD

class adVideoCaptionViewController: UIViewController {
    
    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private let url: URL
    
    private let productLink: String
    
    private let linkText: String
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "caption for your ad"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = .systemFont(ofSize: 18, weight: .light)
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.white.cgColor
        return textView
    }()
    
    init(company: String, logo: UIImage, link: String, url: URL, product: String, text: String) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        self.url = url
        self.productLink = product
        self.linkText = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(textView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "post ad", style: .done, target: self, action: #selector(didTapPost))

       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: view.width - 40, height: 40)
        textView.frame = CGRect(x: 25, y: label.bottom + 15, width: view.width - 50, height: 80)
    }
    
    @objc func didTapPost() {
        textView.resignFirstResponder()
        
        spinner.show(in: view)
        
        let caption = textView.text ?? ""
        
        guard !(caption.count > 300) else {
            spinner.dismiss()
            let ac = UIAlertController(title: "max 300 characters", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel))
            present(ac, animated: true)
            return
            
        }
    
        var adUrls = [String]()
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            errorLoadingPost()
            spinner.dismiss()
            return}
        
        guard let dateString = String.date(from: Date()) else {
            spinner.dismiss()
            errorLoadingPost()
            return
        }
        
        guard let logoData = self.companyLogo.pngData() else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        
        guard let newId = newLogoId() else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        
        
        
        StorageManager.shared.uploadAdVideo(for: self.url, id: email, completion: {
            [weak self] adUrl in
            guard let adVideo = adUrl else {
                self?.spinner.dismiss()
                self?.errorLoadingPost()
                return
            }
            let urlString = adVideo.absoluteString
            adUrls.append(urlString)
            
            StorageManager.shared.uploadCompanyLogo(with: logoData, logoId: newId, email: email, completion: {
                [weak self] logoUrl in
                
                guard let newLogoUrl = logoUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                let logoString = newLogoUrl.absoluteString
                
                guard let compName = self?.companyName else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                guard let prodLink = self?.productLink else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                guard let compLink = self?.companyLink else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                guard let linkLabel = self?.linkText else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                let newAd = Advertisement(company: compName, adType: "video", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: adUrls, urlCount: 1, caption: caption, companyPhoto: logoString)
                      
                DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                    [weak self] success in
                    if success {
                        print("database manager complete")
                        DispatchQueue.main.async {
                            self?.spinner.dismiss()
                            self?.tabBarController?.tabBar.isHidden = false
                            self?.tabBarController?.selectedIndex = 0
                            self?.navigationController?.popToRootViewController(animated: false)
                        }
                        
                    } else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                    }
                    
                })
                
            })
            
        })
    

        
    }
    
    func errorLoadingPost() {
        let ac = UIAlertController(title: "something went wrong", message: "please try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    func newLogoId() -> String? {
        guard let email = UserDefaults.standard.string(forKey: "email") else {return nil}
        let randomNum = Int.random(in: 0...1000)
        guard let dateString = String.date(from: Date()) else {return nil}
        return "\(email)\(dateString)\(randomNum)"
        
    }
    

}
