//
//  NotificationTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/25/21.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    static let identifier = "NotificationTableViewCell"
    
    private let profilePictureImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let startedFollowingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Started Following You"
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(startedFollowingLabel)
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        usernameLabel.sizeToFit()
        
        let size: CGFloat = contentView.height/1.3
        profilePictureImageView.frame = CGRect(x: 5, y: (contentView.height-size)/2, width: size, height: size)
        usernameLabel.frame = CGRect(x: profilePictureImageView.right + 10, y: 3, width: contentView.width - size - 20, height: contentView.height/2)
        startedFollowingLabel.frame = CGRect(x: profilePictureImageView.right + 10, y: usernameLabel.bottom, width: contentView.width - size - 20, height: contentView.height/4 )
        profilePictureImageView.layer.cornerRadius = size/2
    }
    
    func configure(with person: String) {
        usernameLabel.text = person
        StorageManager.shared.profilePictureUrlUsername(forUsername: person, completion: {
            [weak self] profilePhoto in
            guard let profilePic = profilePhoto else {return}
            self?.profilePictureImageView.sd_setImage(with: profilePic, completed: nil)
        })
        
    
}
    
}
