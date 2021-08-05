//
//  PosterCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import SDWebImage

protocol PosterCollectionViewCellDelegate: AnyObject {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, post: Post, type: String, index: Int)
    func posterCollectionViewCellDidUsername(_ cell: PosterCollectionViewCell, email: String, username: String, region: String)
}

final class PosterCollectionViewCell: UICollectionViewCell {
    static let identifier = "PosterCollectionViewCell"
    
    weak var delegate: PosterCollectionViewCellDelegate?
    
    private var type: String?
    
    public var index = 0
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private var email: String?
    
    private var region: String?
    
    private var post: Post?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.addGestureRecognizer(tap)
        usernameLabel.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height-(imagePadding * 2)
        imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(x: imageView.right+10, y: 0, width: usernameLabel.width, height: contentView.height)
        
        moreButton.frame = CGRect(x: contentView.width-60, y: (contentView.height-50)/2, width: 50, height: 50)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        imageView.image = nil
    }
    
    func configure(with viewModel: PosterCollectionViewCellviewModel) {
        usernameLabel.text = viewModel.username
        imageView.sd_setImage(with: viewModel.profilePicture, completed: nil)
        self.email = viewModel.email
        self.region = viewModel.region
        self.post = viewModel.post
        self.type = viewModel.postType
    }
    
    @objc func didTapMore() {
        guard let post = self.post else {return}
        guard let type = self.type else {return}
        delegate?.posterCollectionViewCellDidTapMore(self, post: post, type: type, index: self.index)
    }
    
    @objc func didTapUsername() {
        guard let email = self.email else {
            return}
        print(email)
        guard let username = usernameLabel.text else {
            return}
        guard let region = self.region else {return}
        delegate?.posterCollectionViewCellDidUsername(self,email: email, username: username, region: region)
    }
    
}

