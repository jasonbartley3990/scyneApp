//
//  fullLengthActionCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/20/21.
//

import UIKit

protocol fullLengthActionCollectionViewCellDelegate: AnyObject {
    func fullLengthActionCollectionViewCellDidTapLike(_ cell: fullLengthActionCollectionViewCell, isLiked: Bool, video: String, index: Int)
    
    func fullLengthActionCollectionViewDidTapComment(_ cell: fullLengthActionCollectionViewCell, video: FullLength)
    
    func fullLengthActionDidTapPlay(_ cell: fullLengthActionCollectionViewCell, url: URL, video: String)
    
    func fullLengthActionDidTapViews(_ cell: fullLengthActionCollectionViewCell, views: Int, likers: [String])
        
        }

class fullLengthActionCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "fullLengthActionCollectionViewCell"
    
    weak var delegate : fullLengthActionCollectionViewCellDelegate?
    
    public var index = 0
    
    public var url: URL?
    
    public var isLiked = false
    
    public var video: String?
    
    public var likers = [String]()
    
    public var fullVideo: FullLength?
    
    public var views = 0
    
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
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "play", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34))
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(playButton)
        contentView.addSubview(viewsLabel)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapViews))
        viewsLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.height/1.15
        likeButton.frame = CGRect(x: 7, y: ((contentView.height - size)/2) + 2 , width: size, height: size)
        commentButton.frame = CGRect(x: likeButton.right + 7, y: ((contentView.height - size)/2) + 2, width: size, height: size)
        playButton.frame = CGRect(x: (contentView.width - size - 7), y: ((contentView.height - size)/2) + 2, width: size, height: size)
        viewsLabel.frame = CGRect(x: commentButton.right + 10, y: ((contentView.height - size)/2 + 2), width: 200, height: size)
        
      
    }
    
    func configure(with viewModel: fullLengthActionCellViewModel, index: Int) {
        self.index = index
        isLiked = viewModel.isLiked
        self.url = viewModel.videoUrl
        self.likers = viewModel.likers
        if viewModel.isLiked {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
        let viewNum = viewModel.viewsCount
        viewsLabel.text = "\(viewNum) views"
        self.views = viewModel.viewsCount
        self.video = viewModel.video
        self.fullVideo = viewModel.fullVideo
    }
    
    
    @objc func didTapLike() {
        
        guard let vid = self.video else {return}
        delegate?.fullLengthActionCollectionViewCellDidTapLike(self, isLiked: self.isLiked, video: vid, index: self.index)
    }
    
    @objc func didTapComment() {
        guard let video = self.fullVideo else {return}
        delegate?.fullLengthActionCollectionViewDidTapComment(self, video: video)
    }
    
    @objc func didTapPlay() {
        guard let videoUrl = self.url else {return}
        guard let vid = self.video else {return}
        
        delegate?.fullLengthActionDidTapPlay(self, url: videoUrl, video: vid)
    }
    
    @objc func didTapViews() {
        delegate?.fullLengthActionDidTapViews(self, views: self.views, likers: self.likers)
    }
    
    public func updateLikeLabel(with email: String) {
        if self.isLiked {
            self.likers.append(email)
        } else {
            self.likers.removeAll { $0 == email }
        }

    }
}
