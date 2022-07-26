//
//  NormalPostCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/8/21.
//

import UIKit

protocol normalPostActionCollectionViewCellDelegate: AnyObject {
    func normalPostActionsCollectionViewCellDidTapLike(_ cell: NormalPostActionsCollectionViewCell, isLiked: Bool, post: Post, index: Int)
    func normalPostActionsCollectionViewCellDidTapComment(_ cell: NormalPostActionsCollectionViewCell, post: Post)
    func postActionsCollectionViewCellDidTapLikers(_ cell: NormalPostActionsCollectionViewCell, likers: [String], likeCount: Int)
    
}


class NormalPostActionsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "normalPostCollectionViewCell"
    
    public var isLiked = false
    
    public var likers = [String]()
    
    public var index = 0
    
    private var post: Post?
    
    public var likeCount = 0
    
    public weak var delegate: normalPostActionCollectionViewCellDelegate?
    
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
    
    public var likesLabel: UILabel = {
        let label = UILabel()
        label.text = "0 likes"
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.textColor = .label
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        return label
    }()
    
    public let pageTurner: UIPageControl = {
        let page = UIPageControl()
        page.hidesForSinglePage = true
        page.numberOfPages = 1
        page.currentPageIndicatorTintColor = .systemGray
        page.pageIndicatorTintColor = .systemGray2
        return page
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(commentButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(pageTurner)
        contentView.addSubview(likesLabel)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLikesLabel))
        likesLabel.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pageTurner.currentPage = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.height/1.15

        likeButton.frame = CGRect(x: 5, y: 2, width: size, height: size)
        commentButton.frame = CGRect(x: likeButton.right + 5, y: 2, width: size, height: size)
        likesLabel.frame = CGRect(x: (contentView.width - 150 - 5), y: 2, width: 150, height: size)
        pageTurner.frame = CGRect(x: (contentView.width - 160)/2, y: 5, width: 160, height: 20)
    }
    
    func configure(with viewModel: normalPostActionsCollectionViewCellViewModel) {
        self.isLiked = viewModel.isLiked
        self.likeCount = viewModel.likeCount
        self.post = viewModel.post
        self.likers = viewModel.likers
        pageTurner.numberOfPages = viewModel.numberOfPhotos
        if viewModel.isLiked {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
        
        let numString = String(viewModel.likeCount)
        
        likesLabel.text = "\(numString) likes"
        
        if numString == "1" {
            likesLabel.text = "\(numString) like"
        }
    }
    
    @objc func didTapComment() {
        guard let post = self.post else {return}
        delegate?.normalPostActionsCollectionViewCellDidTapComment(self, post: post)
    }
    
    @objc func didTapLike() {
        guard let post = self.post else {return}
        delegate?.normalPostActionsCollectionViewCellDidTapLike(self, isLiked: self.isLiked, post: post, index: self.index)
       
    }
    
    @objc func didTapLikesLabel() {
        delegate?.postActionsCollectionViewCellDidTapLikers(self, likers: self.likers, likeCount: self.likeCount)
    }
    
    public func updateNormalLikeLabel(with email: String) {
        if self.isLiked {
            self.likeCount += 1
            self.likesLabel.text = "\(self.likeCount) likes"
            self.likers.append(email)
        } else {
            self.likeCount -= 1
            self.likesLabel.text = "\(self.likeCount) likes"
            self.likers.removeAll { $0 == email }
        }

        
    }
    
}
