//
//  SpotActionsCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol SpotActionsCollectionViewCellDelegate: AnyObject {
    func spotActionsCollectionViewCellDidTapSaveSpot(_ cell: SpotActionsCollectionViewCell, isSaved: Bool, post: Post)
    func spotActionsCollectionViewCellDidTapComment(_ cell: SpotActionsCollectionViewCell, post: Post)
    func spotActionCollectionViewCellDidTapVideo(_ cell: SpotActionsCollectionViewCell, post: Post)
    func spotActionsCollectionViewCellDDidTapPin(_ cell: SpotActionsCollectionViewCell, post: Post)
}

class SpotActionsCollectionViewCell: UICollectionViewCell {
    static let identifier = "SpotActionsCollectionViewCell"
    
    private var post: Post?
    
    weak var delegate: SpotActionsCollectionViewCellDelegate?
    
    public var isSaved: Bool? = false
    
    public var index: Int?
    
    public let pageTurner: UIPageControl = {
        let page = UIPageControl()
        page.hidesForSinglePage = true
        page.numberOfPages = 1
        page.currentPageIndicatorTintColor = .systemGray
        page.pageIndicatorTintColor = .systemGray2
        return page
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let videoButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "video", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    public let saveLabel: UILabel = {
        let label = UILabel()
        label.text = "save"
        label.textColor = .label
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private var pinButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "mappin.and.ellipse", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(commentButton)
        contentView.addSubview(videoButton)
        contentView.addSubview(pageTurner)
        contentView.addSubview(saveLabel)
        contentView.addSubview(pinButton)
        videoButton.addTarget(self, action: #selector(didTapVideo), for: .touchUpInside)
        pinButton.addTarget(self, action: #selector(didTapPin), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(didTapSaveSpot))
        saveLabel.addGestureRecognizer(saveTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let saveLabelWidth: CGFloat = 70
        let size: CGFloat = contentView.height/1.15
        commentButton.frame = CGRect(x: 10, y: ((contentView.height - size)/2) + 2 , width: size, height: size)
        videoButton.frame = CGRect(x: commentButton.right + 7, y: ((contentView.height - size)/2) + 2, width: size + 7, height: size)
        pageTurner.frame = CGRect(x: (contentView.width - 160)/2, y: 5, width: 160, height: 20)
        saveLabel.frame = CGRect(x: contentView.width - saveLabelWidth - 10, y: 2, width: saveLabelWidth, height: size)
        pinButton.frame = CGRect(x: videoButton.right + 8, y: 5, width: size, height: size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        post = nil
        isSaved = false
        pageTurner.currentPage = 0
    }
    
    func configure(with viewModel: SpotActionsCollectionViewCellViewModel) {
        pageTurner.numberOfPages = viewModel.photoCount
        if viewModel.isSaved {
            saveLabel.text = "saved"
            saveLabel.textColor = .systemGreen
            self.isSaved = true
        }
        
        self.post = viewModel.post
        
    }
    
    @objc func didTapSaveSpot() {
        guard let saved = self.isSaved else {return}
        if saved {
            saveLabel.text = "save"
            saveLabel.textColor = .label
        } else {
            saveLabel.text = "saved"
            saveLabel.textColor = .green
        }
        
        guard let spotPost = self.post else {return}

        delegate?.spotActionsCollectionViewCellDidTapSaveSpot(self, isSaved: !saved, post: spotPost)
        self.isSaved = !saved

    }
    
    @objc func didTapComment() {
        guard let post = self.post else {return}
        delegate?.spotActionsCollectionViewCellDidTapComment(self, post: post)
    }
    
    @objc func didTapVideo() {
        guard var spotPost = self.post else {return}
        delegate?.spotActionCollectionViewCellDidTapVideo(self, post: spotPost)
    }
    
    @objc func didTapPin() {
        guard let spot = self.post else {return}
        delegate?.spotActionsCollectionViewCellDDidTapPin(self, post: spot)
    }
    
}
