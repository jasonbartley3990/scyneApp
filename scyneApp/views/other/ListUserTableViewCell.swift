//
//  ListUserTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/11/21.
//

import UIKit

class ListUserTableViewCell: UITableViewCell {

    static let identifier = "listUserTableViewCell"
    
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
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(usernameLabel)
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
        usernameLabel.frame = CGRect(x: profilePictureImageView.right + 10, y: 0, width: usernameLabel.width, height: contentView.height)
        profilePictureImageView.layer.cornerRadius = size/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePictureImageView.image = nil
        usernameLabel.text = nil
    }
    
    func configure(with viewModel: ListUserTableViewCellViewModel) {
        usernameLabel.text = viewModel.username
        StorageManager.shared.profilePictureUrlUsername(forUsername: viewModel.username, completion: {
            [weak self] url in
            DispatchQueue.main.async { [weak self] in
                self?.profilePictureImageView.sd_setImage(with: url, completed: nil)
            }
        })
    }
    
}

   
