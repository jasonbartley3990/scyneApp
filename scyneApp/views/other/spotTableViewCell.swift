//
//  spotTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/7/21.
//

import UIKit
import SDWebImage

class spotTableViewCell: UITableViewCell {

    static let identifier = "spotTableViewCell"

    private let spotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var spotName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(spotImageView)
        contentView.addSubview(spotName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spotImageView.frame = CGRect(x: 10, y: 10, width: 70, height: 70)
        spotName.frame = CGRect(x: spotImageView.right + 10, y: 10, width: (contentView.width - 20 - spotImageView.width), height: (contentView.height - 20))
        
    }
    
    public func configure(with model: Post) {
        guard let nick = model.nickname else {return}
        self.spotName.text = nick
        guard let firstUrl = model.photoUrls.first else {return}
        let url = URL(string: firstUrl)
        
        spotImageView.sd_setImage(with: url, completed: nil)
        
    }
    
}

