//
//  CommentTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/6/21.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    static let identifier = "CommentTableViewCell"

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        usernameLabel.frame = CGRect(x: 5 , y: 5, width: (contentView.width - 15), height: (contentView.height/4))
        commentLabel.frame = CGRect(x: 8, y: usernameLabel.bottom, width: (contentView.width - 20), height: (contentView.height/3.2))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = nil
        usernameLabel.text = nil
    }
    
    func configure(with viewModel: CommentViewModel) {
        usernameLabel.text = viewModel.poster
        commentLabel.text = viewModel.comment
    
}

}
