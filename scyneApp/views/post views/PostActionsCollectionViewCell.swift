//
//  PostActionsCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol PostActionCollectionViewCellDelegate: AnyObject {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionCollectionViewCell, isLiked: Bool, post: Post, index: Int)
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionCollectionViewCell, post: Post)
    func postActionsCollectionViewCellDidTapPin(_ cell: PostActionCollectionViewCell, post: Post)
    func postActionsCollectionViewCellDidTapViewers(_ cell: PostActionCollectionViewCell, likers: [String], likeCount: Int)
    
}

final class PostActionCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostActionCollectionViewCell"
    
    weak var delegate: PostActionCollectionViewCellDelegate?
    
    private var post: Post?
    
    public var isLiked = false
    
    public var likeCount = 0
    
    public var viewers = 0
    
    public var index = 0
    
    public var likers = [String]()
    
    public let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private var viewsLabel: UILabel = {
        let label = UILabel()
        label.text = "0 views"
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.textColor = .label
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private var pinButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "mappin.and.ellipse", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36))
        button.setImage(image, for: .normal)
        return button
    }()
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(viewsLabel)
        contentView.addSubview(pinButton)
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        pinButton.addTarget(self, action: #selector(didTapPin), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapViews))
        viewsLabel.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.height/1.15
        likeButton.frame = CGRect(x: 5, y: 2, width: size, height: size)
        commentButton.frame = CGRect(x: likeButton.right + 5, y: 2, width: size, height: size)
        viewsLabel.frame = CGRect(x: commentButton.right + 5, y: 2, width: 200, height: size)
        pinButton.frame = CGRect(x: (contentView.width - 5 - size), y: 2, width: size, height: size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostActionsCollectionViewCellViewModel) {
        self.isLiked = viewModel.isLiked
        self.likeCount = viewModel.likeCount
        self.viewers = viewModel.viewCount
        self.post = viewModel.post
        self.likers = viewModel.likers
        if viewModel.isLiked {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
        
        let numString = String(viewModel.viewCount)
        
        viewsLabel.text = "\(numString) views"
        
    }
    
    
    @objc func didTapLike() {
        guard let post = self.post else {return}
        
        delegate?.postActionsCollectionViewCellDidTapLike(self, isLiked: self.isLiked, post: post, index: self.index)
    }
    
    @objc func didTapComment() {
        guard let post = self.post else {return}
        delegate?.postActionsCollectionViewCellDidTapComment(self, post: post)
    }
    
    @objc func didTapPin() {
        guard let post = self.post else {return}
        delegate?.postActionsCollectionViewCellDidTapPin(self, post: post)
    }
    
    @objc func didTapViews() {
        delegate?.postActionsCollectionViewCellDidTapViewers(self, likers: self.likers, likeCount: self.likeCount)
    }
    
    public func updateLikeLabel(with email: String) {
        if self.isLiked {
            self.likeCount += 1
            self.likers.append(email)
        } else {
            self.likeCount -= 1
            self.likers.removeAll { $0 == email }
        }

    }
    
}
