//
//  fullLengthEditPostViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import UIKit
import JGProgressHUD

class fullLengthEditPostViewController: UIViewController, UITextViewDelegate {

    private let image: UIImage
    
    private let videoUrl: URL
    
    private let videoTitle: String
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.text = "write a description about your video"
        return label
    }()
    
    private let waitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.text = "larger videos take a while to post"
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
    
    init(image: UIImage, url: URL, title: String) {
        self.image = image
        self.videoUrl = url
        self.videoTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(label)
        view.addSubview(textView)
        view.addSubview(waitLabel)
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "post", style: .done, target: self, action: #selector(didTapPost))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = view.width/2.8
        label.sizeToFit()
        imageView.frame = CGRect(x: (view.width - imageSize)/2, y: view.safeAreaInsets.top + 10, width: imageSize, height: imageSize)
        label.frame = CGRect(x: (view.width - label.width)/2, y: imageView.bottom + 10, width: label.width, height: label.height)
        textView.frame = CGRect(x: 20, y: label.bottom + 15, width: view.width - 40, height: 100)
        waitLabel.frame = CGRect(x: 20, y: textView.bottom + 35, width: view.width - 40, height: 20)
        
    }
    
    @objc func didTapPost() {
        textView.resignFirstResponder()
        
        spinner.show(in: view)
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "no description for video", message: "please add a description", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self.present(ac, animated: true)
            }
            spinner.dismiss()
            return
                
        }
        
        var caption = textView.text ?? ""
        if caption == "add description..." {
            caption = ""
        }
        
        guard !(caption.count > 300) else {
            DispatchQueue.main.async {
                self.spinner.dismiss()
                let ac = UIAlertController(title: "max 300 characters", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self.present(ac, animated: true)
            }
            return
        }
        
        guard let dateString = String.date(from: Date()) else {
            self.spinner.dismiss()
            return}
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            self.spinner.dismiss()
            return}
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {
            self.spinner.dismiss()
            return}
        guard let region = UserDefaults.standard.string(forKey: "region") else {
            self.spinner.dismiss()
            return}
        guard let videoIdent = createVideoId() else {
            self.spinner.dismiss()
            return}
    
        guard let imageData = image.pngData() else {
            self.spinner.dismiss()
            return}
        
        let vidTitle = videoTitle
        
        let vidTitleLower = videoTitle.lowercased()
        
        let unixDate = NSDate().timeIntervalSince1970
        
        
        StorageManager.shared.uploadFullLength(with: videoUrl, videoId: videoIdent, completion: { [weak self] url in
            guard let vidUrl = url else {
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    let ac = UIAlertController(title: "unable to upload video at the moment", message: "please try again later", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                    self?.present(ac, animated: true)
                }
                return
               
            }
            StorageManager.shared.uploadFullLengthThumbnail(with: imageData, filename: videoIdent, completion: { [weak self] url in
                guard let thumbUrl = url else {
                    DispatchQueue.main.async {
                        self?.spinner.dismiss()
                        let ac = UIAlertController(title: "unable to upload video at the moment", message: "please try again later", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                        self?.present(ac, animated: true)
                    }
                    return
                }
                
                let videoDatabase = FullLength(poster: currentUsername, posterEmail: currentEmail, videoId: videoIdent, videoName: vidTitle, videoNameLowercased: vidTitleLower, thumbnailString: thumbUrl.absoluteString, videoUrlString: vidUrl.absoluteString, likers: [], region: region , viewers: 0, postedDate: dateString, postedDateNum: unixDate, caption: caption, isAccepted: false)
                
                DatabaseManager.shared.uploadFullLengthData(video: videoDatabase, completion: { [weak self] success in
                    if success {
                        DatabaseManager.shared.creatDistributedCounterForFullLength(for: videoIdent, completion: {
                            success in
                            
                            if success {
                                DatabaseManager.shared.createDistributedLikeCounterForFullLength(for: videoIdent, completion: {
                                    success in
                                
                                    if success {
                                        DispatchQueue.main.async {
                                            self?.spinner.dismiss()
                                            self?.tabBarController?.tabBar.isHidden = false
                                            self?.tabBarController?.selectedIndex = 0
                                            self?.navigationController?.popToRootViewController(animated: false)
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self?.spinner.dismiss()
                                            let ac = UIAlertController(title: "unable to upload video at the moment", message: "please try again later", preferredStyle: .alert)
                                            ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                                            self?.present(ac, animated: true)
                                        }
                                        return
                                        
                                    }
                                })
                            } else {
                                DispatchQueue.main.async {
                                    self?.spinner.dismiss()
                                    let ac = UIAlertController(title: "unable to upload video at the moment", message: "please try again later", preferredStyle: .alert)
                                    ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                                    self?.present(ac, animated: true)
                                }
                                return
                               
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self?.spinner.dismiss()
                            let ac = UIAlertController(title: "unable to upload video at the moment", message: "please try again later", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                            self?.present(ac, animated: true)
                        }
                        return
                        
                    }
            
                })
            })
        })
    }
    
    func createVideoId() -> String? {
        guard let dateString = String.date(from: Date()) else {return nil}
        let randomNum = Int.random(in: 0...1000)
        return "\(videoTitle)_\(dateString)_\(randomNum)"
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "add description..." {
            textView.text = nil
        }
    }
    
}

