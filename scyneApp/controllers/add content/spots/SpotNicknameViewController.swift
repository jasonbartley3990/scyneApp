//
//  SpotNicknameViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/10/21.
//

import UIKit
import CoreLocation
import JGProgressHUD

class SpotNicknameViewController: UIViewController, UITextFieldDelegate {
    
    private let images: [UIImage]
    
    private let spotType: String
    
    private let spotInfo: String
    
    private let longitude: Double
    
    private let latitude: Double
    
    private let address: String
    
    private let spinner = JGProgressHUD(style: .dark)
    
    init(spotType: String, images: [UIImage], spotInfo: String, latitude: Double, longitude: Double, address: String) {
        self.spotType = spotType
        self.images = images
        self.spotInfo = spotInfo
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        label.text = "give it a nickname"
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private let exampleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "ex: \"brooklyn banks\", \"5th st ledge\""
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.numberOfLines = 1
        return label
    }()
    
    private let nickTextField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = ""
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(exampleLabel)
        view.addSubview(nickTextField)
        nickTextField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "post", style: .done, target: self, action: #selector(didTapPost))
        
        if images.count == 8 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: (view.width - 40), height: 40)
        exampleLabel.frame = CGRect(x: 10, y: label.bottom + 4, width: (view.width - 20), height: 30)
        nickTextField.frame = CGRect(x: 20, y: exampleLabel.bottom + 20, width: (view.width - 40), height: 50)
    }
    
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
        
    }

    @objc func didTapPost() {
        nickTextField.resignFirstResponder()
        
        spinner.show(in: view)
        
        guard let nick = nickTextField.text, !nick.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            spinner.dismiss()
            let ac = UIAlertController(title: "nothing entered", message: "please enter a name", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
            present(ac, animated: true)
            return
            
        }
        
        let unixDate = NSDate().timeIntervalSince1970
        
        let num = images.count
        
        var imageDatas: [Data] = []
        
        for x in 0..<num {
            guard let data = images[x].pngData() else {return}
            imageDatas.append(data)
        }
        
        let dataNum = imageDatas.count
        
        guard dataNum != 0 else {return}
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        guard let userEmail = UserDefaults.standard.string(forKey: "email") else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        guard let region = UserDefaults.standard.string(forKey: "region") else {
            spinner.dismiss()
            errorLoadingPost()
            return}
        
        var urls = [String]()
        
        
        if dataNum == 1 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
            
            guard let addy = self?.address else {
                self?.spinner.dismiss()
                self?.errorLoadingPost()
                return}
            guard let lat = self?.latitude else {
                self?.spinner.dismiss()
                self?.errorLoadingPost()
                return}
            guard let long = self?.longitude else {
                self?.spinner.dismiss()
                self?.errorLoadingPost()
                return}
            guard let type = self?.spotType else {
                self?.spinner.dismiss()
                self?.errorLoadingPost()
                return}
            guard let spotDetails = self?.spotInfo else {
                self?.spinner.dismiss()
                self?.errorLoadingPost()
                return}
            guard let dateString = String.date(from: Date()) else {
                self?.spinner.dismiss()
                self?.errorLoadingPost()
                return}
            
                
            let flatLong = Int(floor(long))
            print(flatLong)
            let nickLower = nick.lowercased()
                
            let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 1, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long, floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil, videoThumbnail: nil)
                
                
            //upload to database
            
            DatabaseManager.shared.createPost(newPost: newPost) {
                [weak self] finish in
                guard finish else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return
                }
                guard let com = self?.spotInfo else {return}
                let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                
                let randomNum = Int.random(in: 0...9999)
                
                let newCommentId = "\(username)\(randomNum)"
                
                DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                    if success {
                        DispatchQueue.main.async {
                            self?.spinner.dismiss()
                            self?.tabBarController?.tabBar.isHidden = false
                            self?.tabBarController?.selectedIndex = 0
                            self?.navigationController?.popToRootViewController(animated: false)
                            NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                        }
                    } else {
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
        })
        }
        
        if dataNum == 2 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newSpotId2 = createNewSpotId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadSpot(data: imageDatas[1], id: newSpotId2, completion: { [weak self] newSpotUrl2 in
                    guard let url2 = newSpotUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    
                    guard let addy = self?.address else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    guard let lat = self?.latitude else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    guard let long = self?.longitude else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    guard let type = self?.spotType else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    guard let spotDetails = self?.spotInfo else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    guard let dateString = String.date(from: Date()) else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
        
                    let flatLong = Int(floor(long))
                    let nickLower = nick.lowercased()
                    
                    let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 2, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long, floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil, videoThumbnail: nil)
                    
                    //upload to database
                    
                    DatabaseManager.shared.createPost(newPost: newPost) {
                        [weak self] finish in
                        guard finish else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return
                        }
                        
                        guard let com = self?.spotInfo else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                        
                        let randomNum = Int.random(in: 0...9999)
                        
                        let newCommentId = "\(username)\(randomNum)"
                        
                        
                        DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                            if success {
                                DispatchQueue.main.async {
                                    self?.spinner.dismiss()
                                    self?.tabBarController?.tabBar.isHidden = false
                                    self?.tabBarController?.selectedIndex = 0
                                    self?.navigationController?.popToRootViewController(animated: false)
                                    NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                }
                            } else {
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
                })
                
            })
        }
        
        if dataNum == 3 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newSpotId2 = createNewSpotId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadSpot(data: imageDatas[1], id: newSpotId2, completion: { [weak self] newSpotUrl2 in
                    guard let url2 = newSpotUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let newSpotId3 = createNewSpotId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadSpot(data: imageDatas[2], id: newSpotId3, completion: { [weak self] newSpotUrl3 in
                        guard let url3 = newSpotUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        
                        guard let addy = self?.address else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        guard let lat = self?.latitude else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        guard let long = self?.longitude else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        guard let type = self?.spotType else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        guard let spotDetails = self?.spotInfo else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        guard let dateString = String.date(from: Date()) else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                    
                        let flatLong = Int(floor(long))
                        let nickLower = nick.lowercased()
                        
                        let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 3, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long, floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil, videoThumbnail: nil)
                        
                        
                        
                        //upload to database
                        
                        DatabaseManager.shared.createPost(newPost: newPost) {
                            [weak self] finish in
                            guard finish else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return
                            }
                            
                            guard let com = self?.spotInfo else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                            
                            let randomNum = Int.random(in: 0...9999)
                            
                            let newCommentId = "\(username)\(randomNum)"
                            
                            
                            DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                                if success {
                                    DispatchQueue.main.async {
                                        self?.spinner.dismiss()
                                        self?.tabBarController?.tabBar.isHidden = false
                                        self?.tabBarController?.selectedIndex = 0
                                        self?.navigationController?.popToRootViewController(animated: false)
                                        NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                    }
                                } else {
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
                    })
                })
            })
        }
                            
        
        if dataNum == 4 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newSpotId2 = createNewSpotId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadSpot(data: imageDatas[1], id: newSpotId2, completion: { [weak self] newSpotUrl2 in
                    guard let url2 = newSpotUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let newSpotId3 = createNewSpotId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadSpot(data: imageDatas[2], id: newSpotId3, completion: { [weak self] newSpotUrl3 in
                        guard let url3 = newSpotUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let newSpotId4 = createNewSpotId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadSpot(data: imageDatas[3], id: newSpotId4, completion: { [weak self] newSpotUrl4 in
                            guard let url4 = newSpotUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            
                            guard let addy = self?.address else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            guard let lat = self?.latitude else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            guard let long = self?.longitude else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            guard let type = self?.spotType else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            guard let spotDetails = self?.spotInfo else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            guard let dateString = String.date(from: Date()) else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            
                           
                            let flatLong = Int(floor(long))
                            let nickLower = nick.lowercased()
                            
                            
                            let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 4, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long, floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil, videoThumbnail: nil)
                            
                            
                            
                            
                            //upload to database
                            
                            DatabaseManager.shared.createPost(newPost: newPost) {
                                [weak self] finish in
                                guard finish else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return
                                }
                                
                                guard let com = self?.spotInfo else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                                
                                let randomNum = Int.random(in: 0...9999)
                                
                                let newCommentId = "\(username)\(randomNum)"
                                
                                
                                DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                                    if success {
                                        DispatchQueue.main.async {
                                            self?.spinner.dismiss()
                                            self?.tabBarController?.tabBar.isHidden = false
                                            self?.tabBarController?.selectedIndex = 0
                                            self?.navigationController?.popToRootViewController(animated: false)
                                            NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                        }
                                    } else {
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
                        })
                    })
                })
            })
        }
        
        if dataNum == 5 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newSpotId2 = createNewSpotId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadSpot(data: imageDatas[1], id: newSpotId2, completion: { [weak self] newSpotUrl2 in
                    guard let url2 = newSpotUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let newSpotId3 = createNewSpotId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadSpot(data: imageDatas[2], id: newSpotId3, completion: { [weak self] newSpotUrl3 in
                        guard let url3 = newSpotUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let newSpotId4 = createNewSpotId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadSpot(data: imageDatas[3], id: newSpotId4, completion: { [weak self] newSpotUrl4 in
                            guard let url4 = newSpotUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let newSpotId5 = createNewSpotId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadSpot(data: imageDatas[4], id: newSpotId5, completion: { [weak self] newSpotUrl5 in
                                guard let url5 = newSpotUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                
                                guard let addy = self?.address else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                guard let lat = self?.latitude else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                guard let long = self?.longitude else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                guard let type = self?.spotType else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                guard let spotDetails = self?.spotInfo else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                guard let dateString = String.date(from: Date()) else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                
                                let flatLong = Int(floor(long))
                                let nickLower = nick.lowercased()
                                
                                let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 5, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long, floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil, videoThumbnail: nil)
                                
                                
                                
                                //upload to database
                                
                                DatabaseManager.shared.createPost(newPost: newPost) {
                                    [weak self] finish in
                                    guard finish else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return
                                    }
                                    
                                    guard let com = self?.spotInfo else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                                    
                                    let randomNum = Int.random(in: 0...9999)
                                    
                                    let newCommentId = "\(username)\(randomNum)"
                                    
                                    
                                    DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                                        if success {
                                            DispatchQueue.main.async {
                                                self?.spinner.dismiss()
                                                self?.tabBarController?.tabBar.isHidden = false
                                                self?.tabBarController?.selectedIndex = 0
                                                self?.navigationController?.popToRootViewController(animated: false)
                                                NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self?.spinner.dismiss()
                                                self?.tabBarController?.tabBar.isHidden = false
                                                self?.tabBarController?.selectedIndex = 0
                                                self?.navigationController?.popToRootViewController(animated: false)
                                                NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                                
                                            }
                                        }
                                    })
                                
//                                    }
                                }
                            })
                        })
                    })
                    })
                })
    
        }
        
        if dataNum == 6 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newSpotId2 = createNewSpotId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadSpot(data: imageDatas[1], id: newSpotId2, completion: { [weak self] newSpotUrl2 in
                    guard let url2 = newSpotUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let newSpotId3 = createNewSpotId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadSpot(data: imageDatas[2], id: newSpotId3, completion: { [weak self] newSpotUrl3 in
                        guard let url3 = newSpotUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let newSpotId4 = createNewSpotId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadSpot(data: imageDatas[3], id: newSpotId4, completion: { [weak self] newSpotUrl4 in
                            guard let url4 = newSpotUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let newSpotId5 = createNewSpotId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadSpot(data: imageDatas[4], id: newSpotId5, completion: { [weak self] newSpotUrl5 in
                                guard let url5 = newSpotUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                guard let newSpotId6 = createNewSpotId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                StorageManager.shared.uploadSpot(data: imageDatas[5], id: newSpotId6, completion: { [weak self] newSpotUrl6 in
                                    guard let url6 = newSpotUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    
                                    guard let addy = self?.address else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    guard let lat = self?.latitude else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    guard let long = self?.longitude else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    guard let type = self?.spotType else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        
                                        return}
                                    guard let spotDetails = self?.spotInfo else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    guard let dateString = String.date(from: Date()) else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    
                                    
                                    
                                    let flatLong = Int(floor(long))
                                    let nickLower = nick.lowercased()
                                    
                                    
                                    let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 6, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long,floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil, videoThumbnail: nil)
                                    
                                    
                                    
                                    
                                    
                                    //upload to database
                                    
                                    DatabaseManager.shared.createPost(newPost: newPost) {
                                        [weak self] finish in
                                        guard finish else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return
                                        }
                                        
                                        guard let com = self?.spotInfo else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                                        
                                        let randomNum = Int.random(in: 0...9999)
                                        
                                        let newCommentId = "\(username)\(randomNum)"
                                        
                                        
                                        DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                                            if success {
                                                DispatchQueue.main.async {
                                                    self?.spinner.dismiss()
                                                    self?.tabBarController?.tabBar.isHidden = false
                                                    self?.tabBarController?.selectedIndex = 0
                                                    self?.navigationController?.popToRootViewController(animated: false)
                                                    NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                                }
                                            } else {
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
                                })
                            })
                        })
                    })
                })
            })
        }
        
        if dataNum == 7 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newSpotId2 = createNewSpotId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadSpot(data: imageDatas[1], id: newSpotId2, completion: { [weak self] newSpotUrl2 in
                    guard let url2 = newSpotUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let newSpotId3 = createNewSpotId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadSpot(data: imageDatas[2], id: newSpotId3, completion: { [weak self] newSpotUrl3 in
                        guard let url3 = newSpotUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let newSpotId4 = createNewSpotId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadSpot(data: imageDatas[3], id: newSpotId4, completion: { [weak self] newSpotUrl4 in
                            guard let url4 = newSpotUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let newSpotId5 = createNewSpotId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadSpot(data: imageDatas[4], id: newSpotId5, completion: { [weak self] newSpotUrl5 in
                                guard let url5 = newSpotUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                guard let newSpotId6 = createNewSpotId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                StorageManager.shared.uploadSpot(data: imageDatas[5], id: newSpotId6, completion: { [weak self] newSpotUrl6 in
                                    guard let url6 = newSpotUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    guard let newSpotId7 = createNewSpotId() else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    
                                    StorageManager.shared.uploadSpot(data: imageDatas[6], id: newSpotId7, completion: { [weak self] newSpotUrl7 in
                                        guard let url7 = newSpotUrl7 else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        let string7 = url7.absoluteString
                                        urls.append(string7)
                                        
                                        guard let addy = self?.address else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        guard let lat = self?.latitude else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        guard let long = self?.longitude else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        guard let type = self?.spotType else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        guard let spotDetails = self?.spotInfo else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        guard let dateString = String.date(from: Date()) else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        
                                        let flatLong = Int(floor(long))
                                        let nickLower = nick.lowercased()
                                        
                                        let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 7, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long, floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil,videoThumbnail: nil)
                                        
                                       
                                        
                                        //upload to database
                                        
                                        DatabaseManager.shared.createPost(newPost: newPost) {
                                            [weak self] finish in
                                            guard finish else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return
                                            }
                                            
                                            guard let com = self?.spotInfo else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                                            
                                            let randomNum = Int.random(in: 0...9999)
                                            
                                            let newCommentId = "\(username)\(randomNum)"
                                            
                                            
                                            DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                                                if success {
                                                    DispatchQueue.main.async {
                                                        self?.spinner.dismiss()
                                                        self?.tabBarController?.tabBar.isHidden = false
                                                        self?.tabBarController?.selectedIndex = 0
                                                        self?.navigationController?.popToRootViewController(animated: false)
                                                        NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                                    }
                                                } else {
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
                                    })
                                })
                            })
                        })
                    })
                })
            })
            }
        
        
        if dataNum == 8 {
            guard let newSpotId = createNewSpotId() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            StorageManager.shared.uploadSpot(data: imageDatas[0], id: newSpotId, completion: { [weak self] newSpotUrl in
                guard let url = newSpotUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = url.absoluteString
                urls.append(string)
                guard let newSpotId2 = createNewSpotId() else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                
                StorageManager.shared.uploadSpot(data: imageDatas[1], id: newSpotId2, completion: { [weak self] newSpotUrl2 in
                    guard let url2 = newSpotUrl2 else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let string2 = url2.absoluteString
                    urls.append(string2)
                    guard let newSpotId3 = createNewSpotId() else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    
                    StorageManager.shared.uploadSpot(data: imageDatas[2], id: newSpotId3, completion: { [weak self] newSpotUrl3 in
                        guard let url3 = newSpotUrl3 else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        let string3 = url3.absoluteString
                        urls.append(string3)
                        guard let newSpotId4 = createNewSpotId() else {
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                            return}
                        
                        StorageManager.shared.uploadSpot(data: imageDatas[3], id: newSpotId4, completion: { [weak self] newSpotUrl4 in
                            guard let url4 = newSpotUrl4 else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            let string4 = url4.absoluteString
                            urls.append(string4)
                            guard let newSpotId5 = createNewSpotId() else {
                                self?.spinner.dismiss()
                                self?.errorLoadingPost()
                                return}
                            
                            StorageManager.shared.uploadSpot(data: imageDatas[4], id: newSpotId5, completion: { [weak self] newSpotUrl5 in
                                guard let url5 = newSpotUrl5 else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                let string5 = url5.absoluteString
                                urls.append(string5)
                                guard let newSpotId6 = createNewSpotId() else {
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                    return}
                                
                                StorageManager.shared.uploadSpot(data: imageDatas[5], id: newSpotId6, completion: { [weak self] newSpotUrl6 in
                                    guard let url6 = newSpotUrl6 else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    let string6 = url6.absoluteString
                                    urls.append(string6)
                                    guard let newSpotId7 = createNewSpotId() else {
                                        self?.spinner.dismiss()
                                        self?.errorLoadingPost()
                                        return}
                                    
                                    StorageManager.shared.uploadSpot(data: imageDatas[6], id: newSpotId7, completion: { [weak self] newSpotUrl7 in
                                        guard let url7 = newSpotUrl7 else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        let string7 = url7.absoluteString
                                        urls.append(string7)
                                        guard let newSpotId8 = createNewSpotId() else {
                                            self?.spinner.dismiss()
                                            self?.errorLoadingPost()
                                            return}
                                        
                                        StorageManager.shared.uploadSpot(data: imageDatas[7], id: newSpotId8, completion: { [weak self] newSpotUrl8 in
                                            guard let url8 = newSpotUrl8 else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            let string8 = url8.absoluteString
                                            urls.append(string8)
                                            
                                            guard let addy = self?.address else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            guard let lat = self?.latitude else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            guard let long = self?.longitude else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            guard let type = self?.spotType else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            guard let spotDetails = self?.spotInfo else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            guard let dateString = String.date(from: Date()) else {
                                                self?.spinner.dismiss()
                                                self?.errorLoadingPost()
                                                return}
                                            
                                            let flatLong = Int(floor(long))
                                            let nickLower = nick.lowercased()
                                            
                                            let newPost = Post(posterEmail: userEmail, posterUsername: username, postType: "spot", region: region, postId: newSpotId, postedDateString: dateString, postedDateNum: unixDate, caption: spotDetails, photoUrls: urls, urlCount: 8, savers: [], spotType: type, itemType: nil, askingPrice: nil, latitude: lat, longitude: long, floorLong: flatLong, nickname: nick, nicknameLowercase: nickLower, address: addy, spotId: newSpotId, viewers: nil, videoThumbnail: nil)
                                            
                                            
                                            
                                            
                                            //upload to database
                                            
                                            DatabaseManager.shared.createPost(newPost: newPost) {
                                                [weak self] finish in
                                                guard finish else {
                                                    self?.spinner.dismiss()
                                                    self?.errorLoadingPost()
                                                    return
                                                }
                                                
                                                guard let com = self?.spotInfo else {
                                                    self?.spinner.dismiss()
                                                    self?.errorLoadingPost()
                                                    return}
                                                let comment = Comment(poster: username, posterEmail: userEmail, comment: com)
                                                
                                                let randomNum = Int.random(in: 0...9999)
                                                
                                                let newCommentId = "\(username)\(randomNum)"
                                                
                                                
                                                DatabaseManager.shared.createComment(for: newPost, comment: comment, id: newCommentId, completion: { success in
                                                    if success {
                                                        DispatchQueue.main.async {
                                                            self?.spinner.dismiss()
                                                            self?.tabBarController?.tabBar.isHidden = false
                                                            self?.tabBarController?.selectedIndex = 0
                                                            self?.navigationController?.popToRootViewController(animated: false)
                                                            NotificationCenter.default.post(name: NSNotification.Name("didPost"), object: nil)
                                                        }
                                                    } else {
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
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
            
        }
    
        
        func createNewSpotId() -> String? {
            let randomInt = Int.random(in: 0...999)
            let randomString = UUID().uuidString
            return "\(randomString)\(randomInt)"
        
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nickTextField {
            nickTextField.resignFirstResponder()
        }
        return true
    }
    
    func errorLoadingPost() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "something went wrong, or bad internet connection", message: "please try again", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(ac, animated: true)
        }
        
    }
    
}

