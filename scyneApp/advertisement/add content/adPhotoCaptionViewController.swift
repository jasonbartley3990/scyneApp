//
//  adPhotoCaptionViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit
import JGProgressHUD

class adPhotoCaptionViewController: UIViewController {

    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private let images: [UIImage]
    
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
        return textView
    }()
    
    init(company: String, logo: UIImage, link: String, images: [UIImage], product: String, text: String) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        self.images = images
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
        
        var caption = textView.text ?? ""
        
        guard !(caption.count > 300) else {
            spinner.dismiss()
            let ac = UIAlertController(title: "max 300 characters", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel))
            present(ac, animated: true)
            return
            
        }
        
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            errorLoadingPost()
            spinner.dismiss()
            return }
        
        guard let logoData = self.companyLogo.pngData() else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        
        guard let newId = newLogoId() else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        
        let num = images.count
        
        var imageDatas: [Data] = []
        
        for x in 0..<num {
            guard let data = images[x].pngData() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            imageDatas.append(data)
        }
        
        let dataNum = imageDatas.count
        
        guard dataNum != 0 else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        
        var urls = [String]()
        
        if dataNum == 1 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                
                
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
                    
                
                    //newItem
                    let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 1, caption: caption, companyPhoto: logoString)
                    
                    DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                        [weak self] success in
                        
                        if success {
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
        
        if dataNum == 2 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newPostId2 = createNewPostId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                StorageManager.shared.uploadAdPhoto(with: imageDatas[1], postId: newPostId2, completion: { [weak self] newPostUrl2 in
                    guard let url2 = newPostUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
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
                        
                    
                        //newItem
                        let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 2, caption: caption, companyPhoto: logoString)
                        
                        DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                            [weak self] success in
                            
                            if success {
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
                })
            }
        
        
        
        if dataNum == 3 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newPostId2 = createNewPostId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                StorageManager.shared.uploadAdPhoto(with: imageDatas[1], postId: newPostId2, completion: { [weak self] newPostUrl2 in
                    guard let url2 = newPostUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let newPostId3 = createNewPostId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    
                    StorageManager.shared.uploadAdPhoto(with: imageDatas[2], postId: newPostId3, completion: { [weak self] newPostUrl3 in
                        guard let url3 = newPostUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
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
                            
                        
                            //newItem
                            let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 3, caption: caption, companyPhoto: logoString)
                            
                            DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                                [weak self] success in
                                
                                if success {
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
                    })
                })
                }
        
        
        if dataNum == 4 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newPostId2 = createNewPostId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                StorageManager.shared.uploadAdPhoto(with: imageDatas[1], postId: newPostId2, completion: { [weak self] newPostUrl2 in
                    guard let url2 = newPostUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let newPostId3 = createNewPostId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    
                    StorageManager.shared.uploadAdPhoto(with: imageDatas[2], postId: newPostId3, completion: { [weak self] newPostUrl3 in
                        guard let url3 = newPostUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
                        guard let newPostId4 = createNewPostId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return
                        }
                        
                        StorageManager.shared.uploadAdPhoto(with: imageDatas[3], postId: newPostId4, completion: { [weak self] newPostUrl4 in
                            guard let url4 = newPostUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                        
                        
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
                                
                            
                                //newItem
                                let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 4, caption: caption, companyPhoto: logoString)
                                
                                DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                                    [weak self] success in
                                    
                                    if success {
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
                        })
                    })
                })
                    }
        
        
        
        if dataNum == 5 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newPostId2 = createNewPostId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                StorageManager.shared.uploadAdPhoto(with: imageDatas[1], postId: newPostId2, completion: { [weak self] newPostUrl2 in
                    guard let url2 = newPostUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let newPostId3 = createNewPostId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    
                    StorageManager.shared.uploadAdPhoto(with: imageDatas[2], postId: newPostId3, completion: { [weak self] newPostUrl3 in
                        guard let url3 = newPostUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
                        guard let newPostId4 = createNewPostId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return
                        }
                        
                        StorageManager.shared.uploadAdPhoto(with: imageDatas[3], postId: newPostId4, completion: { [weak self] newPostUrl4 in
                            guard let url4 = newPostUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            
                            guard let newPostId5 = createNewPostId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return
                            }
                            
                            StorageManager.shared.uploadAdPhoto(with: imageDatas[4], postId: newPostId5, completion: { [weak self] newPostUrl5 in
                                guard let url5 = newPostUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                
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
                                    
                                
                                    //newItem
                                    let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 5, caption: caption, companyPhoto: logoString)
                                    
                                    DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                                        [weak self] success in
                                        
                                        if success {
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
                            })
                        })
                    })
                })
                        }
        
        
        if dataNum == 6 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newPostId2 = createNewPostId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                StorageManager.shared.uploadAdPhoto(with: imageDatas[1], postId: newPostId2, completion: { [weak self] newPostUrl2 in
                    guard let url2 = newPostUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let newPostId3 = createNewPostId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    
                    StorageManager.shared.uploadAdPhoto(with: imageDatas[2], postId: newPostId3, completion: { [weak self] newPostUrl3 in
                        guard let url3 = newPostUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
                        guard let newPostId4 = createNewPostId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return
                        }
                        
                        StorageManager.shared.uploadAdPhoto(with: imageDatas[3], postId: newPostId4, completion: { [weak self] newPostUrl4 in
                            guard let url4 = newPostUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            
                            guard let newPostId5 = createNewPostId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return
                            }
                            
                            StorageManager.shared.uploadAdPhoto(with: imageDatas[4], postId: newPostId5, completion: { [weak self] newPostUrl5 in
                                guard let url5 = newPostUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                
                                
                                guard let newPostId6 = createNewPostId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return
                                }
                                
                                StorageManager.shared.uploadAdPhoto(with: imageDatas[5], postId: newPostId6, completion: { [weak self] newPostUrl6 in
                                    guard let url6 = newPostUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                
                                
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
                                    
                                
                                    //newItem
                                    let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 6, caption: caption, companyPhoto: logoString)
                                    
                                    DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                                        [weak self] success in
                                        
                                        if success {
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
                            })
                        })
                    })
                })
            })
        }
        
        
        if dataNum == 7 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newPostId2 = createNewPostId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                StorageManager.shared.uploadAdPhoto(with: imageDatas[1], postId: newPostId2, completion: { [weak self] newPostUrl2 in
                    guard let url2 = newPostUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let newPostId3 = createNewPostId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    
                    StorageManager.shared.uploadAdPhoto(with: imageDatas[2], postId: newPostId3, completion: { [weak self] newPostUrl3 in
                        guard let url3 = newPostUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
                        guard let newPostId4 = createNewPostId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return
                        }
                        
                        StorageManager.shared.uploadAdPhoto(with: imageDatas[3], postId: newPostId4, completion: { [weak self] newPostUrl4 in
                            guard let url4 = newPostUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            
                            guard let newPostId5 = createNewPostId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return
                            }
                            
                            StorageManager.shared.uploadAdPhoto(with: imageDatas[4], postId: newPostId5, completion: { [weak self] newPostUrl5 in
                                guard let url5 = newPostUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                
                                
                                guard let newPostId6 = createNewPostId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return
                                }
                                
                                StorageManager.shared.uploadAdPhoto(with: imageDatas[5], postId: newPostId6, completion: { [weak self] newPostUrl6 in
                                    guard let url6 = newPostUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    
                                    
                                    guard let newPostId7 = createNewPostId() else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return
                                    }
                                    
                                    StorageManager.shared.uploadAdPhoto(with: imageDatas[6], postId: newPostId7, completion: { [weak self] newPostUrl7 in
                                        guard let url7 = newPostUrl7 else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        let string7 = url7.absoluteString
                                        urls.append(string7)
                                
                                
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
                                            
                                        
                                            //newItem
                                            let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 7, caption: caption, companyPhoto: logoString)
                                            
                                            DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                                                [weak self] success in
                                                
                                                if success {
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
                                    })
                                })
                            })
                        })
                    })
                    })
                }
        
        
        if dataNum == 8 {
            guard let newPostId = createNewPostId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadAdPhoto(with: imageDatas[0], postId: newPostId, completion: { [weak self] newPostUrl in
                guard let url = newPostUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newPostId2 = createNewPostId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                
                
                StorageManager.shared.uploadAdPhoto(with: imageDatas[1], postId: newPostId2, completion: { [weak self] newPostUrl2 in
                    guard let url2 = newPostUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let newPostId3 = createNewPostId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    
                    StorageManager.shared.uploadAdPhoto(with: imageDatas[2], postId: newPostId3, completion: { [weak self] newPostUrl3 in
                        guard let url3 = newPostUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
                        guard let newPostId4 = createNewPostId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return
                        }
                        
                        StorageManager.shared.uploadAdPhoto(with: imageDatas[3], postId: newPostId4, completion: { [weak self] newPostUrl4 in
                            guard let url4 = newPostUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            
                            guard let newPostId5 = createNewPostId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return
                            }
                            
                            StorageManager.shared.uploadAdPhoto(with: imageDatas[4], postId: newPostId5, completion: { [weak self] newPostUrl5 in
                                guard let url5 = newPostUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                
                                
                                guard let newPostId6 = createNewPostId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return
                                }
                                
                                StorageManager.shared.uploadAdPhoto(with: imageDatas[5], postId: newPostId6, completion: { [weak self] newPostUrl6 in
                                    guard let url6 = newPostUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    
                                    
                                    guard let newPostId7 = createNewPostId() else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return
                                    }
                                    
                                    StorageManager.shared.uploadAdPhoto(with: imageDatas[6], postId: newPostId7, completion: { [weak self] newPostUrl7 in
                                        guard let url7 = newPostUrl7 else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        let string7 = url7.absoluteString
                                        urls.append(string7)
                                        
                                        
                                        guard let newPostId8 = createNewPostId() else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return
                                        }
                                        
                                        StorageManager.shared.uploadAdPhoto(with: imageDatas[7], postId: newPostId8, completion: { [weak self] newPostUrl8 in
                                            guard let url8 = newPostUrl8 else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            let string8 = url8.absoluteString
                                            urls.append(string8)
                                
                                       
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
                                                
                                            
                                                //newItem
                                                let newAd = Advertisement(company: compName, adType: "photo", productLink: prodLink, companyLink: compLink, productLinkLabel: linkLabel, Urls: urls, urlCount: 8, caption: caption, companyPhoto: logoString)
                                                
                                                DatabaseManager.shared.createAd(email: email, ad: newAd, completion: {
                                                    [weak self] success in
                                                    
                                                    if success {
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
                                        })
                                    })
                                })
                            })
                        })
                        })
                })
                    }
            
                        
                            
                    
        
        
        func createNewPostId() -> String? {
            let dateString = Date().timeIntervalSince1970
            let randomInt = Int.random(in: 0...1000)
            guard let email = UserDefaults.standard.string(forKey: "email") else { return nil }
            
            return "\(email)\(dateString)\(randomInt)"
            
        }
        
        func newLogoId() -> String? {
            guard let email = UserDefaults.standard.string(forKey: "email") else {return nil}
            let randomNum = Int.random(in: 0...1000)
            guard let dateString = String.date(from: Date()) else {return nil}
            return "\(email)\(dateString)\(randomNum)"
            
        }
        
    }
    
    func errorLoadingPost() {
        let ac = UIAlertController(title: "something went wrong", message: "please try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(ac, animated: true)
    }

}
