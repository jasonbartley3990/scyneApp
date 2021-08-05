//
//  captionDetailViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/13/21.
//

import UIKit

class captionDetailViewController: UIViewController {
    
    private let caption: String
    
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
    
    init(caption: String) {
        self.caption = caption
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "caption"
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        label.text = caption
        
    }
    
    override func viewDidLayoutSubviews() {
        label.sizeToFit()
        var labelHeight: CGFloat = 0
        if caption.count > 280 {
            labelHeight = 180
        } else if caption.count > 240 {
            labelHeight = 160
        } else if  caption.count > 200 {
            labelHeight = 140
        } else if caption.count > 160 {
            labelHeight = 120
        } else if caption.count > 120 {
            labelHeight = 80
        } else if caption.count > 80 {
            labelHeight = 60
        } else if caption.count > 40 {
            labelHeight = 60
        }
        
        label.frame = CGRect(x: 25, y: view.safeAreaInsets.top + 15, width: view.width - 50, height: labelHeight)
    }
    

    
    

}
