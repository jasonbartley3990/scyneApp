//
//  SpotLightViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import CoreLocation
import AVKit
import AVFAudio
import FirebaseFirestore

class SpotLightViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    private var collectionView: UICollectionView?
    
    //viewModels is what the collection view gets it data from
    
    private var viewModels = [[HomeFeedCellType]]()
    
    //a list of videos posts grouped from most viewed, most recent, and local, when user changes feed the viewModels property get set to the same list of what they choose
    
    private var mostViewedViewModels = [[HomeFeedCellType]]()
    
    private var mostRecentViewModels = [[HomeFeedCellType]]()
    
    private var localViewModels = [[HomeFeedCellType]]()
    
    
    private var didFetchMostViewed = false
    
    private var didFetchLocal = false
    
    private var isFeedMostViewed = false
    
    private var isFeedMostRecent = true
    
    private var isFeedLocal = false
    
    private var lastMostRecentDoc: DocumentSnapshot?
    
    private var lastMostViewedDoc: DocumentSnapshot?
    
    private var lastLocalDoc: DocumentSnapshot?
    
    
    
    
    //MARK: authorization properties
    
    private var cameraAuthorizationStatus = RequestCameraAuthorizationController.getCameraAuthorizationStatus()
    
    private var MicrophoneAuthorizationStatus = RequestMicrophoneAuthorizationController.getMicrophoneAuthorizationStatus()
    
    
    private var PhotoLibraryAuthorizationStatus = RequestPhotoLiobraryAuthorizationController.getPhotoLibraryAuthorizationStatus()
    
    private var locationAuthorizationStatus =  CLLocationManager.authorizationStatus()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "FULL LENGTHS"
        view.backgroundColor = .systemBackground
        let filter = UIBarButtonItem(title: "filter", style: .done, target: self, action: #selector(didTapFilter))
        let add = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapAdd))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        navigationItem.rightBarButtonItems = [add, filter, spacer]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearchButton))
        fetchPosts()
        configureCollectionView()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "FULL LENGTHS"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = "VIDEOS"
    }
    
    //MARK: add content
    
    @objc func didTapAdd() {
        let ac = UIAlertController(title: "select an upload option", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "upload a clip", style: .default) { [weak self] _ in

            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = ClipCheckPermisssionsViewController(spot: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = ClipAskForSpotViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload a spot", style: .default) { [weak self] _ in
            guard self?.cameraAuthorizationStatus == .granted else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard self?.MicrophoneAuthorizationStatus == .granted else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            
            let vc = SpotCameraViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload an item for local resale", style: .default) { [weak self] _ in
            guard self?.cameraAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard self?.MicrophoneAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
                
            }
            
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            let vc = GearCameraViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload a normal post", style: .default, handler: {
            [weak self] _ in
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = CheckNormalPhotoLibraryAccessViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = uploadNormalPostViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }))
            
            
        ac.addAction(UIAlertAction(title: "upload a full length", style: .default) { [weak self] _ in
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = CheckPhotoLibraryPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = FulllengthUploadViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    

    //MARK: filtering videos
    
    
    @objc func didTapFilter() {
        
        //changes feed to either most recent, most viewed, or regional
        
        let ac = UIAlertController(title: "filter by", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "recently posted", style: .default, handler: {
            [weak self] _ in
            self?.isFeedLocal = false
            self?.isFeedMostRecent = true
            self?.isFeedMostViewed = false
            guard let allVids = self?.mostRecentViewModels else {return}
            self?.viewModels = allVids
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
                
            }
           
        }))
        ac.addAction(UIAlertAction(title: "most viewed", style: .default, handler: {
            [weak self] _ in
            self?.isFeedLocal = false
            self?.isFeedMostRecent = false
            self?.isFeedMostViewed = true
            
            //checks first if the user had already called it or not , if not then make the initial fetch, if they did then set collection view data to what they had already grabbed
            
            guard let boolean = self?.didFetchMostViewed else {return}
            if boolean {
                guard let allVids = self?.mostViewedViewModels else {return}
                self?.viewModels = allVids
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
                
            } else {
                DatabaseManager.shared.fetchFullLengthsMostViewed(completion: {
                    [weak self] videos, lastDoc in
                    
                    guard let last = lastDoc else {return}
                    
                    self?.lastMostViewedDoc = last
                    
                    let group = DispatchGroup()
                
                    videos.forEach({ video in
                        group.enter()
                        
                        guard let thumbnailUrl = URL(string: video.thumbnailString) else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: video.videoUrlString) else {
                            group.leave()
                            return }
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        let vidId = video.videoId
                        
                        DatabaseManager.shared.getTotalViewsForFullLength(for: vidId, completion: {
                            [weak self] views in
                            
                            DatabaseManager.shared.getTotalLikers(for: video.videoId, completion: {
                                [weak self] likers in
                                
                                let isLikedVideo = likers.contains(email)
                                
                                let videoData: [HomeFeedCellType] = [
                                    .title(viewModel: TitleCollectionViewCellViewModel(title: video.videoName)),
                                    .post(viewModel: PostCollectionViewCellViewModel(postUrl: thumbnailUrl, fullLength: video)
                                    ),
                                    .fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: isLikedVideo, videoUrl: videoUrl, viewsCount: views, video: video.videoId, likers: likers, fullVideo: video)),
                                    .fullLengthPoster(viewModel: fullLengthPosterCollectionViewCellViewModel(poster: video.poster, posterEmail: video.posterEmail, region: video.region)),
                                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: video.caption)),
                                    .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: video.postedDateNum, dateString: video.postedDate))
                                ]
                                self?.mostViewedViewModels.append(videoData)
                                group.leave()
                                })
                        })
                        })
                    group.notify(queue: .main, execute: {
                        self?.didFetchMostViewed = true
                        guard let allVids = self?.mostViewedViewModels else {return}
                        self?.viewModels = allVids
                        DispatchQueue.main.async {
                            self?.collectionView?.reloadData()
                        }
                    })
                    
                   
                })
            }
            
            
            
        }))
        ac.addAction(UIAlertAction(title: "region", style: .default, handler: {
            [weak self] _ in
            self?.isFeedLocal = true
            self?.isFeedMostRecent = false
            self?.isFeedMostViewed = false
            
            //checks if they had already grabbed regional videos, if they didnt they do the initial fetch, if they did, then set collection view data to what has already been grabbed
            
            guard let boolean = self?.didFetchLocal else {return}
            if boolean {
                guard let allVids = self?.localViewModels else {return}
                self?.viewModels = allVids
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            } else {
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                
                let group = DispatchGroup()
                
                DatabaseManager.shared.fetchFullLengthsForRegion(region: region, completion: {
                    [weak self] videos, lastDoc in
                    
                    guard let last = lastDoc else {return}
                    
                    self?.lastLocalDoc = last
                
                    videos.forEach({ video in
                        group.enter()
                        
                        guard let thumbnailUrl = URL(string: video.thumbnailString) else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: video.videoUrlString) else {
                            group.leave()
                            return }
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        let vidId = video.videoId
                        
                        DatabaseManager.shared.getTotalViewsForFullLength(for: vidId, completion: {
                            [weak self] views in
                            
                            DatabaseManager.shared.getTotalLikers(for: video.videoId, completion: {
                                [weak self] likers in
                                
                                let isLikedVideo = likers.contains(email)
            
                                let videoData: [HomeFeedCellType] = [
                                    .title(viewModel: TitleCollectionViewCellViewModel(title: video.videoName)),
                                    .post(viewModel: PostCollectionViewCellViewModel(postUrl: thumbnailUrl, fullLength: video)
                                    ),
                                    .fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: isLikedVideo, videoUrl: videoUrl, viewsCount: views, video: video.videoId, likers: likers, fullVideo: video)),
                                    .fullLengthPoster(viewModel: fullLengthPosterCollectionViewCellViewModel(poster: video.poster, posterEmail: video.posterEmail, region: video.region)),
                                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: video.caption)),
                                    .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: video.postedDateNum, dateString: video.postedDate))
                                ]
                                
                                self?.localViewModels.append(videoData)
                                group.leave()
                                })
                                })
                    })
                    group.notify(queue: .main, execute: {
                        self?.didFetchLocal = true
                        guard let allVids = self?.localViewModels else {return}
                        self?.viewModels = allVids
                        self?.collectionView?.reloadData()
                        
                    })
                   
                })
            }
            
            
            
            
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    //MARK: search function
    
    
    @objc func didTapSearchButton() {
        let vc = FullLengthSearchViewController()
        vc.title = "search"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: grab most recent videos
    
    private func fetchPosts() {
            
        DatabaseManager.shared.fetchFullLengthsMostRecent(completion: {
            [weak self] videos, lastDoc in
            
            guard let last = lastDoc else {return}
            
            self?.lastMostRecentDoc = last
            
            let group = DispatchGroup()
        
            videos.forEach({ video in
                group.enter()
                guard let thumbnailUrl = URL(string: video.thumbnailString) else {
                    group.leave()
                    return}
                
                guard let videoUrl = URL(string: video.videoUrlString) else {
                    group.leave()
                    return }
                
                
                guard let email = UserDefaults.standard.string(forKey: "email") else {
                    group.leave()
                    return}
                
                let vidId = video.videoId
                
                DatabaseManager.shared.getTotalViewsForFullLength(for: vidId, completion: {
                    [weak self] views in
                    
                    DatabaseManager.shared.getTotalLikers(for: vidId, completion: {
                        [weak self] likers in
                        
                        let isVideoLiked = likers.contains(email)
                        
                        let videoData: [HomeFeedCellType] = [
                            .fullLengthTitle(viewModel: fullLengthTitleCollectionViewCellViewModel(title: video.videoName)),
                            .post(viewModel: PostCollectionViewCellViewModel(postUrl: thumbnailUrl, fullLength: video)
                            ),
                            .fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: isVideoLiked, videoUrl: videoUrl, viewsCount: views, video: video.videoId, likers: likers, fullVideo: video )),
                            .fullLengthPoster(viewModel: fullLengthPosterCollectionViewCellViewModel(poster: video.poster, posterEmail: video.posterEmail, region: video.region)),
                            .caption(viewModel: PostCaptionCollectionViewCellModel(caption: video.caption)),
                            .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: video.postedDateNum, dateString: video.postedDate))
                        ]
                        self?.viewModels.append(videoData)
                        self?.mostRecentViewModels.append(videoData)
                        group.leave()
                        })
                        
                    })
                    
                   
            })
    
            group.notify(queue: .main, execute: {
                self?.collectionView?.reloadData()
                
            })
            
        })
        
    }
    
    //MARK: configure collection view
    
    func configureCollectionView() {
        let sectionHeight: CGFloat = 225 + view.width
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {
            index, _ -> NSCollectionLayoutSection? in
            
            //item
            let posterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
            )
            
            let postItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
            
            let optionOneitem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(35)))
            
            let titleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)))
            
            let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)))
            
            
            let timeStampItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)))
            
            //group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(sectionHeight)), subitems: [posterItem, postItem, optionOneitem, titleItem, captionItem, timeStampItem]
            )
            //section
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
        collectionView.register(SpotActionsCollectionViewCell.self, forCellWithReuseIdentifier: SpotActionsCollectionViewCell.identifier)
        collectionView.register(SpotActionsCollectionViewCell.self, forCellWithReuseIdentifier: SpotActionsCollectionViewCell.identifier)
        collectionView.register(SpotUploaderCollectionViewCell.self, forCellWithReuseIdentifier: SpotUploaderCollectionViewCell.identifier)
        collectionView.register(titleCollectionViewCell.self, forCellWithReuseIdentifier: titleCollectionViewCell.identifier)
        collectionView.register(fullLengthActionCollectionViewCell.self, forCellWithReuseIdentifier: fullLengthActionCollectionViewCell.identifier)
        collectionView.register(MultiPhotoCollectionViewCell.self, forCellWithReuseIdentifier: MultiPhotoCollectionViewCell.identifier)
        collectionView.register(SingleVideoCollectionViewCell.self, forCellWithReuseIdentifier: SingleVideoCollectionViewCell.identifier)
        collectionView.register(fullLengthPosterCollectionViewCell.self, forCellWithReuseIdentifier: fullLengthPosterCollectionViewCell.identifier)
        collectionView.register(fullLengthTitleCollectionViewCell.self, forCellWithReuseIdentifier: fullLengthTitleCollectionViewCell.identifier)
        self.collectionView = collectionView
    }
    
    
    //MARK: collection view functions
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.section][indexPath.row]
        switch cellType {
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath) as? PosterCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .postActions(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCollectionViewCell.identifier, for: indexPath) as? PostActionCollectionViewCell else {
                fatalError()
            }
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
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .MultiPhoto(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiPhotoCollectionViewCell.identifier, for: indexPath) as? MultiPhotoCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel, id: nil)
            return cell
        case .singleVideo(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleVideoCollectionViewCell.identifier, for: indexPath) as? SingleVideoCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            return cell
        case .fullLengthPoster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fullLengthPosterCollectionViewCell.identifier, for: indexPath) as? fullLengthPosterCollectionViewCell else { fatalError() }
            cell.configure(with: viewModel)
            cell.delegate = self
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //when the user scrolls by check to see if the post has been liked and if it is change the heart to red
        
        if cell.reuseIdentifier == fullLengthActionCollectionViewCell.identifier {
            guard let cell = cell as? fullLengthActionCollectionViewCell else {return}
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
        
        if cell.reuseIdentifier == MultiPhotoCollectionViewCell.identifier {
            guard let cell = cell as? MultiPhotoCollectionViewCell else {return}
            cell.index = indexPath.section
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        //if they scroll to the bottom then paginate for the next posts, but first check what feed they are currently on (most recent, most viewed, or regional), then fill in then update collection view and properties accordingly
        
        guard let collectionHeight = collectionView?.contentSize.height else { return }
        if position > collectionHeight - 100 - scrollView.frame.size.height {
        
            
            guard !DatabaseManager.shared.isPaginating else  {
                print("nope")
                return
                
            }
            
            if isFeedMostViewed {
                guard let lastDoc = self.lastMostViewedDoc else {return}
                DatabaseManager.shared.continueFetchFullLengthsMostViewed(lastDoc: lastDoc, completion: {
                    [weak self] videos, lastDoc in
                    guard let last = lastDoc else {return}
                    self?.lastMostViewedDoc = last
                    
                    
                    let group = DispatchGroup()
                    
                    var newViewModels = [[HomeFeedCellType]]()
                
                    videos.forEach({ video in
                        group.enter()
                        print("sup")
                        
                        guard let thumbnailUrl = URL(string: video.thumbnailString) else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: video.videoUrlString) else {
                            group.leave()
                            return }
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        let vidId = video.videoId
                        
                        DatabaseManager.shared.getTotalViewsForFullLength(for: vidId, completion: {
                            [weak self] views in
                            
                            DatabaseManager.shared.getTotalLikers(for: video.videoId, completion: {
                                [weak self] likers in
                                
                                let isLikedVideo = likers.contains(email)
                                
                                let videoData: [HomeFeedCellType] = [
                                    .fullLengthTitle(viewModel: fullLengthTitleCollectionViewCellViewModel(title: video.videoName)),
                                    .post(viewModel: PostCollectionViewCellViewModel(postUrl: thumbnailUrl, fullLength: video)
                                    ),
                                    .fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: isLikedVideo, videoUrl: videoUrl, viewsCount: views, video: video.videoId, likers: likers, fullVideo: video)),
                                    .fullLengthPoster(viewModel: fullLengthPosterCollectionViewCellViewModel(poster: video.poster, posterEmail: video.posterEmail, region: video.region)),
                                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: video.caption)),
                                    .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: video.postedDateNum, dateString: video.postedDate))
                                ]
                                newViewModels.append(videoData)
                                group.leave()
                                })
                        })
                        })
                    group.notify(queue: .main, execute: {
                        guard let allVids = self?.mostViewedViewModels else {return}
                        self?.mostViewedViewModels = allVids + newViewModels
                        self?.viewModels = allVids + newViewModels
                        self?.collectionView?.reloadData()
                        
                    })
                })
            }
            
            if isFeedMostRecent{
                guard let lastDoc = self.lastMostRecentDoc else {return}
                DatabaseManager.shared.continueFetchingFullLengthsMostRecent(lastDoc: lastDoc, completion: {
                    [weak self] videos, lastDoc in
                    guard let last = lastDoc else {return}
                    self?.lastMostRecentDoc = last
                    
                    
                    let group = DispatchGroup()
                    
                    var newViewModels = [[HomeFeedCellType]]()
                
                    videos.forEach({ video in
                        group.enter()
                        
                        guard let thumbnailUrl = URL(string: video.thumbnailString) else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: video.videoUrlString) else {
                            group.leave()
                            return }
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        let vidId = video.videoId
                        
                        DatabaseManager.shared.getTotalViewsForFullLength(for: vidId, completion: {
                            [weak self] views in
                            
                            DatabaseManager.shared.getTotalLikers(for: video.videoId, completion: {
                                [weak self] likers in
                                
                                let isLikedVideo = likers.contains(email)
                                
                                let videoData: [HomeFeedCellType] = [
                                    .fullLengthTitle(viewModel: fullLengthTitleCollectionViewCellViewModel(title: video.videoName)),
                                    .post(viewModel: PostCollectionViewCellViewModel(postUrl: thumbnailUrl, fullLength: video)
                                    ),
                                    .fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: isLikedVideo, videoUrl: videoUrl, viewsCount: views, video: video.videoId, likers: likers, fullVideo: video)),
                                    .fullLengthPoster(viewModel: fullLengthPosterCollectionViewCellViewModel(poster: video.poster, posterEmail: video.posterEmail, region: video.region)),
                                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: video.caption)),
                                    .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: video.postedDateNum, dateString: video.postedDate))
                                ]
                                newViewModels.append(videoData)
                                group.leave()
                                })
                        })
                        })
                    group.notify(queue: .main, execute: {
                        guard let allVids = self?.mostRecentViewModels else {return}
                        self?.mostRecentViewModels = allVids + newViewModels
                        self?.viewModels = allVids + newViewModels
                        self?.collectionView?.reloadData()
                        
                    })
                })
                
            }
            
            if isFeedLocal {
                guard let lastDoc = self.lastLocalDoc else {return}
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                DatabaseManager.shared.continueFetchFullLengthsForRegion(region: region, lastDoc: lastDoc, completion: {
                    [weak self] videos, lastDoc in
                    guard let last = lastDoc else {return}
                    self?.lastLocalDoc = last
                    
                    
                    let group = DispatchGroup()
                    
                    var newViewModels = [[HomeFeedCellType]]()
                
                    videos.forEach({ video in
                        group.enter()
                        
                        guard let thumbnailUrl = URL(string: video.thumbnailString) else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: video.videoUrlString) else {
                            group.leave()
                            return }
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        let vidId = video.videoId
                        
                        DatabaseManager.shared.getTotalViewsForFullLength(for: vidId, completion: {
                            [weak self] views in
                            
                            DatabaseManager.shared.getTotalLikers(for: video.videoId, completion: {
                                [weak self] likers in
                                
                                let isLikedVideo = likers.contains(email)
                                
                                let videoData: [HomeFeedCellType] = [
                                    .fullLengthTitle(viewModel: fullLengthTitleCollectionViewCellViewModel(title: video.videoName)),
                                    .post(viewModel: PostCollectionViewCellViewModel(postUrl: thumbnailUrl, fullLength: video)
                                    ),
                                    .fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: isLikedVideo, videoUrl: videoUrl, viewsCount: views, video: video.videoId, likers: likers, fullVideo: video)),
                                    .fullLengthPoster(viewModel: fullLengthPosterCollectionViewCellViewModel(poster: video.poster, posterEmail: video.posterEmail, region: video.region)),
                                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: video.caption)),
                                    .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: video.postedDateNum, dateString: video.postedDate))
                                ]
                                newViewModels.append(videoData)
                                group.leave()
                                })
                        })
                        })
                    group.notify(queue: .main, execute: {
                        guard let allVids = self?.localViewModels else {return}
                        self?.localViewModels = allVids + newViewModels
                        self?.viewModels = allVids + newViewModels
                        self?.collectionView?.reloadData()
                        
                    })
                })
                
            }
        }
    }

}

//MARK: video cell delegates

extension SpotLightViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption: String) {
        
        //go to caption detail view controller
        
        let vc = captionDetailViewController(caption: caption)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SpotLightViewController: titleCollectionViewCellDelegate {
    func titleCollectionViewCellDelegateDidTapTitle(_ cell: titleCollectionViewCell) {
        //do nothing
    }
}



extension SpotLightViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, post: FullLength, index: Int) {
        print("does nothing")
    
    }
    
}

extension SpotLightViewController: fullLengthActionCollectionViewCellDelegate {
    
    func fullLengthActionDidTapViews(_ cell: fullLengthActionCollectionViewCell, views: Int, likers: [String]) {
        
        //go to liker view table to view likers and total number of views
        
        let vc = likerTableViewController(likers: likers, likeCount: likers.count)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    func fullLengthActionDidTapPlay(_ cell: fullLengthActionCollectionViewCell, url: URL, video: String) {
        
        //play video on av video player controller

        let player = AVPlayer(url: url)
        let vcPlayer = AVPlayerViewController()
        vcPlayer.player = player
        vcPlayer.player?.playImmediately(atRate: 1.0)
        self.present(vcPlayer, animated: true, completion: nil)
        
        DatabaseManager.shared.incrementFullLengthVideoCount(video: video)
        
    }
    
    func fullLengthActionCollectionViewCellDidTapLike(_ cell: fullLengthActionCollectionViewCell, isLiked: Bool, video: String, index: Int) {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        let actionIndex = IndexPath(row: 2, section: index)
        guard let cell = collectionView?.cellForItem(at: actionIndex) as? fullLengthActionCollectionViewCell else {return}
        
        if isLiked {
            cell.isLiked = !isLiked
            let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .label
            DatabaseManager.shared.removeLikeFromArrayFullLength(for: video, email: currentEmail)
            cell.updateLikeLabel(with: currentEmail)
            let likers = cell.likers
            let views = cell.views
            guard let vid = cell.fullVideo else {return}
            guard let vidurl = cell.url else {return}
            guard let vidname = cell.video else {return}
            
            //update the view model at its index
            
            self.viewModels[index][2] = HomeFeedCellType.fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: false, videoUrl: vidurl, viewsCount: views, video: vidname, likers: likers, fullVideo: vid))
            
        } else {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .systemRed
            cell.isLiked = !isLiked
            DatabaseManager.shared.addLikeToArrayFullLength(for: video, email: currentEmail)
            cell.updateLikeLabel(with: currentEmail)
            let likers = cell.likers
            let views = cell.views
            guard let vid = cell.fullVideo else {return}
            guard let vidurl = cell.url else {return}
            guard let vidname = cell.video else {return}
            
            //update the view model at the index
            
            self.viewModels[index][2] = HomeFeedCellType.fullLengthAction(viewModel: fullLengthActionCellViewModel(isLiked: true, videoUrl: vidurl, viewsCount: views, video: vidname, likers: likers, fullVideo: vid))
            
        }
        
    }
    
    func fullLengthActionCollectionViewDidTapComment(_ cell: fullLengthActionCollectionViewCell, video: FullLength) {
        
        //comment detail view controller
        
        let vc = fullLengthCommentViewController(video: video)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension SpotLightViewController: fullLengthPosterCollectionViewCellDelegate {
    func fullLengthPosterCollectionViewCellDidTapLabel(_ cell: fullLengthPosterCollectionViewCell, username: String, email: String, region: String) {
        
        //go to profile of poster
        
        let vc = ProfileViewController(user: User(username: username, email: email, region: region))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
