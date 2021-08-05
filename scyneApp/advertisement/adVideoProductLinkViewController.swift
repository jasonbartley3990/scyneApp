//
//  adVideoProductLinkViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class adVideoProductLinkViewController: UIViewController {
    
    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private let url: URL
    
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
        label.numberOfLines = 8
        label.text = "enter the url address to send a customer directly to the product being shown. Make sure to type it in correctly\nEX: https://www.your-website.com/t-shirts\nviewers will be brought to this page when they tap on the bottom product link. if you wish to use the same link as previously select same link"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let sameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "same link"
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    init(company: String, logo: UIImage, link: String, url: URL) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(linkTextView)
        view.addSubview(sameLabel)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapSame))
        sameLabel.addGestureRecognizer(tap1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 10, width: view.width - 40, height: 160)
        linkTextView.frame = CGRect(x: 25, y: label.bottom + 10, width: view.width - 50, height: 80)
        sameLabel.frame = CGRect(x: 20, y: linkTextView.bottom + 13, width: view.width - 40, height: 40)
        
    }
    
    @objc func didTapSame() {
        let vc = adBottomLinkLabelViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, url: self.url, product: self.companyLink)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapNext() {
        guard let productLink = linkTextView.text else {return}
        let vc = adBottomLinkLabelViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, url: self.url, product: productLink)
        navigationController?.pushViewController(vc, animated: true)
    }
    

    

}
