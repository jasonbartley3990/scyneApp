//
//  ConversationTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/14/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "conversationTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private var userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    public var isRead = true
    
    private var date: Double?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(dateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        usernameLabel.frame = CGRect(x: userImageView.right + 10, y: 7, width: (contentView.width - 25 - userImageView.width), height: (contentView.height - 20)/3)
        userMessageLabel.frame = CGRect(x: userImageView.right + 12, y: usernameLabel.bottom, width: (contentView.width-22-userImageView.width), height: (contentView.height-20)/2.1)
        dateLabel.frame = CGRect(x: userImageView.right + 10, y: userMessageLabel.bottom, width: contentView.width-22-userImageView.width, height:  (contentView.height-20)/4)
        
    }
    
    public func configure(with model: Conversation) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
    
        
        if model.name == currentUsername {
            self.usernameLabel.text = model.otherUsername
        } else {
            self.usernameLabel.text = model.name
        }
        self.userMessageLabel.text = model.latestmessage.text
    
        var otherName = ""
        
        isRead = model.isRead
        
        guard let doubleDate = Double(model.dateNum) else {return}
        
        let dateObject = Date(timeIntervalSince1970: doubleDate)
        let string = dateObject.timeAgoDisplay()
        
        if string == "usePostedDate" {
            dateLabel.text = string
        } else if string == "1 days ago" {
            dateLabel.text = "1 day ago"
        } else if string == "1 hours ago" {
            dateLabel.text = "1 hour ago"
        } else if string == "1 weeks ago" {
            dateLabel.text = "1 week ago"
        } else {
            dateLabel.text = string
        }
        
        
        
        if isRead {
            contentView.backgroundColor = .systemBackground
        } else {
            if model.sender == currentEmail {
                contentView.backgroundColor = .systemBackground
            } else {
                contentView.backgroundColor = .systemTeal
            }
        }
        
        if model.name == currentUsername {
            otherName = model.otherUsername
        } else {
            otherName = model.name
        }
        
        let image = StorageManager.shared.profilePictureUrl(for: model.otherUserEmail, completion: {
            [weak self] url in
            DispatchQueue.main.async { [weak self] in
                self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            }
        )
            
        
    }
    
}

