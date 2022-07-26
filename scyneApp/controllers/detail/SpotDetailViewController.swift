//
//  SpotDetailViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/10/21.
//

import UIKit
import FirebaseFirestore
import SafariServices
import JGProgressHUD

class SpotDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let spot: SpotModel
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let spotId: String?
    
    private let post: Post?
    
    private var header: SpotHeaderViewModel?
    
    private var collectionView: UICollectionView?
    
    private var viewModels = [HomeFeedCellType]()
    
    private var isSaved = false
    
    private var lastDocument: DocumentSnapshot?
    
    public var completion: ((Bool) -> Void)?
    
    private var currentIndex = 0
    
    private var isCurrentViewController = false
    
    private var blockedUsers: [String] = []
    
    private var PhotoLibraryAuthorizationStatus = RequestPhotoLiobraryAuthorizationController.getPhotoLibraryAuthorizationStatus()
    
    
    init(spot: SpotModel, post: Post) {
        self.spot = spot
        self.spotId = spot.spotId
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = spot.nickName.uppercased()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        self.isSaved = spot.isSaved
        configureCollectionView()
        fetchSpotInfo()
        fetchPosts()
        blockedUsers = infoManager.shared.blockUsers
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isCurrentViewController = false
        let videoIndex1 = IndexPath(row: currentIndex, section: 0)
        let videoIndex2 = IndexPath(row: currentIndex - 1, section: 0)
        let videoIndex3 = IndexPath(row: currentIndex + 1, section: 0)
        if let videoCell = collectionView?.cellForItem(at: videoIndex1) as? SingleVideoCollectionViewCell {
            videoCell.pauseVideo()
        }
        if let videoCell2 = collectionView?.cellForItem(at: videoIndex2) as? SingleVideoCollectionViewCell {
            videoCell2.pauseVideo()
        }
        if let videoCell3 = collectionView?.cellForItem(at: videoIndex3) as? SingleVideoCollectionViewCell {
            videoCell3.pauseVideo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isCurrentViewController = true
    }
    
    
    
    
    func fetchSpotInfo() {
        guard let post = self.post else {return}
        self.header = SpotHeaderViewModel(spotPictureUrl: spot.spotPhotoUrl, spotNickname: spot.nickName, spotUploader: "uploaded by \(spot.postedBy)", address: spot.location, isSaved: self.isSaved, post: post, numberOfPics: post.urlCount )
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
        
    }
    
    
    
    func configureCollectionView() {
        let sectionHeight: CGFloat = 260 + view.width
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {
            index, _ -> NSCollectionLayoutSection? in
            
            //items
            
            let posterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
            )
            
            let postItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
            
            let actionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(35)))
            
            let titleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)))
            
            let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)))
            
            let timeStampItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)))
            

            //group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(sectionHeight)), subitems: [posterItem, postItem,actionItem, titleItem, captionItem, timeStampItem]
            )
            
            //section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.75)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
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
        collectionView.register(titleCollectionViewCell.self, forCellWithReuseIdentifier: titleCollectionViewCell.identifier)
        collectionView.register(SpotHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SpotHeaderCollectionReusableView.identifier)
        collectionView.register(MultiPhotoCollectionViewCell.self, forCellWithReuseIdentifier: MultiPhotoCollectionViewCell.identifier)
        collectionView.register(SingleVideoCollectionViewCell.self, forCellWithReuseIdentifier: SingleVideoCollectionViewCell.identifier)
        collectionView.register(pageTurnerCollectionViewCell.self, forCellWithReuseIdentifier: pageTurnerCollectionViewCell.identifier)
        collectionView.register(AdvertisementHeaderCollectionViewCell.self, forCellWithReuseIdentifier: AdvertisementHeaderCollectionViewCell.identifier)
        collectionView.register(AdvertisementWebLinkCollectionViewCell.self, forCellWithReuseIdentifier: AdvertisementWebLinkCollectionViewCell.identifier)
        self.collectionView = collectionView
    }
    
    private func fetchPosts() {
        guard let spot = self.spotId else {return}
        
        spinner.show(in: view)
        
        DatabaseManager.shared.getAllClipsForSpot(for: spot, completion: {
            [weak self] clips, lastDoc in
            
            guard let last = lastDoc else {
                self?.spinner.dismiss()
                return}
            self?.lastDocument = last
            
            let group = DispatchGroup()
            for clip in clips {
                group.enter()
                
                guard let isBlocked = self?.blockedUsers.contains(clip.posterEmail) else {
                    group.leave()
                    return}
                if isBlocked {
                    group.leave()
                    continue
                }
                
                
                StorageManager.shared.profilePictureUrl(for: clip.posterEmail) { [weak self] profilePictureUrl in
                    
                    guard let profilePic = profilePictureUrl else {
                        group.leave()
                        return}
                    
                    guard let email = UserDefaults.standard.string(forKey: "email") else {
                        group.leave()
                        return}
                    
                    guard let firstUrl = clip.photoUrls.first else {
                        group.leave()
                        return}
                    
                    guard let videoUrl = URL(string: firstUrl) else {
                        group.leave()
                        return}
                    
                    
                    DatabaseManager.shared.getTotalViews(for: clip, completion: {
                        [weak self] views in
                        
                        DatabaseManager.shared.getTotalLikers(for: clip, completion: {
                            likers in
                            
                            let isClipLiked = likers.contains(email)
                            
                            let clipData: [HomeFeedCellType] = [
                                .poster(viewModel: PosterCollectionViewCellviewModel(email: clip.posterEmail, username: clip.posterUsername, region: clip.region, post: clip, postType: "clip", profilePicture: profilePic)
                                ),
                                .singleVideo(viewModel: SingleVideoCollectionViewCellViewModel(url: videoUrl, post: clip, viewers: views, type: "clip")
                                      ),
                                .postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: isClipLiked, likeCount: likers.count, viewCount: views, post: clip, likers: likers)),
                                .title(viewModel: TitleCollectionViewCellViewModel(title: clip.posterUsername)),
                                .caption(viewModel: PostCaptionCollectionViewCellModel(caption: clip.caption)),
                                .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: clip.postedDateNum, dateString: clip.postedDateString))
                                ]
                            guard let vms = self?.viewModels else {return}
                            self?.viewModels = vms + clipData
                            group.leave()
                        
                    })
                    })
                }
            }
            group.notify(queue: .main, execute: {
                self?.spinner.dismiss()
                self?.collectionView?.reloadData()
                
            })
        })
    }
    
    private func blockAUser(email: String, currentEmail: String) {
        let ac = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Block", style: .destructive, handler: {
            [weak self] _ in
            DatabaseManager.shared.blockUser(email: email, currentEmail: currentEmail, completion: {
                [weak self] success in
                if success {
                    NotificationCenter.default.post(name: Notification.Name("userDidChangeBlock"), object: nil)
                    let ac = UIAlertController(title: "user blocked", message: "When app refreshes you will no longer see there content", preferredStyle: .alert)
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
    

    @objc func didTapAdd() {
        let ac = UIAlertController(title: "Select an upload option", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Upload a clip to this spot", style: .default) { [weak self] _ in
           
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = ClipCheckPermisssionsViewController(spot: self?.spot.spotId)
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = ClipUploaderViewController(urls: [], spot: self?.spot.spotId)
            self?.navigationController?.pushViewController(vc, animated: true)
            
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //collection view functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.row]
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
            cell.delegate = self
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
            cell.delegate = self
            return cell
        case .advertisementheader(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdvertisementHeaderCollectionViewCell.identifier, for: indexPath) as? AdvertisementHeaderCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .AdPageTurner(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pageTurnerCollectionViewCell.identifier, for: indexPath) as? pageTurnerCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SpotHeaderCollectionReusableView.identifier, for: indexPath) as? SpotHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        header?.isSaved = self.isSaved
        if let viewModel = header {
            headerView.configure(with: viewModel)
        }
        headerView.delegate = self
        return headerView
            
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
            currentIndex = indexPath.row
            cell.index = indexPath.row
            if isCurrentViewController {
                DispatchQueue.main.async {
                    cell.playVideo()
                }
                cell.startTimer()
                
                let index = indexPath.row
                
                let videoIndex1 = IndexPath(row: index - 1, section: 0)
                let videoIndex2 = IndexPath(row: index + 1, section: 0)
                
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
        }
        
        if cell.reuseIdentifier == PostActionCollectionViewCell.identifier {
            guard let cell = cell as? PostActionCollectionViewCell else {return}
            cell.index = indexPath.row
            print(indexPath)
            
            if !cell.isLiked {
                let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                DispatchQueue.main.async {
                    cell.likeButton.setImage(image, for: .normal)
                    cell.likeButton.tintColor = .label
                }
            } else {
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                DispatchQueue.main.async {
                    cell.likeButton.setImage(image, for: .normal)
                    cell.likeButton.tintColor = .systemRed
                }
            }
        }
        
        if cell.reuseIdentifier == PosterCollectionViewCell.identifier {
            guard let cell = cell as? PosterCollectionViewCell else { return }
            cell.index = indexPath.row
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        guard let collectionHeight = collectionView?.contentSize.height else { return }
        if position > collectionHeight - 100 - scrollView.frame.size.height {
            
            guard let lastDocu = self.lastDocument else {return}
            guard let spot = self.spotId else {return}
            
            guard !DatabaseManager.shared.isPaginating else {
                return
            }
            
            DatabaseManager.shared.continueGetClipsForSpot(for: spot , lastDoc: lastDocu, completion: {
                [weak self] clips, lastDoc in
                
                print(clips)
                
                guard let last = lastDoc else {return}
                self?.lastDocument = last
                
                let group = DispatchGroup()
                for clip in clips {
                    
                    guard let isBlocked = self?.blockedUsers.contains(clip.posterEmail) else {
                        group.leave()
                        return}
                    if isBlocked {
                        group.leave()
                        continue
                    }
                    
                    group.enter()
                    
                    StorageManager.shared.profilePictureUrl(for: clip.posterEmail) { [weak self] profilePictureUrl in
                        
                        guard let profilePic = profilePictureUrl else {
                            group.leave()
                            return}
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        guard let firstUrl = clip.photoUrls.first else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: firstUrl) else {
                            group.leave()
                            return}
                        
                        
                        DatabaseManager.shared.getTotalViews(for: clip, completion: {
                            [weak self] views in
                            
                            DatabaseManager.shared.getTotalLikers(for: clip, completion: {
                                likers in
                                
                                let isClipLiked = likers.contains(email)
                                
                                let clipData: [HomeFeedCellType] = [
                                    .poster(viewModel: PosterCollectionViewCellviewModel(email: clip.posterEmail, username: clip.posterUsername, region: clip.region, post: clip, postType: "clip", profilePicture: profilePic)
                                    ),
                                    .singleVideo(viewModel: SingleVideoCollectionViewCellViewModel(url: videoUrl, post: clip, viewers: views, type: "clip")
                                          ),
                                    .postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: isClipLiked, likeCount: likers.count, viewCount: views, post: clip, likers: likers)),
                                    .title(viewModel: TitleCollectionViewCellViewModel(title: clip.posterUsername)),
                                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: clip.caption)),
                                    .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: clip.postedDateNum, dateString: clip.postedDateString))
                                    ]
                                guard let vms = self?.viewModels else {return}
                                self?.viewModels = vms + clipData
                                group.leave()
                            
                        })
                        })
                    }
                }
                group.notify(queue: .main, execute: {
                    self?.collectionView?.reloadData()
                    
                })
                
            })
            
        }
    }

}

extension SpotDetailViewController: PosterCollectionViewCellDelegate {
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

extension SpotDetailViewController: titleCollectionViewCellDelegate {
    func titleCollectionViewCellDelegateDidTapTitle(_ cell: titleCollectionViewCell) {
        
    }
    
    
}

extension SpotDetailViewController: PostActionCollectionViewCellDelegate {
    
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
            self.viewModels[index] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false, likeCount: count, viewCount: views, post: post, likers: likers))
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
            self.viewModels[index] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true, likeCount: count, viewCount: views, post: post, likers: likers))
            NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
            
        }
    }
    
    func postActionsCollectionViewCellDidTapPin(_ cell: PostActionCollectionViewCell, post: Post) {
        guard let spotId = post.spotId else {
            return
        }
        if spotId != "" {
            guard let spot = self.post else {return}
            let vc = SinglePinViewController(spot: spot)
            navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let ac = UIAlertController(title: "No spot info attached", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionCollectionViewCell, post: Post) {
        let vc = commentViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension SpotDetailViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption: String) {
        let vc = captionDetailViewController(caption: caption)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SpotDetailViewController: SpotHeaderCollectionReusableViewDelegate {
    func spotHeaderCollectionReusableViewDidTapPoster(_ header: SpotHeaderCollectionReusableView, username: String, email: String, region: String) {
        let vc = ProfileViewController(user: User(username: username, email: email, region: region))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func spotHeaderCollectionReusableViewDidTapPin(_ header: SpotHeaderCollectionReusableView, post: Post) {
        let vc = SinglePinViewController(spot: post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func SpotHeaderCollectionReusableViewDidTapComment(_ header: SpotHeaderCollectionReusableView, post: Post) {
        let vc = commentViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func SpotheaderCollectionReusableViewdidTapSave(_ header: SpotHeaderCollectionReusableView) {
        let currentSpot = self.spot
        
        spinner.show(in: view)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
       
        DatabaseManager.shared.updateSpotSaved(state: self.isSaved ? .unSaved : .save, postId: currentSpot.spotId, completion: {
            [weak self] success in
            if success {
                guard let savedState = self?.isSaved else {return}
                self?.isSaved = !savedState
                self?.completion?(true)
                self?.spinner.dismiss()
                DispatchQueue.main.async {
                    self?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .done, target: self, action: #selector(self?.didTapBack))
                }
            } else {
                DispatchQueue.main.async {
                    self?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .done, target: self, action: #selector(self?.didTapBack))
                }
                self?.spinner.dismiss()
            }
        })
            
      
        
    }
    
}


extension SpotDetailViewController: AdvertisementWebLinkCollectionViewCellDelegate {
    func AdvertisementDidTapLink(_ cell: AdvertisementWebLinkCollectionViewCell, link: String) {
        if let url = URL(string: link) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
    
    
}

extension SpotDetailViewController: AdvertisementHeaderDelegate {
    func advertisementheaderDidTapMore(_ cell: AdvertisementHeaderCollectionViewCell, link: String) {
        let ac = UIAlertController(title: "Actions", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Visit their website", style: .default, handler: {
            [weak self] _ in
            if let url = URL(string: link) {
                let safariVC = SFSafariViewController(url: url)
                self?.present(safariVC, animated: true)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }

    
}

extension SpotDetailViewController: MultiImageViewDelegate {
    func MultiImageViewDelegateDidDoubleTap(_ cell: MultiPhotoCollectionViewCell, post: Post, index: Int, type: String) {
        //nothing
    }
    
    func MultiImageViewDelegateDidScroll(_ cell: MultiPhotoCollectionViewCell, page: Int, index: Int, type: String) {
       
        
    }
    
    
}

extension SpotDetailViewController: SingleVideoCollectionViewCellDelegate {
    func SingleVideoCollectionViewCellDidDoubleTap(_ cell: SingleVideoCollectionViewCell, index: Int, post: Post, viewers: Int, type: String) {
        
            guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
            
            let actionIndex = IndexPath(row: (index + 1), section: 0)
            
            guard let cell = collectionView?.cellForItem(at: actionIndex) as? PostActionCollectionViewCell else {
                return }
        
            
            if cell.isLiked {
                cell.isLiked = !cell.isLiked
                let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .label
                DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
                cell.updateLikeLabel(with: currentEmail)
                let likers = cell.likers
                self.viewModels[index + 1] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false, likeCount: likers.count, viewCount: cell.viewers, post: post, likers: likers))
                NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
                
            } else {
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .systemRed
                cell.isLiked = !cell.isLiked
                DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
                cell.updateLikeLabel(with: currentEmail)
                let likers = cell.likers
                self.viewModels[index + 1] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true, likeCount: likers.count, viewCount: cell.viewers, post: post, likers: likers))
                NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
                
            }
    }
}



