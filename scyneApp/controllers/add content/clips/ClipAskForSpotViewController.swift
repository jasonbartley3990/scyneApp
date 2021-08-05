//
//  ClipAskForSpotViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/26/21.
//

import UIKit
class ClipAskForSpotViewController: UIViewController {
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "do you want to tag a spot or park to post?\notherwise press next"
        return label
    }()
    
    let searchForSpotButton: UIButton = {
        let button = UIButton()
        button.setTitle("add a location tag", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(searchForSpotButton)
        view.addSubview(label)

        searchForSpotButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let buttonWidth: CGFloat = 160
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: (view.width - 40), height: 80)
        searchForSpotButton.frame = CGRect(x: (view.width - buttonWidth)/2, y: label.bottom + 20, width: buttonWidth, height: 40)
    }
    
    
    @objc func didTapButton() {
        let vc = SpotIdSearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapNext() {
        let vc = ClipUploaderViewController(urls: [], spot: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    

   

}
