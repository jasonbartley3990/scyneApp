//
//  SelectCompanyLinkViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class SelectCompanyLinkViewController: UIViewController {
    
    private let companyName: String
    
    private let companyLogo: UIImage
    
    let linkTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.secondaryLabel.cgColor
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 17, weight: .light)
        return textView
    }()

    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.text = "enter the url address to your company website, make sure to type it in correctly\nEX: https://www.your-website.com\nviewers will be brought to this website when they tap on your companyName"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    
    init(company: String, logo: UIImage) {
        self.companyName = company
        self.companyLogo = logo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(linkTextView)
        view.addSubview(label)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: view.width - 40, height: 100)
        linkTextView.frame = CGRect(x: 25, y: label.bottom + 15, width: view.width - 50, height: 80)
    }
    
    @objc func didTapNext() {
        guard let link = linkTextView.text else {return}
        let vc = AdTypeViewController(company: self.companyName, logo: self.companyLogo, link: link)
        navigationController?.pushViewController(vc, animated: true)
    }
    

   

}
