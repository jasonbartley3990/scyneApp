//
//  createCommentViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/6/21.
//

import UIKit
import JGProgressHUD

class createCommentViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    public var completion: (() -> Void)?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = .systemFont(ofSize: 18, weight: .light)
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.borderWidth = 0.5
        return textView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "type your comment"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let post: Post
    
    init(post: Post) {
        self.post = post
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "post", style: .done, target: self, action: #selector(didTapPost))

    }
    
    override func viewDidLayoutSubviews() {
        label.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 15, width: (view.width - 20), height: 30)
        textView.frame = CGRect(x: 10, y: label.bottom + 15, width: (view.width - 20), height: 100)
    }
    
    @objc func didTapPost() {
        spinner.show(in: view)
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {
            spinner.dismiss()
            return}
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            spinner.dismiss()
            return}
        
        if textView.text == "" {
            spinner.dismiss()
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "please enter something", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
                self.present(ac, animated: true)
            }
            return
        }
        
        guard let commentText = textView.text else {
            spinner.dismiss()
            return}
        
        guard !(commentText.count > 300) else {
            DispatchQueue.main.async {
                self.spinner.dismiss()
                let ac = UIAlertController(title: "max 300 characters", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self.present(ac, animated: true)
            }
            return
        }
        
        
        let comment = Comment(poster: currentUsername, posterEmail: currentEmail, comment: commentText)
        let randomNum = Int.random(in: 0...9000)
        
        let newCommentId = "\(currentUsername)\(randomNum)"
        
        DatabaseManager.shared.createComment(for: self.post, comment: comment, id: newCommentId, completion: {
            [weak self] success in
            self?.spinner.dismiss()
            if success {
                DispatchQueue.main.async {
                    self?.completion?()
                    self?.navigationController?.popViewController(animated: true)
                }
                
            } else {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "something went wrong", message: "try agian", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
                    self?.present(ac, animated: true)
                    return
                }
            }
            
        })
    }

}
