//
//  ReportAnIssueViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/27/21.
//

import UIKit
import JGProgressHUD

class ReportAnIssueViewController: UIViewController, UITextViewDelegate {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.text = "report an issue, type what you experienced"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .light)
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
    
    private let spinner = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        view.addSubview(textView)
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "report", style: .done, target: self, action: #selector(didTapReport))

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let labelSize: CGFloat = (view.width - 50)
        label.frame = CGRect(x: (view.width - labelSize)/2 , y: view.safeAreaInsets.top + 25, width: labelSize, height: 50)
        textView.frame = CGRect(x: 20, y: label.bottom + 15, width: view.width - 40, height: 100)
        
    }
    
    
    
    @objc func didTapReport() {
        textView.resignFirstResponder()
        
        spinner.show(in: view)
        
        let caption = textView.text ?? ""
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            spinner.dismiss()
            return}
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            spinner.dismiss()
            return}
        
        let issue = Issue(username: username, email: email, issue: caption)
        
        let random = String(Int.random(in: 0...9000))
        
        let newId = "\(email)\(random)"
        
        DatabaseManager.shared.reportIssue(issue: issue, id: newId , completion: {
            [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    let ac = UIAlertController(title: "issue reported thank you", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: {
                        [weak self] _ in
                        self?.doneReporting()
                    }))
                    self?.present(ac, animated: true, completion: nil)
                }
                
            } else {
                self?.spinner.dismiss()
            }
        })
        
        
        
    }
    
    private func doneReporting() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    

    

}
