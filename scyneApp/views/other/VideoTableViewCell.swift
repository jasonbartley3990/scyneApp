//
//  VideoTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/20/21.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    static let identifier = "VideoTableViewCell"

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
    
    public func configure(with model: FullLength) {
        self.usernameLabel.text = model.videoName
        
        let _ = StorageManager.shared.fetchFullLengthThumbNail(for: model.videoId, completion: {
            [weak self] url in
            DispatchQueue.main.async { [weak self] in
                self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            }
        )
            
        
    }
    
}
