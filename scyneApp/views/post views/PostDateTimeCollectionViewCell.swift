//
//  PostDateTimeCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

class PostDatetimeCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostDatetimeCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 6, y: 0, width: contentView.width-12, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: PostDateTimeCollectionViewCellViewModel) {
        let date = viewModel.date
        let dateObject = Date(timeIntervalSince1970: date)
        let string = dateObject.timeAgoDisplay()
        
        if string == "usePostedDate" {
            label.text = viewModel.dateString
        } else if string == "1 days ago" {
            label.text = "1 day ago"
        } else if string == "1 hours ago" {
            label.text = "1 hour ago"
        } else if string == "1 weeks ago" {
            label.text = "1 week ago"
        } else if string == "1 minutes ago" {
            label.text = "1 minute ago"
        } else {
            label.text = string
        }
        
    }}
