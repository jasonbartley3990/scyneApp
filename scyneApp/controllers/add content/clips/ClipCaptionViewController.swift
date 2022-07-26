//
//  ClipCaptionViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/26/21.
//

import UIKit
import JGProgressHUD

class ClipCaptionViewController: UIViewController, UITextViewDelegate{
    
    private let spotId: String?
    
    private let image: UIImage
    
    private var urls = [URL]()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.text = "caption"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = .systemFont(ofSize: 18, weight: .light)
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.borderWidth = 0.5
        return textView
    }()
    
    init(urls: [URL], spotId: String?, thumbnail: UIImage) {
        self.spotId = spotId
        self.urls = urls
        self.image = thumbnail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        view.addSubview(label)
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "post", style: .done, target: self, action: #selector(didTapPost))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let labelSize: CGFloat = (view.width - 50)
        label.frame = CGRect(x: (view.width - labelSize)/2 , y: view.safeAreaInsets.top + 25, width: labelSize, height: 50)
        textView.frame = CGRect(x: 20, y: label.bottom + 15, width: view.width - 40, height: 100)
        
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
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            errorLoadingPost()
            spinner.dismiss()
            return}
        guard let region = UserDefaults.standard.string(forKey: "region") else {
            errorLoadingPost()
            spinner.dismiss()
            return}
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            errorLoadingPost()
            spinner.dismiss()
            return}
        
        
        guard let dateString = String.date(from: Date()) else {
            errorLoadingPost()
            spinner.dismiss()
            return}
        let unixDate = NSDate().timeIntervalSince1970
      
        var spotIdString = ""
        
        
        if spotId != nil {
            spotIdString = spotId!
        }
        
        let num = urls.count
        print(urls)
        print(num)
        
        var uploadedVideoUrls: [String] = []
        
        if num == 1 {
            let url1 = urls[0]
            guard let newClipId1 = newClipId() else {
                spinner.dismiss()
                errorLoadingPost()
                return
                
            }
            
            guard let thumbnailData = image.pngData() else {
                spinner.dismiss()
                errorLoadingPost()
                return}
            
            
            StorageManager.shared.uploadClipUrl(with: url1, postId: newClipId1, email: email, completion: { [weak self] newClipUrl in
                guard let urlOne = newClipUrl else {
                    self?.spinner.dismiss()
                    self?.errorLoadingPost()
                    return}
                let string = urlOne.absoluteString
                uploadedVideoUrls.append(string)
                
                StorageManager.shared.uploadClipThumbnail(with: thumbnailData, postId: newClipId1, email: email, completion: {
                    [weak self] url in
                    guard let thumbnail = url else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return}
                    let thumbnailString = thumbnail.absoluteString
               
                
                let newPost = Post(posterEmail: email, posterUsername: username, postType: "clip", region: region, postId: newClipId1, postedDateString: dateString, postedDateNum: unixDate, caption: caption, photoUrls: uploadedVideoUrls, urlCount: 1, savers: [], spotType: nil, itemType: nil, askingPrice: nil, latitude: nil, longitude: nil, floorLong: nil , nickname: nil, nicknameLowercase: nil, address: nil, spotId: spotIdString, viewers: 0, videoThumbnail: thumbnailString)
                    
                    
                DatabaseManager.shared.createPost(newPost: newPost, completion: { [weak self] success in
                    guard success else {
                        self?.spinner.dismiss()
                        self?.errorLoadingPost()
                        return
                    }
                    
                    DatabaseManager.shared.createDistributedCounterForVideoCount(post: newPost) {
                        [weak self] success in
                        if success {
                            DatabaseManager.shared.createDistributedLikeCounterForPost(for: newPost, completion: {
                                [weak self] success in
                                if success {
                                    print("database manager complete")
                                    DispatchQueue.main.async {
                                        self?.spinner.dismiss()
                                        self?.tabBarController?.tabBar.isHidden = false
                                        self?.tabBarController?.selectedIndex = 0
                                        self?.navigationController?.popToRootViewController(animated: false)
                                        NotificationCenter.default.post(name: Notification.Name("didPost"), object: nil)
                                    }
                                    
                                } else {
                                    DatabaseManager.shared.deleteClipOrNormalPost(postId: newPost.postId, completion: {
                                        success in
                                        print("deleted")
                                    })
                                    self?.spinner.dismiss()
                                    self?.errorLoadingPost()
                                }
                            })
                           
                        } else {
                            DatabaseManager.shared.deleteClipOrNormalPost(postId: newPost.postId, completion: {
                                success in
                                print("deleted")
                            })
                            self?.spinner.dismiss()
                            self?.errorLoadingPost()
                        }
                    }
                })
                })
            })
        }
        
        
        
        func newClipId() -> String? {
            let randomNum = Int.random(in: 0...20)
            let randomString = UUID().uuidString
            return "\(randomString)\(randomNum)"
            
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

