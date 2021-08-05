//
//  ProfileHeaderCountView.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol ProfileHeaderCountViewDelegate: AnyObject {
    func profileHeaderCountViewDidTapFollowers(_ countainerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollowing(_ countainerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapPosts(_ countainerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapEditProfile(_ countainerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollow(_ countainerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapUnfollow(_ countainerView: ProfileHeaderCountView)
    
}

class ProfileHeaderCountView: UIView {
    
    weak var delegate: ProfileHeaderCountViewDelegate?
    
    private var action = ProfileButtonType.edit
    
    private var isFollowing = false
    
    private var followingCount = 0
    
    private var followerCount = 0
    
    public let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
//        button.layer.cornerRadius = 4
//        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    public let followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
//        button.layer.cornerRadius = 4
//        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
//        button.layer.cornerRadius = 4
//        button.layer.borderWidth = 0.5
//        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private let actionButton = ScyneFollowButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(followerCountButton)
        addSubview(actionButton)
        addSubview(followingCountButton)
        addSubview(postCountButton)
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth: CGFloat = (width - 15)/3
        followerCountButton.frame = CGRect(x: 0, y: 5, width: buttonWidth, height: height/2)
        actionButton.frame = CGRect(x: 5, y: height-37, width: width-10, height: 37)
        followingCountButton.frame = CGRect(x: followerCountButton.right+5, y: 5, width: buttonWidth, height: height/2)
        postCountButton.frame = CGRect(x: followingCountButton.right + 5, y: 5, width: buttonWidth, height: height/2)
        
    }
    
    private func addActions() {
        followerCountButton.addTarget(self, action: #selector(didTapFollowers), for: .touchUpInside)
        followingCountButton.addTarget(self, action: #selector(didTapFollowing), for: .touchUpInside)
        postCountButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapActions), for: .touchUpInside)
        
    }
    
    @objc func didTapFollowers() {
        delegate?.profileHeaderCountViewDidTapFollowers(self)
        
    }
    
    @objc func didTapFollowing() {
        delegate?.profileHeaderCountViewDidTapFollowing(self)
    
    }
    
    @objc func didTapActions() {
        print(self.isFollowing)
        switch action {
        case .edit:
            delegate?.profileHeaderCountViewDidTapEditProfile(self)
        case .follow(_):
            if self.isFollowing {
                //unfollow
                delegate?.profileHeaderCountViewDidTapUnfollow(self)
                self.followerCount -= 1
                followerCountButton.setTitle("\(self.followerCount)\nFollowers", for: .normal)
            } else {
                //follow
                delegate?.profileHeaderCountViewDidTapFollow(self)
                self.followerCount += 1
                followerCountButton.setTitle("\(self.followerCount)\nFollowers", for: .normal)
            }
            if self.isFollowing {
                self.isFollowing = false
            } else {
                self.isFollowing = true
            }
            print("atcq")
            actionButton.configure(for: self.isFollowing ? .unfollow : .follow)
        } }
    
    @objc func didTapPosts() {
        delegate?.profileHeaderCountViewDidTapPosts(self)
        
    }
    
    
    public func configure(with viewModel: ProfileHeaderCountViewModel) {
        followerCountButton.setTitle("\(viewModel.followerCount)\nFollowers", for: .normal)
        followingCountButton.setTitle("\(viewModel.followingCount)\nFollowing", for: .normal)
        postCountButton.setTitle("\(viewModel.clipCount)\nClips", for: .normal)
        
        self.action = viewModel.actionType
        
        self.followerCount = viewModel.followerCount
        
        self.followingCount = viewModel.followingCount
        
        switch viewModel.actionType {
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
        case .follow(let isFollowing):
            print(self.isFollowing)
            self.isFollowing = isFollowing
            actionButton.configure(for: isFollowing ? .unfollow : .follow)
           
        }
        
    }
    
    
    
}
