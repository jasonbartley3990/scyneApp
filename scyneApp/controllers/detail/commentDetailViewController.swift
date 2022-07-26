//
//  commentDetailViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/6/21.
//

import UIKit

class commentDetailViewController: UIViewController {
    
    private let comment: Comment
    
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
    
    init(comment: Comment) {
        self.comment = comment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        label.text = comment.comment
    }
    
    override func viewDidLayoutSubviews() {
        label.sizeToFit()
        var labelHeight: CGFloat = 0
        if comment.comment.count > 280 {
            labelHeight = 180
        } else if comment.comment.count > 240 {
            labelHeight = 160
        } else if  comment.comment.count > 200 {
            labelHeight = 140
        } else if comment.comment.count > 160 {
            labelHeight = 120
        } else if comment.comment.count > 120 {
            labelHeight = 80
        } else if comment.comment.count > 80 {
            labelHeight = 60
        } else if comment.comment.count > 40 {
            labelHeight = 60
        } else {
            labelHeight = 40
        }
        
        label.frame = CGRect(x: 25, y: view.safeAreaInsets.top + 15, width: view.width - 50, height: labelHeight)
    }

    

}
