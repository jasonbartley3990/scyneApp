//
//  ProfileHeaderCollectionReusableView.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func ProfileHeaderViewCollectionReusableViewDidTapImage(_ header: ProfileHeaderCollectionReusableView)
    func ProfileHeaderViewCollectionReusableViewDidTapClips(_ header: ProfileHeaderCollectionReusableView)
    func ProfileHeaderViewCollectionReusableViewDidTapItems(_ header: ProfileHeaderCollectionReusableView)
    func ProfileHeaderViewCollectionReusableViewDidTapSpots(_ header: ProfileHeaderCollectionReusableView)
    func ProfileHeaderViewCollectionReusableViewDidTapPosts(_ header: ProfileHeaderCollectionReusableView)
    func ProfileHeaderViewCollectionReusableViewDidTapBio(_ header: ProfileHeaderCollectionReusableView)
    func ProfileHeaderViewCollectionReusableViewDidTapLink( _ header: ProfileHeaderCollectionReusableView)
    
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "profileHeaderCollectionReusableView"
    
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16)
        label.text = "bio"
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let linkButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemTeal, for: .normal)
        return button
    }()
    
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    
    private let clipsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "video.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let photoButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemGray
        let image = UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let itemButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemGray
        let image = UIImage(systemName: "bag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let spotButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemGray
        let image = UIImage(systemName: "building.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    
    public let countContainerView = ProfileHeaderCountView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(countContainerView)
        addSubview(bioLabel)
        addSubview(spotButton)
        addSubview(clipsButton)
        addSubview(itemButton)
        addSubview(photoButton)
        addSubview(nameLabel)
        addSubview(linkButton)
        clipsButton.addTarget(self, action: #selector(didTapClips), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        itemButton.addTarget(self, action: #selector(didTapItems), for: .touchUpInside)
        spotButton.addTarget(self, action: #selector(didTapSpots), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBio))
        bioLabel.addGestureRecognizer(tap)
        linkButton.addTarget(self, action: #selector(didTapWebLink), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = (width - 10)/4
        let quarterSize: CGFloat = (width/4)
        let buttonSize: CGFloat = quarterSize/2.8
        
        imageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        countContainerView.frame = CGRect(x: imageView.right + 10, y: 3, width: width-imageView.right-10, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom + 7, width: 200, height: 20)
        bioLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: (width - 20), height: 70)
        linkButton.frame = CGRect(x: 10, y: bioLabel.bottom, width: width - 20, height: 20)
        clipsButton.frame = CGRect(x: (quarterSize - buttonSize)/2, y: height - buttonSize - 1, width: buttonSize + 7, height: buttonSize)
        photoButton.frame = CGRect(x: quarterSize + ((quarterSize - buttonSize)/2), y: height - buttonSize - 1, width: buttonSize, height: buttonSize)
        itemButton.frame = CGRect(x: (quarterSize*2) + ((quarterSize - buttonSize)/2), y: height - buttonSize - 1, width: buttonSize, height: buttonSize)
        spotButton.frame = CGRect(x: (quarterSize*3) + ((quarterSize - buttonSize)/2), y: height - buttonSize - 1, width: buttonSize, height: buttonSize)
        
        
        
    }
    
    public func configure(with viewModel: ProfileHeaderViewModel) {
        imageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        var text = ""
        if let name = viewModel.name {
            nameLabel.text = name
        }
        guard let bioText = viewModel.bio else {return}
        
        if bioText.count < 45 {
            text = "\(bioText)\n"
        } else {
            text = bioText
        }
        
        linkButton.setTitle(viewModel.webLink, for: .normal)
        
       
        bioLabel.text = text
        
        let containerView = ProfileHeaderCountViewModel(followerCount: viewModel.followerCount, followingCount: viewModel.followingCount, clipCount: viewModel.clipCount, actionType: viewModel.buttonType)
        countContainerView.configure(with: containerView)
        
        
    }
    
    @objc func didTapImage() {
        delegate?.ProfileHeaderViewCollectionReusableViewDidTapImage(self)
    }
    
    @objc func didTapBio() {
        delegate?.ProfileHeaderViewCollectionReusableViewDidTapBio(self)
    }
    
    @objc func didTapWebLink() {
        delegate?.ProfileHeaderViewCollectionReusableViewDidTapLink(self)
    }
    
    @objc func didTapClips() {
        delegate?.ProfileHeaderViewCollectionReusableViewDidTapClips(self)
        
        DispatchQueue.main.async { [weak self] in
            let clipImage = UIImage(systemName: "video.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.clipsButton.setImage(clipImage, for: .normal)
            self?.clipsButton.tintColor = .label
            
            let postImage = UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.photoButton.setImage(postImage, for: .normal)
            self?.photoButton.tintColor = .systemGray
            
            let itemImage = UIImage(systemName: "bag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.itemButton.setImage(itemImage, for: .normal)
            self?.itemButton.tintColor = .systemGray
            
            let spotImage = UIImage(systemName: "building.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.spotButton.setImage(spotImage, for: .normal)
            self?.spotButton.tintColor = .systemGray
            
        }
        
    }
    
    @objc func didTapItems() {
        delegate?.ProfileHeaderViewCollectionReusableViewDidTapItems(self)
        
        DispatchQueue.main.async { [weak self] in
            let clipImage = UIImage(systemName: "video", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.clipsButton.setImage(clipImage, for: .normal)
            self?.clipsButton.tintColor = .systemGray
            
            let postImage = UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.photoButton.setImage(postImage, for: .normal)
            self?.photoButton.tintColor = .systemGray
            
            let itemImage = UIImage(systemName: "bag.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.itemButton.setImage(itemImage, for: .normal)
            self?.itemButton.tintColor = .label
            
            let spotImage = UIImage(systemName: "building.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.spotButton.setImage(spotImage, for: .normal)
            self?.spotButton.tintColor = .systemGray
            
        }

    }
    
    @objc func didTapSpots() {
        delegate?.ProfileHeaderViewCollectionReusableViewDidTapSpots(self)
        
        DispatchQueue.main.async { [weak self] in
            let clipImage = UIImage(systemName: "video", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.clipsButton.setImage(clipImage, for: .normal)
            self?.clipsButton.tintColor = .systemGray
            
            let postImage = UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.photoButton.setImage(postImage, for: .normal)
            self?.photoButton.tintColor = .systemGray
            
            let itemImage = UIImage(systemName: "bag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.itemButton.setImage(itemImage, for: .normal)
            self?.itemButton.tintColor = .systemGray
            
            let spotImage = UIImage(systemName: "building.2.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.spotButton.setImage(spotImage, for: .normal)
            self?.spotButton.tintColor = .label
            
        }

    }
    
    @objc func didTapPosts() {
        
        delegate?.ProfileHeaderViewCollectionReusableViewDidTapPosts(self)
        
        DispatchQueue.main.async { [weak self] in
            let clipImage = UIImage(systemName: "video", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.clipsButton.setImage(clipImage, for: .normal)
            self?.clipsButton.tintColor = .systemGray
            
            let postImage = UIImage(systemName: "photo.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.photoButton.setImage(postImage, for: .normal)
            self?.photoButton.tintColor = .label
            
            let itemImage = UIImage(systemName: "bag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.itemButton.setImage(itemImage, for: .normal)
            self?.itemButton.tintColor = .systemGray
            
            let spotImage = UIImage(systemName: "building.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.spotButton.setImage(spotImage, for: .normal)
            self?.spotButton.tintColor = .systemGray
            
            
        }
        
    }
}


