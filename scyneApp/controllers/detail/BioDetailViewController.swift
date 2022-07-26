//
//  BioDetailViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/22/21.
//

import Foundation
import UIKit

class BioDetailViewController: UIViewController {

    private let bio: String
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.sizeToFit()
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    init(bio: String) {
        self.bio = bio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BIO"
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        label.text = bio
        
    }
    
    

    override func viewDidLayoutSubviews() {
        label.sizeToFit()
        var labelHeight: CGFloat = 0
        if bio.count > 280 {
            labelHeight = 180
        } else if bio.count > 240 {
            labelHeight = 160
        } else if  bio.count > 200 {
            labelHeight = 140
        } else if bio.count > 160 {
            labelHeight = 120
        } else if bio.count > 120 {
            labelHeight = 80
        } else if bio.count > 80 {
            labelHeight = 60
        } else if bio.count > 40 {
            labelHeight = 60
        }
        
        label.frame = CGRect(x: 25, y: view.safeAreaInsets.top + 15, width: view.width - 50, height: labelHeight)
    }
}
