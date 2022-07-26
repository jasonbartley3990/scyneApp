//
//  singleClipViewerViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/6/21.
//

import UIKit

class singleClipViewerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var viewModels = [[HomeFeedCellType]]()
    
    private var isLiked: Bool = false
    
    private var post: Post
    
    public var completion: (() -> Void)?
    
    private var collectionView: UICollectionView?
    
    private var isCurrentViewController = false
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        createViewModel(post: self.post, completion: {
            [weak self] success in
            if success {
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView?.reloadData()
                }
            } else {
                self?.showAlert()
            }
        
    })
        
        }
    
    override func viewDidAppear(_ animated: Bool) {
        isCurrentViewController = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isCurrentViewController = false
        guard let videoCell = collectionView?.cellForItem(at: IndexPath(row: 2, section: 0)) as? SingleVideoCollectionViewCell else {
            return
        }
        videoCell.pauseVideo()
    }
        
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func blockAUser(email: String, currentEmail: String) {
        let ac = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Block", style: .destructive, handler: {
            [weak self] _ in
            DatabaseManager.shared.blockUser(email: email, currentEmail: currentEmail, completion: {
                [weak self] success in
                if success {
                    NotificationCenter.default.post(name: Notification.Name("userDidChangeBlock"), object: nil)
                    let ac = UIAlertController(title: "User blocked", message: "When app refreshes you will no longer see there content", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    DispatchQueue.main.async {
                        self?.present(ac, animated: true)
                    }
                }
            })
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    private func showAlert() {
        let ac = UIAlertController(title: "Something went wrong", message: "Please try again later", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        DispatchQueue.main.async {
            self.present(ac,animated: true)
        }
    }
    
    
    private func createViewModel(post: Post, completion: @escaping (Bool) -> Void) {
        
        StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
            
            guard let profilePic = profilePictureUrl else {
                completion(false)
                return}
            
            guard let email = UserDefaults.standard.string(forKey: "email") else {
                completion(false)
                return}
            
            guard let firstUrl = post.photoUrls.first else {
                completion(false)
                return}
            
            guard let videoUrl = URL(string: firstUrl) else {
                completion(false)
                return}
            
            DatabaseManager.shared.getTotalViews(for: post, completion: {
                [weak self] views in
                
                DatabaseManager.shared.getTotalLikers(for: post, completion: {
                    [weak self] likers in
                    
                    let isClipLiked = likers.contains(email)
                    
                    let clipData: [HomeFeedCellType] = [
                        .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "clip", profilePicture: profilePic)
                        ),
                        .singleVideo(viewModel: SingleVideoCollectionViewCellViewModel(url: videoUrl, post: post, viewers: views, type: "clip")
                              ),
                        .postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: isClipLiked, likeCount: likers.count, viewCount: views, post: post, likers: likers)),
                        .title(viewModel: TitleCollectionViewCellViewModel(title: post.posterUsername)),
                        .caption(viewModel: PostCaptionCollectionViewCellModel(caption: post.caption)),
                        .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
                        ]
                    self?.viewModels.append(clipData)
                    completion(true)
        
                })
            })
        }
    }
                                 
    func configureCollectionView() {
        let sectionHeight: CGFloat = 260 + view.width
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {
            index, _ -> NSCollectionLayoutSection? in
        
            let posterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
            )
            
            let postItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
            
            let actionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(35)))
            
            let titleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)))
            
            let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)))
            
            let timeStampItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)))

            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(sectionHeight)), subitems: [posterItem, postItem, actionItem, titleItem, captionItem, timeStampItem]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
            return section
        }))
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PosterCollectionViewCell.self, forCellWithReuseIdentifier: PosterCollectionViewCell.identifier)
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.register(PostActionCollectionViewCell.self, forCellWithReuseIdentifier: PostActionCollectionViewCell.identifier)
        collectionView.register(PostCaptionCollectionViewCell.self, forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier)
        collectionView.register(PostDatetimeCollectionViewCell.self, forCellWithReuseIdentifier: PostDatetimeCollectionViewCell.identifier)
        collectionView.register(GearActionsCollectionViewCell.self, forCellWithReuseIdentifier: GearActionsCollectionViewCell.identifier)
        collectionView.register(titleCollectionViewCell.self, forCellWithReuseIdentifier: titleCollectionViewCell.identifier)
        collectionView.register(MultiPhotoCollectionViewCell.self, forCellWithReuseIdentifier: MultiPhotoCollectionViewCell.identifier)
        collectionView.register(SingleVideoCollectionViewCell.self, forCellWithReuseIdentifier: SingleVideoCollectionViewCell.identifier)
        self.collectionView = collectionView
    }

    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.section][indexPath.row]
        switch cellType {
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath) as? PosterCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .postActions(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCollectionViewCell.identifier, for: indexPath) as? PostActionCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCaptionCollectionViewCell.identifier, for: indexPath) as? PostCaptionCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .timeStamp(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostDatetimeCollectionViewCell.identifier, for: indexPath) as? PostDatetimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .newSpot(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotHeaderCollectionViewCell.identifier, for: indexPath) as? SpotHeaderCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .spotAction(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotActionsCollectionViewCell.identifier, for: indexPath) as? SpotActionsCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .address(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotAddressCollectionViewCell.identifier, for: indexPath) as? SpotAddressCollectionViewCell else {
                fatalError()
            }
            //cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .gearAction(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GearActionsCollectionViewCell.identifier, for: indexPath) as? GearActionsCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .uploader(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotUploaderCollectionViewCell.identifier, for: indexPath) as? SpotUploaderCollectionViewCell else {
                fatalError()
            }
            //cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .title(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: titleCollectionViewCell.identifier , for: indexPath) as? titleCollectionViewCell else { fatalError() }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .fullLengthAction(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fullLengthActionCollectionViewCell.identifier, for: indexPath) as? fullLengthActionCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel, index: 2)
            return cell
        case .MultiPhoto(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiPhotoCollectionViewCell.identifier, for: indexPath) as? MultiPhotoCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel, id: nil)
            return cell
        case .singleVideo(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleVideoCollectionViewCell.identifier, for: indexPath) as? SingleVideoCollectionViewCell else { fatalError() }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .fullLengthPoster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fullLengthPosterCollectionViewCell.identifier, for: indexPath) as? fullLengthPosterCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
        case .fullLengthTitle(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fullLengthTitleCollectionViewCell.identifier, for: indexPath) as? fullLengthTitleCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
        case .normalPostAction(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NormalPostActionsCollectionViewCell.identifier, for: indexPath) as?
                    NormalPostActionsCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
        case .advertisementLink(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdvertisementWebLinkCollectionViewCell.identifier, for: indexPath) as?
                    AdvertisementWebLinkCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
        case .advertisementheader(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdvertisementHeaderCollectionViewCell.identifier, for: indexPath) as? AdvertisementHeaderCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
        case .AdPageTurner(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pageTurnerCollectionViewCell.identifier, for: indexPath) as? pageTurnerCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
    }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if cell.reuseIdentifier == SingleVideoCollectionViewCell.identifier {
            guard let cell = cell as? SingleVideoCollectionViewCell else {return}
            cell.pauseVideo()
            cell.stopTimer()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        

        
        if cell.reuseIdentifier == SingleVideoCollectionViewCell.identifier {
            guard let cell = cell as? SingleVideoCollectionViewCell else {return}
            cell.playVideo()
            cell.startTimer()
            
            let index = indexPath.section
            
            let videoIndex1 = IndexPath(row: 1, section: index - 1)
            let videoIndex2 = IndexPath(row: 1, section: index + 1)
            
            for cell in 1...2 {
                if cell == 1 {
                    guard let videoCellBefore = collectionView.cellForItem(at: videoIndex1) as? SingleVideoCollectionViewCell else {continue}
                    videoCellBefore.pauseVideo()
                    videoCellBefore.stopTimer()
                    
                }
                
                if cell == 2 {
                    guard let videoCellAfter = collectionView.cellForItem(at: videoIndex2) as? SingleVideoCollectionViewCell else {continue}
                    videoCellAfter.pauseVideo()
                    videoCellAfter.stopTimer()
                    
                }
            }

        }
        
        if cell.reuseIdentifier == PostActionCollectionViewCell.identifier {
            guard let cell = cell as? PostActionCollectionViewCell else {return}
            cell.index = indexPath.section
            
            if !cell.isLiked {
                let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .label
                
            } else {
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .systemRed
                
            }
            
            
        }
    }

}

extension singleClipViewerViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, post: Post, type: String, index: Int) {
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        if currentEmail == post.posterEmail {
            let sheet = UIAlertController(title: "Post action", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            sheet.addAction(UIAlertAction(title: "Delete post", style: .default, handler: {
                [weak self] _ in
                if type == "clip" {
                    let ac = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
                        let postId = post.postId
                        DatabaseManager.shared.deleteClipOrNormalPost(postId: postId, completion: {
                            [weak self] success in
                            if success {
                                self?.completion?()
                                DispatchQueue.main.async {
                                    self?.tabBarController?.selectedIndex = 4
                                    self?.navigationController?.popToRootViewController(animated: false)
                                }
                            }
                        })
                    }))
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self?.present(ac, animated: true)
                }
                
            }))
            present(sheet, animated: true)
            
        } else {
            let sheet = UIAlertController(title: "Post action", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            sheet.addAction(UIAlertAction(title: "Block user", style: .default, handler: {
                [weak self] _ in
                guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
                self?.blockAUser(email: post.posterEmail, currentEmail: currentEmail)
            }))
            sheet.addAction(UIAlertAction(title: "Report post", style: .destructive, handler: {
                [weak self] _ in
                DatabaseManager.shared.reportPost(post: post, completion: {
                    [weak self] success in
                    let ac = UIAlertController(title: "Post reported", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    DispatchQueue.main.async {
                        self?.present(ac,animated: true)
                    }
                })
            }))
            present(sheet, animated: true)
        }
    }
    
    func posterCollectionViewCellDidUsername(_ cell: PosterCollectionViewCell, email: String, username: String, region: String) {
        let vc = ProfileViewController(user: User(username: username, email: email, region: region))
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension singleClipViewerViewController: titleCollectionViewCellDelegate {
    func titleCollectionViewCellDelegateDidTapTitle(_ cell: titleCollectionViewCell) {
        //do nothing
    }
}

extension singleClipViewerViewController: PostActionCollectionViewCellDelegate {
    
    func postActionsCollectionViewCellDidTapViewers(_ cell: PostActionCollectionViewCell, likers: [String], likeCount: Int) {
        let vc = likerTableViewController(likers: likers, likeCount: likeCount)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionCollectionViewCell, isLiked: Bool, post: Post, index: Int) {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        if isLiked {
            cell.isLiked = !isLiked
            let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .label
            DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
            cell.updateLikeLabel(with: currentEmail)
            let likers = cell.likers
            let count = cell.likeCount
            let views = cell.viewers
            self.viewModels[0][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false, likeCount: count, viewCount: views, post: post, likers: likers))
            NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
            
        } else {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .systemRed
            cell.isLiked = !isLiked
            DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
            cell.updateLikeLabel(with: currentEmail)
            let likers = cell.likers
            let count = cell.likeCount
            let views = cell.viewers
            self.viewModels[0][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true, likeCount: count, viewCount: views, post: post, likers: likers))
            NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
            
        }
        
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionCollectionViewCell, post: Post) {
        let vc = commentViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapPin(_ cell: PostActionCollectionViewCell, post: Post) {
        guard let spotId = post.spotId else {
            return
        }
        if spotId != "" {
            DatabaseManager.shared.grabASpot(with: spotId, completion: {
                [weak self] spot in
                guard spot.count != 0 else {return}
                let theSpot = spot[0]
                let vc = SinglePinViewController(spot: theSpot)
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            
        } else {
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: "no spot info attached", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self?.present(ac, animated: true)
            }
        }
    }
}


extension singleClipViewerViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption: String) {
        let vc = captionDetailViewController(caption: caption)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension singleClipViewerViewController: SingleVideoCollectionViewCellDelegate {
    func SingleVideoCollectionViewCellDidDoubleTap(_ cell: SingleVideoCollectionViewCell, index: Int, post: Post, viewers: Int, type: String) {
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        let actionIndex = IndexPath(row: 2, section: 0)
        
        guard let cell = collectionView?.cellForItem(at: actionIndex) as? PostActionCollectionViewCell else { return }
        
        if cell.isLiked {
            cell.isLiked = !cell.isLiked
            let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .label
            DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
            cell.updateLikeLabel(with: currentEmail)
            let likers = cell.likers
            self.viewModels[0][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false, likeCount: likers.count, viewCount: cell.viewers, post: post, likers: likers))
           
            
        } else {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .systemRed
            cell.isLiked = !cell.isLiked
            DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
            cell.updateLikeLabel(with: currentEmail)
            let likers = cell.likers
            self.viewModels[0][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true, likeCount: likers.count, viewCount: cell.viewers, post: post, likers: likers))
        }
    }
}

