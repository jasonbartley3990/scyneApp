//
//  ItemDescriptionViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import UIKit
import JGProgressHUD

class ItemDescriptionViewController: UIViewController, UITextViewDelegate {
    
    private var images: [UIImage]
    
    private let askingPrice: String
    
    private let itemType: String
    
    private let spinner = JGProgressHUD(style: .dark)
    
    init(asking: String, image: [UIImage], itemType: String) {
        self.askingPrice = asking
        self.images = image
        self.itemType = itemType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "write a description about what you are selling"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "add description..."
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = .systemFont(ofSize: 18, weight: .light)
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.white.cgColor
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(textView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "post", style: .done, target: self, action: #selector(didTapPost))
        textView.delegate = self
        
        //you dont want the user to post more than 8 photos, so dont allow them to go back
        if images.count == 8 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let labelSize: CGFloat = (view.width - 50)
        label.frame = CGRect(x: (view.width - labelSize)/2 , y: view.safeAreaInsets.top + 25, width: labelSize, height: 50)
        textView.frame = CGRect(x: 20, y: label.bottom + 15, width: view.width - 40, height: 100)
        
    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func didTapPost() {
        textView.resignFirstResponder()
        
        spinner.show(in: view)
        
        var captionBare = textView.text ?? ""
        if captionBare == "add description..." {
            captionBare = ""
        }
        
        let caption = captionBare.trimingLeadingSpaces()
        
        guard !(caption.count > 300) else {
            spinner.dismiss()
            let ac = UIAlertController(title: "max 300 characters", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel))
            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
            return
            
        }
        
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            spinner.dismiss()
            errorLoadingPost()
            return }
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            spinner.dismiss()
            errorLoadingPost()
            return }
        guard let region = UserDefaults.standard.string(forKey: "region") else {
            spinner.dismiss()
            errorLoadingPost()
            return }
        guard let dateString = String.date(from: Date()) else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        
        
        let unixDate = NSDate().timeIntervalSince1970
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
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                
                guard let type = self?.itemType else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                guard let price = self?.askingPrice else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
            
                //newItem
                let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls, urlCount: 1, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil,  videoThumbnail: nil)
                
                
                //upload to database
               
                
                DatabaseManager.shared.createPost(newPost: newItem) {
                    [weak self] finish in
                    guard finish else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    DispatchQueue.main.async {
                        self?.spinner.dismiss()
                        self?.tabBarController?.tabBar.isHidden = false
                        self?.tabBarController?.selectedIndex = 0
                        self?.navigationController?.popToRootViewController(animated: false)
                        NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                        
                    }
                }
            })
        }
        
        if dataNum == 2 {
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let itemId2 = createNewItemId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadItem(data: imageDatas[1], id: itemId2, completion: { [weak self] newItemUrl2 in
                    guard let url2 = newItemUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let type = self?.itemType else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    guard let price = self?.askingPrice else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    //newItem
                    let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls, urlCount: 2, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil, videoThumbnail: nil)
                    
                  
                    
                    //upload to database
                    
                    DatabaseManager.shared.createPost(newPost: newItem) {
                        [weak self] finish in
                        guard finish else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return
                        }
                        DispatchQueue.main.async {
                            self?.spinner.dismiss()
                            self?.tabBarController?.tabBar.isHidden = false
                            self?.tabBarController?.selectedIndex = 0
                            self?.navigationController?.popToRootViewController(animated: false)
                            NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                            
                        }
                    }
                })
            })
            }
        
        if dataNum == 3 {
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let itemId2 = createNewItemId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadItem(data: imageDatas[1], id: itemId2, completion: { [weak self] newItemUrl2 in
                    guard let url2 = newItemUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let itemId3 = createNewItemId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadItem(data: imageDatas[2], id: itemId3, completion: { [weak self] newItemUrl3 in
                        guard let url3 = newItemUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
                        guard let type = self?.itemType else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        guard let price = self?.askingPrice else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        //newItem
                        let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls,urlCount: 3, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil, videoThumbnail: nil)
                        
                        
                        
                        //upload to database
                        
                        DatabaseManager.shared.createPost(newPost: newItem) {
                            [weak self] finish in
                            guard finish else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return
                            }
                            DispatchQueue.main.async {
                                self?.spinner.dismiss()
                                self?.tabBarController?.tabBar.isHidden = false
                                self?.tabBarController?.selectedIndex = 0
                                self?.navigationController?.popToRootViewController(animated: false)
                                NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                            }
                        }
                    })
                })
            })
        }
        
        if dataNum == 4 {
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let itemId2 = createNewItemId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadItem(data: imageDatas[1], id: itemId2, completion: { [weak self] newItemUrl2 in
                    guard let url2 = newItemUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let itemId3 = createNewItemId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadItem(data: imageDatas[2], id: itemId3, completion: { [weak self] newItemUrl3 in
                        guard let url3 = newItemUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let itemId4 = createNewItemId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadItem(data: imageDatas[3], id: itemId4, completion: { [weak self] newItemUrl4 in
                            guard let url4 = newItemUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            
                            guard let type = self?.itemType else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            guard let price = self?.askingPrice else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            //newItem
                            let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls, urlCount: 4, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil, videoThumbnail: nil)
                            
                            
                            
                            //upload to database
                            
                            DatabaseManager.shared.createPost(newPost: newItem) {
                                [weak self] finish in
                                guard finish else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return
                                }
                                DispatchQueue.main.async {
                                    self?.spinner.dismiss()
                                    self?.tabBarController?.tabBar.isHidden = false
                                    self?.tabBarController?.selectedIndex = 0
                                    self?.navigationController?.popToRootViewController(animated: false)
                                    NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                    
                                    
                                }
                            }
                            
                        })
                    })
                })
            })
        }
        
        if dataNum == 5 {
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let itemId2 = createNewItemId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadItem(data: imageDatas[1], id: itemId2, completion: { [weak self] newItemUrl2 in
                    guard let url2 = newItemUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let itemId3 = createNewItemId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadItem(data: imageDatas[2], id: itemId3, completion: { [weak self] newItemUrl3 in
                        guard let url3 = newItemUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let itemId4 = createNewItemId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadItem(data: imageDatas[3], id: itemId4, completion: { [weak self] newItemUrl4 in
                            guard let url4 = newItemUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let itemId5 = createNewItemId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadItem(data: imageDatas[4], id: itemId5, completion: { [weak self] newItemUrl5 in
                                guard let url5 = newItemUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                
                                guard let type = self?.itemType else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                guard let price = self?.askingPrice else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                //newItem
                                let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls, urlCount: 5, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil, videoThumbnail: nil)
                                
                                
                                
                                //upload to database
                                
                                DatabaseManager.shared.createPost(newPost: newItem) {
                                    [weak self] finish in
                                    guard finish else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        self?.spinner.dismiss()
                                        self?.tabBarController?.tabBar.isHidden = false
                                        self?.tabBarController?.selectedIndex = 0
                                        self?.navigationController?.popToRootViewController(animated: false)
                                        NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                        
                                    }
                                }
                            })
                        })
                    })
                })
            })
        }
        
        if dataNum == 6 {
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let itemId2 = createNewItemId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadItem(data: imageDatas[1], id: itemId2, completion: { [weak self] newItemUrl2 in
                    guard let url2 = newItemUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let itemId3 = createNewItemId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadItem(data: imageDatas[2], id: itemId3, completion: { [weak self] newItemUrl3 in
                        guard let url3 = newItemUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let itemId4 = createNewItemId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadItem(data: imageDatas[3], id: itemId4, completion: { [weak self] newItemUrl4 in
                            guard let url4 = newItemUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let itemId5 = createNewItemId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadItem(data: imageDatas[4], id: itemId5, completion: { [weak self] newItemUrl5 in
                                guard let url5 = newItemUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                guard let itemId6 = createNewItemId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                StorageManager.shared.uploadItem(data: imageDatas[5], id: itemId6, completion: { [weak self] newItemUrl6 in
                                    guard let url6 = newItemUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    
                                    guard let type = self?.itemType else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    guard let price = self?.askingPrice else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    
                                    //newItem
                                    let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls,urlCount: 6, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil, videoThumbnail: nil)
                                    
                                    
                                    
                                    //upload to database
                                    
                                    DatabaseManager.shared.createPost(newPost: newItem) {
                                        [weak self] finish in
                                        guard finish else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            self?.spinner.dismiss()
                                            self?.tabBarController?.tabBar.isHidden = false
                                            self?.tabBarController?.selectedIndex = 0
                                            self?.navigationController?.popToRootViewController(animated: false)
                                            NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                            
                                        }
                                    }
                            })
                        })
                    })
                })
            })
            })
        }
        
        if dataNum == 7 {
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let itemId2 = createNewItemId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadItem(data: imageDatas[1], id: itemId2, completion: { [weak self] newItemUrl2 in
                    guard let url2 = newItemUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let itemId3 = createNewItemId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadItem(data: imageDatas[2], id: itemId3, completion: { [weak self] newItemUrl3 in
                        guard let url3 = newItemUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let itemId4 = createNewItemId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadItem(data: imageDatas[3], id: itemId4, completion: { [weak self] newItemUrl4 in
                            guard let url4 = newItemUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let itemId5 = createNewItemId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadItem(data: imageDatas[4], id: itemId5, completion: { [weak self] newItemUrl5 in
                                guard let url5 = newItemUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                guard let itemId6 = createNewItemId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                StorageManager.shared.uploadItem(data: imageDatas[5], id: itemId6, completion: { [weak self] newItemUrl6 in
                                    guard let url6 = newItemUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    guard let itemId7 = createNewItemId() else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    
                                    StorageManager.shared.uploadItem(data: imageDatas[6], id: itemId7, completion: { [weak self] newItemUrl7 in
                                        guard let url7 = newItemUrl7 else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        let string7 = url7.absoluteString
                                        urls.append(string7)
                                        
                                        guard let type = self?.itemType else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        guard let price = self?.askingPrice else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        
                                        //newItem
                                        let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls, urlCount: 7, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil, videoThumbnail: nil)
                                        
                                        
                                        
                                        //upload to database
                                        
                                        DatabaseManager.shared.createPost(newPost: newItem) {
                                            [weak self] finish in
                                            guard finish else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return
                                            }
                                            DispatchQueue.main.async {
                                                self?.spinner.dismiss()
                                                self?.tabBarController?.tabBar.isHidden = false
                                                self?.tabBarController?.selectedIndex = 0
                                                self?.navigationController?.popToRootViewController(animated: false)
                                                NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                                
                                                
                                            }
                                        }
                                        
                                    })
                                })
                            })
                        })
                    })
                })
            })
            
        }
        
        if dataNum == 8 {
            guard let newItemId = createNewItemId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadItem(data: imageDatas[0], id: newItemId, completion: { [weak self] newItemUrl in
                guard let url = newItemUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let itemId2 = createNewItemId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadItem(data: imageDatas[1], id: itemId2, completion: { [weak self] newItemUrl2 in
                    guard let url2 = newItemUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let itemId3 = createNewItemId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadItem(data: imageDatas[2], id: itemId3, completion: { [weak self] newItemUrl3 in
                        guard let url3 = newItemUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let itemId4 = createNewItemId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadItem(data: imageDatas[3], id: itemId4, completion: { [weak self] newItemUrl4 in
                            guard let url4 = newItemUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let itemId5 = createNewItemId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadItem(data: imageDatas[4], id: itemId5, completion: { [weak self] newItemUrl5 in
                                guard let url5 = newItemUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                guard let itemId6 = createNewItemId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                StorageManager.shared.uploadItem(data: imageDatas[5], id: itemId6, completion: { [weak self] newItemUrl6 in
                                    guard let url6 = newItemUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    guard let itemId7 = createNewItemId() else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    
                                    StorageManager.shared.uploadItem(data: imageDatas[6], id: itemId7, completion: { [weak self] newItemUrl7 in
                                        guard let url7 = newItemUrl7 else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        let string7 = url7.absoluteString
                                        urls.append(string7)
                                        guard let itemId8 = createNewItemId() else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        
                                        StorageManager.shared.uploadItem(data: imageDatas[7], id: itemId8, completion: { [weak self] newItemUrl8 in
                                            guard let url8 = newItemUrl8 else {
                                                self?.spinner.dismiss()
                                                return}
                                            let string8 = url8.absoluteString
                                            urls.append(string8)
                                            
                                        guard let type = self?.itemType else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        guard let price = self?.askingPrice else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        
                                        //newItem
                                            let newItem = Post(posterEmail: email, posterUsername: username, postType: "gear", region: region, postId: newItemId, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: urls, urlCount: 8, savers: [], spotType: nil, itemType: type, askingPrice: price, latitude: nil, longitude: nil, floorLong: nil, nickname: nil, nicknameLowercase: nil, address: nil, spotId: nil, viewers: nil, videoThumbnail: nil)
                                            
                                        //upload to database
                                        
                                        DatabaseManager.shared.createPost(newPost: newItem) {
                                            [weak self] finish in
                                            guard finish else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return
                                            }
                                            DispatchQueue.main.async {
                                                self?.spinner.dismiss()
                                                self?.tabBarController?.tabBar.isHidden = false
                                                self?.tabBarController?.selectedIndex = 0
                                                self?.navigationController?.popToRootViewController(animated: false)
                                                NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                                
                                            }
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
                        
        
        func createNewItemId() -> String? {
            let randomString = UUID().uuidString
            let randomInt = Int.random(in: 0...1000)
            return "\(randomString)\(randomInt)"
            
        }
}
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "add description..." {
            textView.text = nil
        }
    }
    
    func errorLoadingPost() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "something went wrong, or bad internet connection", message: "please try again", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(ac, animated: true)
        }
        
    }
}

