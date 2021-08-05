//
//  companyNameViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class companyNameViewController: UIViewController {
    
    private let companyTextField: ScyneTextField = {
        let textfield = ScyneTextField()
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.returnKeyType = .continue
        textfield.placeholder = "company name"
        return textfield
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.text = "enter the company name that you wish to be displayed, this will appear at the top of  your post next to your company logo"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(companyTextField)

        view.backgroundColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: view.width - 40, height: 60)
        companyTextField.frame = CGRect(x: 25, y: label.bottom + 20, width: view.width - 50, height: 40)
    }
    
    @objc func didTapNext() {
        guard let companyName = companyTextField.text else {return}
        
        let vc = SelectLogoViewController(company: companyName)
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
    

}
