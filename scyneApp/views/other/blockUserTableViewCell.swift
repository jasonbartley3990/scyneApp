//
//  blockUserTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 7/16/21.
//

import UIKit

class blockUserTableViewCell: UITableViewCell {
    
    static let identifier = "blockUserTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 70, height: 70)
        usernameLabel.frame = CGRect(x: userImageView.right + 10, y: 10, width: (contentView.width - 20 - userImageView.width), height: (contentView.height - 20))
        
    }
    
    public func configure(with email: String) {
        
        
        DatabaseManager.shared.findUser(with: email, completion: {
            [weak self] user in
            self?.usernameLabel.text = user?.username
        })
        
        let image = StorageManager.shared.profilePictureUrl(for: email, completion: {
            [weak self] url in
            DispatchQueue.main.async { [weak self] in
                self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            }
        )
    }
}
