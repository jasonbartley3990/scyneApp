//
//  ViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import SafariServices
import JGProgressHUD

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    //MARK: collection view properties
    
    //viewModels is where the collection view gets it data from, when the feed is changed (local posts, following posts, or top regional posts), the viewModels will be set to either localViewModels, followingViewModels or regionViewModels.
    
    private var viewModels = [[HomeFeedCellType]]()
    
    private var localViewModels = [[HomeFeedCellType]]()
    
    private var followingViewModel = [[HomeFeedCellType]]()
    
    private var regionViewModels = [[HomeFeedCellType]]()
    
    private var allPosts = [Post]()
    
    private var collectionView: UICollectionView?
    
    private var didCallFollowing: Bool = false
    
    private var didCallRegion: Bool = false
    
    private var currentFeedLocal = true
    
    private var currentFeedFollowing = false
    
    private var currentFeedSpotlight = false
    
    public var selectedRegion = ""
    
    private var lastDocumentForLocal: DocumentSnapshot?
    
    private var lastDocumentRegion: DocumentSnapshot?
    
    private var AllAds = [[HomeFeedCellType]]()
    
    private var currentIndex = 0
    
    private var isCurrentViewController = false
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var blockUsers: [String] = []
    
    
    let ThreeDaysAgo = Calendar.current.date(
      byAdding: .hour,
      value: -72,
      to: Date())
    
    //MARK: check permission status properties
    
    private var cameraAuthorizationStatus = RequestCameraAuthorizationController.getCameraAuthorizationStatus()
    
    private var MicrophoneAuthorizationStatus = RequestMicrophoneAuthorizationController.getMicrophoneAuthorizationStatus()
    
    
    private var PhotoLibraryAuthorizationStatus = RequestPhotoLiobraryAuthorizationController.getPhotoLibraryAuthorizationStatus()
    
    private var locationAuthorizationStatus =  CLLocationManager.authorizationStatus()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "SCYNE"
        view.backgroundColor = .systemBackground
        
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapAdd))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        let feed = UIBarButtonItem(title: "feed", style: .done, target: self, action: #selector(didTapFeed))
        navigationItem.rightBarButtonItems = [camera, feed, spacer]
        navigationItem.leftBarButtonItems = [search, spacer]
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidPost), name: Notification.Name("didPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(needToUpdate), name: NSNotification.Name("didChangePost"), object: nil)
        
        getAllAds()
        fetchLocalPosts()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top - 5, width: view.width, height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isCurrentViewController = false
        
        //make sure all videos are paused before the view disapears, checks current post in view, previous post, and post in front of it
        
        let videoIndex1 = IndexPath(row: 1, section: currentIndex)
        let videoIndex2 = IndexPath(row: 1, section: currentIndex - 1)
        let videoIndex3 = IndexPath(row:1, section: currentIndex + 1)
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
    
    //MARK: get local posts first and set collection view to display these post, and ads are inserted into list randomly
    
    private func fetchLocalPosts() {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        DatabaseManager.shared.getBlockUsers(email: currentEmail , completion: {
            [weak self] users in
            self?.blockUsers = users
            infoManager.shared.blockUsers = users
        
        self?.viewModels = []
        self?.localViewModels = []

        guard let region = UserDefaults.standard.string(forKey: "region") else {return}
        DatabaseManager.shared.getAllPostsForRegion(region: region, completion: {
            [weak self] posts, lastDoc in
            
            guard !posts.isEmpty else {
                print("whoops")
                return
            }
            let group = DispatchGroup()
            
            guard let last = lastDoc else {return}
            
            self?.lastDocumentForLocal = last
            
            for _ in 1...posts.count {
                group.enter()
            }
            
            for post in posts {
                let postType = post.postType
                
                guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {
                    print("failed in isBlocked")
                    group.leave()
                    return}
                if isBlocked {
                    print("isBlocked")
                    group.leave()
                    continue
                } else {
                    print("not blocked")
                }
                
                
                if postType == "clip" {
                    StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                        
                        guard let profilePic = profilePictureUrl else {
                            group.leave()
                            print("failer with profile photo")
                            return}
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        guard let firstUrl = post.photoUrls.first else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: firstUrl) else {
                            group.leave()
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
                                    self?.localViewModels.append(clipData)
                                
                                let randomNumber = Int.random(in: 0...11)
                                
                                if randomNumber == 7 {
                                    if self?.AllAds.count != 0 {
                                        guard let ad = self?.AllAds.randomElement() else {
                                            group.leave()
                                            return}
                                        self?.viewModels.append(ad)
                                        self?.localViewModels.append(ad)
                                    }
                                }
                                group.leave()
                            })
                        })
                    }
                }
                
                if postType == "gear" {
                    StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                        
                        guard let profilePic = profilePictureUrl else {
                            group.leave()
                            return}
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        let isPostSaved = post.savers.contains(email)
                        
                        guard let askingPrice = post.askingPrice else {
                            group.leave()
                            return}
                    
                    let gearData: [HomeFeedCellType] = [
                        .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "gear", profilePicture: profilePic)
                        ),
                        .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "gear")
                              ),
                        .gearAction(viewModel: gearActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: isPostSaved, post: post)),
                        .title(viewModel: TitleCollectionViewCellViewModel(title: "\(askingPrice)$")),
                        .caption(viewModel: PostCaptionCollectionViewCellModel(caption: post.caption)),
                        .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
                        ]
                        self?.viewModels.append(gearData)
                        self?.localViewModels.append(gearData)
                        
                        let randomNumber = Int.random(in: 0...11)
                        
                        if randomNumber == 7 {
                            if self?.AllAds.count != 0 {
                                guard let ad = self?.AllAds.randomElement() else {
                                    group.leave()
                                    return}
                                self?.viewModels.append(ad)
                                self?.localViewModels.append(ad)
                            }
                        }
                        group.leave()
                    }
                }
                
                if postType == "spot" {
                    guard let email = UserDefaults.standard.string(forKey: "email") else {
                        group.leave()
                        return}
                    
                    let isSpotSaved = post.savers.contains(email)
                    
                    guard let addy = post.address else {
                        group.leave()
                        return}
                    
                    guard let spotName = post.nickname else {
                        group.leave()
                        return}
                    
                    let spotData: [HomeFeedCellType] = [
                        .newSpot(viewModel: SpotHeaderCollectionViewCellModel(isSaved: isSpotSaved, post: post)),
                        .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "spot")
                        ),
                        .spotAction(viewModel: SpotActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: isSpotSaved, post: post)),
                        .title(viewModel: TitleCollectionViewCellViewModel(title: spotName)),
                        .address(viewModel: SpotAddressCollectionViewCellViewModel(address: addy)),
                        .uploader(viewModel: SpotUploaderCollectionViewCellViewModel(uploader: post.posterUsername, email: post.posterEmail, region: post.region))
                    ]
                    self?.viewModels.append(spotData)
                    self?.localViewModels.append(spotData)
                    
                    let randomNumber = Int.random(in: 0...11)
                    
                    if randomNumber == 7 {
                        if self?.AllAds.count != 0 {
                            guard let ad = self?.AllAds.randomElement() else {
                                group.leave()
                                return}
                            self?.viewModels.append(ad)
                            self?.localViewModels.append(ad)
                        }
                        
                    }
                    group.leave()
                }
            
            
                if postType == "normal" {
                    StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                        
                        guard let profilePic = profilePictureUrl else {
                            group.leave()
                            return}
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        DatabaseManager.shared.getTotalLikers(for: post, completion: {
                            [weak self] likers in
                            
                            let isPostLiked = likers.contains(email)
                    
                            let postData: [HomeFeedCellType] = [
                                .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "post", profilePicture: profilePic)),
                                .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "post")),
                                .normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: isPostLiked, likeCount: likers.count, post: post, likers: likers, numberOfPhotos: post.urlCount)),
                                .title(viewModel: TitleCollectionViewCellViewModel(title: post.posterUsername)),
                                .caption(viewModel: PostCaptionCollectionViewCellModel(caption: post.caption)),
                                .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
                            ]
                            self?.viewModels.append(postData)
                            self?.localViewModels.append(postData)
                            
                            let randomNumber = Int.random(in: 0...11)
                            
                            if randomNumber == 7 {
                                if self?.AllAds.count != 0 {
                                    guard let ad = self?.AllAds.randomElement() else {
                                        group.leave()
                                        return}
                                    self?.viewModels.append(ad)
                                    self?.localViewModels.append(ad)
                                }
                                
                            }
                            
                            group.leave()
                        })
                    }
                }
            }
           
            group.notify(queue: .main, execute: {
                self?.collectionView?.reloadData()
            })
            
        })
        })
        
        
    }
    
    //MARK: get ads
    
    func getAllAds() {
        DatabaseManager.shared.grabAllAds(completion: {
            [weak self] ads in
            guard ads.count != 0 else {return}
            
            
            for ad in ads {
                let adType = ad.adType
                
                guard let firstUrl = ad.Urls.first else {return}
                
                guard let vidUrl = URL(string: firstUrl) else {return}
                
                if adType == "video" {
                    let adData: [HomeFeedCellType] = [
                        .advertisementheader(viewModel: advertisementHeaderViewModel(company: ad.company, link: ad.companyLink, photoUrl: ad.companyPhoto)),
                        .singleVideo(viewModel: SingleVideoCollectionViewCellViewModel(url: vidUrl, post: nil, viewers:0, type: "ad")),
                        .AdPageTurner(viewModel: AdvertisementPageTurnerViewModel(urlCount: ad.urlCount)),
                        .title(viewModel: TitleCollectionViewCellViewModel(title: ad.company)),
                        .caption(viewModel: PostCaptionCollectionViewCellModel(caption: ad.caption)),
                        .advertisementLink(viewModel: AdvertisementWebLinkViewModel(link: ad.productLink, linkTitle: ad.productLinkLabel))
                    ]
                    self?.AllAds.append(adData)
                }
                
                if adType == "photo" {
                    let adData: [HomeFeedCellType] = [
                        .advertisementheader(viewModel: advertisementHeaderViewModel(company: ad.company, link: ad.companyLink, photoUrl: ad.companyPhoto)),
                        .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: ad.Urls, post: nil, type: "ad")),
                        .AdPageTurner(viewModel: AdvertisementPageTurnerViewModel(urlCount: ad.urlCount)),
                        .title(viewModel: TitleCollectionViewCellViewModel(title: ad.company)),
                        .caption(viewModel: PostCaptionCollectionViewCellModel(caption: ad.caption)),
                        .advertisementLink(viewModel: AdvertisementWebLinkViewModel(link: ad.productLink, linkTitle: ad.productLinkLabel))
                    ]
                    self?.AllAds.append(adData)
                }
            }
            
        })
        
    }
    
    //MARK: functions to add content
    

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
    
    //MARK: search for users
    
    
    @objc func didTapSearch() {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: if user post
    
    @objc func userDidPost() {
        self.currentFeedLocal = true
        self.currentFeedFollowing = false
        self.currentFeedSpotlight = false
        viewModels.removeAll()
        localViewModels.removeAll()
        collectionView?.reloadData()
        fetchLocalPosts()
    }
    
    //MARK: if a post somewhere around the app was changed need to update data here
    
    @objc func needToUpdate() {
        self.currentFeedLocal = true
        self.currentFeedFollowing = false
        self.currentFeedSpotlight = false
        self.didCallRegion = false
        self.didCallFollowing = false
        self.viewModels.removeAll()
        self.followingViewModel.removeAll()
        self.regionViewModels.removeAll()
        self.localViewModels.removeAll()
        fetchLocalPosts()
    }
    
    //MARK: changing the feed, will check if you have change feed to that before, if you did, then the colection view will display what was already grabbed, if not, then it will make the initial fetch.
    
    
    
    @objc func didTapFeed() {
        let ac = UIAlertController(title: "change feed?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "local", style: .default, handler: { [weak self] _ in
            self?.currentFeedLocal = true
            self?.currentFeedFollowing = false
            self?.currentFeedSpotlight = false
            
            guard let allLocal = self?.localViewModels else {return}
            
            self?.viewModels = allLocal
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
            
        }))
        ac.addAction(UIAlertAction(title: "following", style: .default, handler: { [weak self] _ in
            self?.currentFeedFollowing = true
            self?.currentFeedLocal = false
            self?.currentFeedSpotlight = false
            
            guard let queryDate = self?.ThreeDaysAgo?.timeIntervalSince1970 else {
                print("did returned")
                return}
            self?.getFollowingPosts(date: queryDate)
            
            
        }))
        ac.addAction(UIAlertAction(title: "spotlight", style: .default, handler: { [weak self] _ in
            
            guard let boolean = self?.didCallRegion else {return}
            
            if !boolean {
                let ac = UIAlertController(title: "select a spotlight region", message: " you will view the most viewed clips in that region", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true)
            } else {
                self?.currentFeedFollowing = false
                self?.currentFeedLocal = false
                self?.currentFeedSpotlight = true
                guard let reg = self?.selectedRegion else {return}
                
                self?.getTopPostsForRegion(region: reg)
                
            }
            
        }))
        ac.addAction(UIAlertAction(title: "select spotlight region", style: .default, handler: { [weak self] _ in
            let vc = ChooseRegionWithCompletionViewController()
            vc.completion = { [weak self] selectedReg in
                self?.didCallRegion = true
                self?.selectedRegion = selectedReg
                
                self?.currentFeedFollowing = false
                self?.currentFeedLocal = false
                self?.currentFeedSpotlight = true
                guard let reg = self?.selectedRegion else {return}
                
                self?.getTopPostsForRegion(region: reg)
                
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    //MARK: getting following posts
    
    private func getFollowingPosts(date: Double) {
        
        spinner.show(in: view)
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            spinner.dismiss()
            return}
        
        if !didCallFollowing {
        
        DatabaseManager.shared.followingEmail(for: email, completion: {
            [weak self] users in
            
            guard !users.isEmpty else {
                self?.spinner.dismiss()
                print("returned")
                return
            }
            
            self?.didCallFollowing = true
            
            for user in users {
                DatabaseManager.shared.getClipPostForUserThreeDaysAgo(date: date, email: user, completion: { [weak self] clipPosts in
                    
                    DatabaseManager.shared.getNormalPostForUserThreeDaysAgo(date: date, email: user, completion: { [weak self] NormalPosts in
                        
                        let allPostsFollowingFetched: [Post]  = (NormalPosts + clipPosts)
                      
                        let group = DispatchGroup()
                        
                        var newViewModels = [[HomeFeedCellType]]()
                        
                        for post in allPostsFollowingFetched {
                            group.enter()
                            
                            guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {
                                group.leave()
                                return}
                            if isBlocked {
                                group.leave()
                                return
                            }
                            
                            let postType = post.postType
                            
                            if postType == "clip" {
                                StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                                    
                                    guard let profilePic = profilePictureUrl else {
                                        group.leave()
                                        print("failer with profile photo")
                                        return}
                                    
                                    guard let email = UserDefaults.standard.string(forKey: "email") else {
                                        group.leave()
                                        return}
                                    
                                    guard let firstUrl = post.photoUrls.first else {
                                        group.leave()
                                        return}
                                    
                                    guard let videoUrl = URL(string: firstUrl) else {
                                        group.leave()
                                        return}
                                    
                                    DatabaseManager.shared.getTotalViews(for: post) {
                                        [weak self] views in
                                        
                                        DatabaseManager.shared.getTotalLikers(for: post) {
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
                                            newViewModels.append(clipData)
                                            
                                            let randomNumber = Int.random(in: 0...10)
                                            
                                            if randomNumber == 7 {
                                                if self?.AllAds.count != 0 {
                                                    guard let ad = self?.AllAds.randomElement() else {
                                                        group.leave()
                                                        return}
                                                    newViewModels.append(ad)
                                                }
                                                
                                            }
                                            group.leave()
                                    }
                                    }
                                }
                            }
                            if postType == "normal" {
                                StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                                    
                                    guard let profilePic = profilePictureUrl else {
                                        group.leave()
                                        print("failer with profile photo")
                                        return}
                                    
                                    guard let email = UserDefaults.standard.string(forKey: "email") else {
                                        group.leave()
                                        return}
                                        
                                        DatabaseManager.shared.getTotalLikers(for: post) {
                                            [weak self] likers in
                                            
                                            let isPostLiked = likers.contains(email)
                                            
                                            let postData: [HomeFeedCellType] = [
                                                .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "post", profilePicture: profilePic)
                                                ),
                                                .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "post")
                                                      ),
                                                .normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: isPostLiked, likeCount: likers.count, post: post, likers: likers, numberOfPhotos: post.urlCount)),
                                                .title(viewModel: TitleCollectionViewCellViewModel(title: post.posterUsername)),
                                                .caption(viewModel: PostCaptionCollectionViewCellModel(caption: post.caption)),
                                                .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
                                                ]
                                            newViewModels.append(postData)
                                            
                                            let randomNumber = Int.random(in: 0...10)
                                            
                                            if randomNumber == 7 {
                                                if self?.AllAds.count != 0 {
                                                    guard let ad = self?.AllAds.randomElement() else {
                                                        group.leave()
                                                        return}
                                                    newViewModels.append(ad)
                                                   
                                                }
                                                
                                            }
                                            group.leave()
                                    }
                                    }
                                }
                        }
                        group.notify(queue: .main, execute: {
                            self?.followingViewModel = newViewModels
                            self?.viewModels = newViewModels
                            self?.spinner.dismiss()
                            self?.collectionView?.reloadData()
                        })
                    })
            })
            }
        })
            
        } else {
            spinner.dismiss()
            self.viewModels = self.followingViewModel
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        
        
    }
    
    //MARK: grabbing top posts for region, and checks post to see if the poster is blocked
    
    
    private func getTopPostsForRegion(region: String) {
        spinner.show(in: view)
        DatabaseManager.shared.getMostViewedClipsForRegion(region: region, completion: {
            [weak self] posts, lastDocu in
            
            guard let last = lastDocu else {
                self?.viewModels = []
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                    self?.spinner.dismiss()
                }
                return}
            self?.lastDocumentRegion = last
            
            let group = DispatchGroup()
            
            var newViewModels = [[HomeFeedCellType]]()
            
            if posts.isEmpty {
                self?.viewModels = []
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    self?.collectionView?.reloadData()
                }
            }
            
            for post in posts {
                group.enter()
                let postType = post.postType
                
                guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {
                    group.leave()
                    return}
                if isBlocked {
                    group.leave()
                    return
                }
                
                
                if postType == "clip" {
                    StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                        
                        guard let profilePic = profilePictureUrl else {
                            group.leave()
                            print("failer with profile photo")
                            return}
                        
                        guard let email = UserDefaults.standard.string(forKey: "email") else {
                            group.leave()
                            return}
                        
                        guard let firstUrl = post.photoUrls.first else {
                            group.leave()
                            return}
                        
                        guard let videoUrl = URL(string: firstUrl) else {
                            group.leave()
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
                                newViewModels.append(clipData)
                                let randomNumber = Int.random(in: 0...12)
                                
                                if randomNumber == 7 {
                                    if self?.AllAds.count != 0 {
                                        guard let ad = self?.AllAds.randomElement() else {
                                            group.leave()
                                            return}
                                        newViewModels.append(ad)
                                    }
                                }
                                group.leave()
                            })
                        })
                    }
                }
            
            }
            group.notify(queue: .main, execute: {
                print("are you here")
                
                self?.regionViewModels = newViewModels
                self?.spinner.dismiss()
                self?.viewModels = newViewModels
                self?.collectionView?.reloadData()
               
            })
        })
    }
    
    
    
    
    //MARK: function to block a user
    
    private func blockAUser(email: String, currentEmail: String, index: Int) {
        let ac = UIAlertController(title: "are you sure?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "block", style: .destructive, handler: {
            [weak self] _ in
            DatabaseManager.shared.blockUser(email: email, currentEmail: currentEmail, completion: {
                [weak self] success in
                if success {
                    NotificationCenter.default.post(name: Notification.Name("userDidChangeBlock"), object: nil)
                    let ac = UIAlertController(title: "user blocked", message: "when app refreshes you will no longer see there content", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    self?.present(ac, animated: true)
                }
            })
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
   
    
    //MARK: collection view functions and configuration
    
    
    //MARK: collection view set up
    
    func configureCollectionView() {
        let sectionHeight: CGFloat = 225 + view.width
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {
            index, _ -> NSCollectionLayoutSection? in
            
            //item
            let posterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
            )
            
            let postItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
            
            let actionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(35)))
            
            let titleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)))
            
            let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)))
            
            let timeStampItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)))
            
            //group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(sectionHeight)), subitems: [posterItem, postItem, actionItem, titleItem, captionItem, timeStampItem]
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
        collectionView.register(SpotHeaderCollectionViewCell.self, forCellWithReuseIdentifier: SpotHeaderCollectionViewCell.identifier)
        collectionView.register(SpotAddressCollectionViewCell.self, forCellWithReuseIdentifier: SpotAddressCollectionViewCell.identifier)
        collectionView.register(SpotActionsCollectionViewCell.self, forCellWithReuseIdentifier: SpotActionsCollectionViewCell.identifier)
        collectionView.register(SpotActionsCollectionViewCell.self, forCellWithReuseIdentifier: SpotActionsCollectionViewCell.identifier)
        collectionView.register(SpotUploaderCollectionViewCell.self, forCellWithReuseIdentifier: SpotUploaderCollectionViewCell.identifier)
        collectionView.register(GearActionsCollectionViewCell.self, forCellWithReuseIdentifier: GearActionsCollectionViewCell.identifier)
        collectionView.register(titleCollectionViewCell.self, forCellWithReuseIdentifier: titleCollectionViewCell.identifier)
        collectionView.register(MultiPhotoCollectionViewCell.self, forCellWithReuseIdentifier: MultiPhotoCollectionViewCell.identifier)
        collectionView.register(SingleVideoCollectionViewCell.self, forCellWithReuseIdentifier: SingleVideoCollectionViewCell.identifier)
        collectionView.register(NormalPostActionsCollectionViewCell.self, forCellWithReuseIdentifier: NormalPostActionsCollectionViewCell.identifier)
        collectionView.register(pageTurnerCollectionViewCell.self, forCellWithReuseIdentifier: pageTurnerCollectionViewCell.identifier)
        collectionView.register(AdvertisementHeaderCollectionViewCell.self, forCellWithReuseIdentifier: AdvertisementHeaderCollectionViewCell.identifier)
        collectionView.register(AdvertisementWebLinkCollectionViewCell.self, forCellWithReuseIdentifier: AdvertisementWebLinkCollectionViewCell.identifier)
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
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .spotAction(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotActionsCollectionViewCell.identifier, for: indexPath) as? SpotActionsCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
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
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .uploader(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotUploaderCollectionViewCell.identifier, for: indexPath) as? SpotUploaderCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
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
            cell.configure(with: viewModel)
            cell.delegate = self
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
            cell.delegate = self
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
        return viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //if a video pause leaves the view then pause it
        
        if cell.reuseIdentifier == SingleVideoCollectionViewCell.identifier {
            guard let cell = cell as? SingleVideoCollectionViewCell else {return}
            print("video paused bitch")
            cell.pauseVideo()
            cell.stopTimer()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        

        
        if cell.reuseIdentifier == SingleVideoCollectionViewCell.identifier {
            guard let cell = cell as? SingleVideoCollectionViewCell else {return}
            print("video will play")
            
            //plays video if it came into view, and pauses the video leaving the view, and post ahead of it
            
            currentIndex = indexPath.section
            cell.index = indexPath.section
            if isCurrentViewController {
                DispatchQueue.main.async {
                    cell.playVideo()
                }
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

        }
        
        if cell.reuseIdentifier == PostActionCollectionViewCell.identifier {
            guard let cell = cell as? PostActionCollectionViewCell else {return}
            cell.index = indexPath.section
            
            //checks if the post has been liked by current user
            
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
        
        if cell.reuseIdentifier == NormalPostActionsCollectionViewCell.identifier {
            guard let cell = cell as? NormalPostActionsCollectionViewCell else { return }
            
            //checks if the current user has liked the post uploaded
            
            cell.index = indexPath.section
            
            if !cell.isLiked {
                let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .label
                
            } else {
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .systemRed
                cell.likesLabel.text = "\(cell.likeCount) likes"
                
            }
            
            
        }
        
        if cell.reuseIdentifier == SpotActionsCollectionViewCell.identifier {
            guard let cell = cell as? SpotActionsCollectionViewCell else {return}
            cell.index = indexPath.section
            
            //checks if the post has been saved by user
           
            
            guard let saved = cell.isSaved else {return}
            if saved {
                cell.saveLabel.text = "saved"
                cell.saveLabel.textColor = .systemGreen
                
            } else {
                cell.saveLabel.text = "save"
                cell.saveLabel.textColor = .label
            }
        }
        
        if cell.reuseIdentifier == GearActionsCollectionViewCell.identifier {
            guard let cell = cell as? GearActionsCollectionViewCell else {return}
            cell.index = indexPath.section
            
            //checks if the post is saved by the current user
            
            guard let saved = cell.isSaved else {return}
            if saved {
                cell.saveLabel.text = "saved"
                cell.saveLabel.textColor = .systemGreen
            } else {
                cell.saveLabel.text = "save"
                cell.saveLabel.textColor = .label
            }
            
            
        }
        
        if cell.reuseIdentifier == MultiPhotoCollectionViewCell.identifier {
            guard let cell = cell as? MultiPhotoCollectionViewCell else {return}
            cell.index = indexPath.section
            print(indexPath)
            
            //sets a post "post type" property
            
            let actionCell = viewModels[indexPath.section][2]
            switch actionCell {
            
            case .poster(_):
                break
            case .post(_):
                break
            case .postActions(_):
                break
            case .caption(_):
                break
            case .timeStamp(_):
                break
            case .newSpot(_):
                break
            case .spotAction(_):
                cell.type = "spot"
            case .address(_):
                break
            case .uploader(_):
                break
            case .gearAction(_):
                cell.type = "gear"
            case .title(_):
                break
            case .fullLengthAction(_):
                break
            case .MultiPhoto(_):
                break
            case .singleVideo(_):
                break
            case .fullLengthPoster(_):
                break
            case .fullLengthTitle(_):
                break
            case .normalPostAction(_):
                cell.type = "post"
            case .advertisementLink(_):
                break
            case .advertisementheader(_):
                break
            case .AdPageTurner(_):
                cell.type = "ad"
            }
            
            
            
        }
        
        if cell.reuseIdentifier == PosterCollectionViewCell.identifier {
            guard let cell = cell as? PosterCollectionViewCell else {return}
            cell.index = indexPath.section
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //when user gets to bottom of scroll view, then it first checks what feed the current user in, the paginates accordingly for feed and displays those post on the feed
        
        
        let position = scrollView.contentOffset.y
        guard let collectionHeight = collectionView?.contentSize.height else { return }
        if position > collectionHeight - 100 - scrollView.frame.size.height {
        
            
            guard !DatabaseManager.shared.isPaginating else  {
                return
            }
            
            
            if currentFeedLocal {
                guard let lastDoc = self.lastDocumentForLocal else {return}
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                
                DatabaseManager.shared.continueAllPostForRegion(region: region, lastDoc: lastDoc, completion: {
                    [weak self] posts, lastDocu in
                    
                   
                    
                    guard let last = lastDocu else {return}
                    self?.lastDocumentForLocal = last
                    
                    let group = DispatchGroup()
                    
                    var newViewModels = [[HomeFeedCellType]]()
                    
                    for post in posts {
                        group.enter()
                        let postType = post.postType
                        
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {
                            group.leave()
                            return}
                        if isBlocked {
                            group.leave()
                            return
                        }
                        
                        if postType == "clip" {
                            StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                                
                                guard let profilePic = profilePictureUrl else {
                                    group.leave()
                                    print("failer with profile photo")
                                    return}
                                
                                guard let email = UserDefaults.standard.string(forKey: "email") else {
                                    group.leave()
                                    return}
                                
                                guard let firstUrl = post.photoUrls.first else {
                                    group.leave()
                                    return}
                                
                                guard let videoUrl = URL(string: firstUrl) else {
                                    group.leave()
                                    return}
                                
                                DatabaseManager.shared.getTotalViews(for: post, completion: {
                                    [weak self]views in
                                    
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
                                        newViewModels.append(clipData)
                                        
                                        let randomNumber = Int.random(in: 0...11)
                                        
                                        if randomNumber == 7 {
                                            if self?.AllAds.count != 0 {
                                                guard let ad = self?.AllAds.randomElement() else {
                                                    group.leave()
                                                    return}
                                                newViewModels.append(ad)
                                            }
                                        }
                                        
                                        
                                        group.leave()
                                    
                            
                                })
                                })
                            }
                        }
                        
                        if postType == "gear" {
                            StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                                
                                guard let profilePic = profilePictureUrl else {
                                    group.leave()
                                    return}
                                
                                guard let email = UserDefaults.standard.string(forKey: "email") else {
                                    group.leave()
                                    return}
                                
                                let isPostSaved = post.savers.contains(email)
                                
                                guard let askingPrice = post.askingPrice else {
                                    group.leave()
                                    return}
                                
                                
                            
                            let gearData: [HomeFeedCellType] = [
                                .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "gear", profilePicture: profilePic)
                                ),
                                .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "gear")
                                      ),
                                .gearAction(viewModel: gearActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: isPostSaved, post: post)),
                                .title(viewModel: TitleCollectionViewCellViewModel(title: "\(askingPrice)$")),
                                .caption(viewModel: PostCaptionCollectionViewCellModel(caption: post.caption)),
                                .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
                                ]
                                newViewModels.append(gearData)
                                
                                let randomNumber = Int.random(in: 0...11)
                                
                                if randomNumber == 7 {
                                    if self?.AllAds.count != 0 {
                                        guard let ad = self?.AllAds.randomElement() else {
                                            group.leave()
                                            return}
                                        newViewModels.append(ad)
                                    }
                                }
                                
                                group.leave()
                            }
                        }
                        
                        if postType == "spot" {
                            guard let email = UserDefaults.standard.string(forKey: "email") else {
                                group.leave()
                                return}
                            
                            let isSpotSaved = post.savers.contains(email)
                            
                            guard let addy = post.address else {
                                group.leave()
                                return}
                            
                            guard let spotName = post.nickname else {
                                group.leave()
                                return}
                            
                            
                            let spotData: [HomeFeedCellType] = [
                                .newSpot(viewModel: SpotHeaderCollectionViewCellModel(isSaved: isSpotSaved, post: post)),
                                .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "spot")
                                ),
                                .spotAction(viewModel: SpotActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: isSpotSaved, post: post)),
                                .title(viewModel: TitleCollectionViewCellViewModel(title: spotName)),
                                .address(viewModel: SpotAddressCollectionViewCellViewModel(address: addy)),
                                .uploader(viewModel: SpotUploaderCollectionViewCellViewModel(uploader: post.posterUsername, email: post.posterEmail, region: post.region))
                            ]
                            newViewModels.append(spotData)
                            
                            let randomNumber = Int.random(in: 0...11)
                            
                            if randomNumber == 7 {
                                if self?.AllAds.count != 0 {
                                    guard let ad = self?.AllAds.randomElement() else {
                                        group.leave()
                                        return}
                                    newViewModels.append(ad)
                                }
                            }
                            
                            
                            group.leave()
                        }
                    
                    
                        if postType == "normal" {
                            StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                                
                                guard let profilePic = profilePictureUrl else {
                                    group.leave()
                                    return}
                                
                                guard let email = UserDefaults.standard.string(forKey: "email") else {
                                    group.leave()
                                    return}
                                
                                DatabaseManager.shared.getTotalLikers(for: post, completion: {
                                    [weak self] likers in
                                    
                                    let isPostLiked = likers.contains(email)
                                    
                            
                                    let postData: [HomeFeedCellType] = [
                                        .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "post", profilePicture: profilePic)),
                                        .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "post")),
                                        .normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: isPostLiked, likeCount: likers.count, post: post, likers: likers, numberOfPhotos: post.urlCount)),
                                        .title(viewModel: TitleCollectionViewCellViewModel(title: post.posterUsername)),
                                        .caption(viewModel: PostCaptionCollectionViewCellModel(caption: post.caption)),
                                        .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
                                    ]
                                    newViewModels.append(postData)
                                    
                                    let randomNumber = Int.random(in: 0...11)
                                    
                                    if randomNumber == 7 {
                                        if self?.AllAds.count != 0 {
                                            guard let ad = self?.AllAds.randomElement() else {
                                                group.leave()
                                                return}
                                            newViewModels.append(ad)
                                        }
                                    }
                                    group.leave()
                                })
                            }
                        }
                    }
                   
                    group.notify(queue: .main, execute: {
                        guard let alreadyFetchedLocal = self?.localViewModels else {return}
                        self?.localViewModels = alreadyFetchedLocal + newViewModels
                        print("count")
                        print(alreadyFetchedLocal.count)
                        print(newViewModels.count)
                        self?.viewModels = alreadyFetchedLocal + newViewModels
                        self?.collectionView?.reloadData()
                       
                    })
                    
                })
                
            }
            
            if currentFeedSpotlight {
                guard let lastDoc = self.lastDocumentRegion else {return}
                DatabaseManager.shared.continueGetMostViewedClipsForRegion(region: selectedRegion, lastDoc: lastDoc, completion: {
                    [weak self] posts, lastDocu in
                    
                    guard let last = lastDocu else {return}
                    self?.lastDocumentForLocal = last
                    
                    let group = DispatchGroup()
                    
                    var newViewModels = [[HomeFeedCellType]]()
                    
                    for post in posts {
                        group.enter()
                        let postType = post.postType
                        
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {
                            group.leave()
                            return}
                        if isBlocked {
                            group.leave()
                            return
                        }
                        
                        if postType == "clip" {
                            StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
                                
                                guard let profilePic = profilePictureUrl else {
                                    group.leave()
                                    print("failer with profile photo")
                                    return}
                                
                                guard let email = UserDefaults.standard.string(forKey: "email") else {
                                    group.leave()
                                    return}
                                
                                guard let firstUrl = post.photoUrls.first else {
                                    group.leave()
                                    return}
                                
                                guard let videoUrl = URL(string: firstUrl) else {
                                    group.leave()
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
                                        newViewModels.append(clipData)
                                        
                                        let randomNumber = Int.random(in: 0...11)
                                        
                                        if randomNumber == 7 {
                                            if self?.AllAds.count != 0 {
                                                guard let ad = self?.AllAds.randomElement() else {
                                                    group.leave()
                                                    return}
                                                newViewModels.append(ad)
                                            }
                                        }
                                        
                                        
                                        group.leave()
                                    })
                                })
                            }
                        }
                    
                    }
                    group.notify(queue: .main, execute: {
                        guard let alreadyFetchedRegion = self?.regionViewModels else {return}
                        self?.regionViewModels = alreadyFetchedRegion + newViewModels
                        self?.viewModels = alreadyFetchedRegion + newViewModels
                        self?.collectionView?.reloadData()
                        
                    })
                    
                })
               
                
            }
            
        }
    }
            
           
        
    
}


//MARK: spot actions extension

extension HomeViewController: SpotActionsCollectionViewCellDelegate {
    func spotActionsCollectionViewCellDDidTapPin(_ cell: SpotActionsCollectionViewCell, post: Post) {
        
        //shows location of the post
        
        let vc = SinglePinViewController(spot: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func spotActionCollectionViewCellDidTapVideo(_ cell: SpotActionsCollectionViewCell, post: Post) {
        
        //shows spot detail view controller
        
        guard let ind = cell.index else {return}
        
        guard let addy = post.address else {return}
        guard let type = post.spotType else {return}
        guard let nickname = post.nickname else {return}
        guard let latitude = post.latitude else {return}
        guard let longitude = post.longitude else {return}
        guard let spotId = post.spotId else {return}
        guard let info = post.caption else {return}
        guard let saveStatus = cell.isSaved else {return}
        
        let spot = SpotModel(location: addy, spotPhotoUrl: post.photoUrls, spotType: type, nickName: nickname, postedBy: post.posterUsername, latitude: latitude, longitude: longitude, spotId: spotId, savers: post.savers, spotInfo: info, isSaved: saveStatus)
        let vc = SpotDetailViewController(spot: spot, post: post)
        vc.completion = { [weak self] bool in
            if bool == true {
                guard let boo = cell.isSaved else {return}
                cell.isSaved = !boo
                if boo == true {
                    cell.saveLabel.text = "save"
                    cell.saveLabel.textColor = .label
                    self?.viewModels[ind][2] = HomeFeedCellType.spotAction(viewModel: SpotActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: false, post: post))
                } else {
                    cell.saveLabel.text = "saved"
                    cell.saveLabel.textColor = .systemGreen
                    self?.viewModels[ind][2] = HomeFeedCellType.spotAction(viewModel: SpotActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: true, post: post))
                    
                }
            }
          
            }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func spotActionsCollectionViewCellDidTapSaveSpot(_ cell: SpotActionsCollectionViewCell, isSaved: Bool, post: Post) {
        
        //updates save on a post
        
        print("tapped saved")
        spinner.show(in: view)
        DatabaseManager.shared.updateSpotSaved(state: isSaved ? .save : .unSaved, postId: post.postId, completion: {
            [weak self] success in
            if success {
                if isSaved {
                    DispatchQueue.main.async {
                        cell.saveLabel.text = "saved"
                        cell.saveLabel.textColor = .systemGreen
                    }
                    cell.isSaved = true
                    guard let index = cell.index else {return}
                    self?.viewModels[index][2] = HomeFeedCellType.spotAction(viewModel: SpotActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: isSaved, post: post))
                    self?.spinner.dismiss()
                } else {
                    DispatchQueue.main.async {
                        cell.saveLabel.text = "save"
                        cell.saveLabel.textColor = .label
                    }
                    cell.isSaved = false
                    guard let index = cell.index else {return}
                    self?.viewModels[index][2] = HomeFeedCellType.spotAction(viewModel: SpotActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: isSaved, post: post))
                    self?.spinner.dismiss()
                }
                print("saved")
            } else {
                print("not saved")
                self?.spinner.dismiss()
            }
            
        })
        
    }
    
    func spotActionsCollectionViewCellDidTapComment(_ cell: SpotActionsCollectionViewCell, post: Post) {
        
        //shows comment view controller with all the comments
        
        print("tapped comment")
        let vc = commentViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension HomeViewController: SpotHeaderCollectionViewDelegate {
    
    //lets a user report a post or block a user
    
    func SpotHeaderCollectionViewDelegateDidTapMore(_ cell: SpotHeaderCollectionViewCell, post: Post) {
        print("tapped more")
        let sheet = UIAlertController(title: "post action", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "report post", style: .destructive, handler: {
            [weak self] _ in
            DatabaseManager.shared.reportPost(post: post, completion: {
                success in
                let ac = UIAlertController(title: "post reported", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                DispatchQueue.main.async {
                    self?.present(ac,animated: true)
                }
                
            })
            
        }))
        present(sheet, animated: true)
        
    }
}

extension HomeViewController: SpotUploaderCollectionViewCellDelegate {
    func SpotUploaderCollectionViewCellDelegateDidTapPoster(_ cell: SpotUploaderCollectionViewCell, username: String, email: String, region: String) {
        
        //goes to the posters profile
        
        let vc = ProfileViewController(user: User(username: username, email: email, region: region))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


//MARK: gear extensions
    
extension HomeViewController: GearActionsCollectionViewCellDelegate {
    func GearActionsCollectionViewCellDidTapSaveButton(_ cell: GearActionsCollectionViewCell, isSaved: Bool, post: Post) {
        
        //update save on a post
        
        print("tapped saved")
        spinner.show(in: view)
        DatabaseManager.shared.updateItemSaved(state: isSaved ? .save : .unSaved, itemId: post.postId, completion: {
            [weak self] success in
            guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
            
            if success {
                if isSaved {
                    DispatchQueue.main.async {
                        cell.saveLabel.text = "saved"
                        cell.saveLabel.textColor = .systemGreen
                    }
                    cell.isSaved = true
                    guard let index = cell.index else {return}
                    cell.updateSaveLabel(with: currentEmail)
                    self?.viewModels[index][2] = HomeFeedCellType.gearAction(viewModel: gearActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: true, post: post))
                    self?.spinner.dismiss()
                    
                } else {
                    DispatchQueue.main.async {
                        cell.saveLabel.text = "save"
                        cell.saveLabel.textColor = .label
                    }
                    cell.isSaved = false
                    guard let index = cell.index else {return}
                    cell.updateSaveLabel(with: currentEmail)
                    self?.viewModels[index][2] = HomeFeedCellType.gearAction(viewModel: gearActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: false, post: post))
                    self?.spinner.dismiss()
                }
                print("saved")
            } else {
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                print("not saved")
            }
        })
        
    }
    
    func GearActionsCollectionViewCellDidTapMessageButton(_ cell: GearActionsCollectionViewCell, post: Post) {
        
        //checks if the user has had a conversation with the poster before and then shows a chat view controller
        
        print("message tapped")
        guard let email1 = UserDefaults.standard.string(forKey: "email") else {return}
        let email2 = post.posterEmail
        
        if email1 == email2 {
            print("same person")
            return
        }

        DatabaseManager.shared.checkIfConversationExistsInDatabase(email1: email1, email2: email2, completion: {
            [weak self] result in

            guard let convoId = result else {
                let vc = ChatViewController(with: post.posterUsername, email: email2, id: nil)
                vc.title = post.posterUsername
                vc.isNewConversation = true
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }

            let vc = ChatViewController(with: post.posterUsername, email: post.posterEmail, id: convoId)
            self?.navigationController?.pushViewController(vc, animated: true)

        })
    }
}

//MARK: post action extensions

extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption:String) {
        
        //goes to caption view controller
        
        let vc = captionDetailViewController(caption: caption)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: PostActionCollectionViewCellDelegate {
    
    func postActionsCollectionViewCellDidTapPin(_ cell: PostActionCollectionViewCell, post: Post) {
        
        //goes to location of post
        
        print("tapped")
        guard let spotId = post.spotId else {
            return
        }
        if spotId != "" {
            DatabaseManager.shared.grabASpot(with: spotId, completion: {
                [weak self] spot in
                guard spot.count != 0 else {return}
                let theSpot = spot[0]
                let vc = SinglePinViewController(spot: theSpot)
                self?.navigationController?.pushViewController(vc, animated: true)
                
            })
            
            
        } else {
            let ac = UIAlertController(title: "no spot info attached", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel))
            present(ac, animated: true)
        }
        
    }
    
    func postActionsCollectionViewCellDidTapViewers(_ cell: PostActionCollectionViewCell, likers: [String], likeCount: Int) {
        
        // goes to liker view controller to show likers
        
        let vc = likerTableViewController(likers: likers, likeCount: likeCount)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionCollectionViewCell, isLiked: Bool, post: Post, index: Int) {
        
        //likes a post and updates the data on the post
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        let actionIndex = IndexPath(row: 2, section: index)
        guard let cell = collectionView?.cellForItem(at: actionIndex) as? PostActionCollectionViewCell else {return}
        
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
            
            //update view model
            
            self.viewModels[index][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false, likeCount: count, viewCount: views, post: post, likers: likers))
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
            
            //update view model
            
            self.viewModels[index][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true, likeCount: count, viewCount: views, post: post, likers: likers))
        }
        
        
        
        
        
        
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionCollectionViewCell, post: Post) {
        
        //goes to comment view controller for post
        
        let vc = commentViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionCollectionViewCell) {
        let vc = UIActivityViewController(activityItems: ["shared from instagram"], applicationActivities: [])
        present(vc, animated: true)
        
    }
    
    
}

extension HomeViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, post: Post, type: String, index: Int) {
        print("tapped more")
        
        //if is current user ask them if they want to delete a post, if not current user ask them if they want to block or report a post
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        if currentEmail == post.posterEmail {
            let sheet = UIAlertController(title: "post action", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
            sheet.addAction(UIAlertAction(title: "delete post", style: .default, handler: {
                [weak self] _ in
                    let ac = UIAlertController(title: "are you sure?", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "delete", style: .default, handler: { [weak self] _ in
                        let postId = post.postId
                        DatabaseManager.shared.deleteClipOrNormalPost(postId: postId, completion: {
                            [weak self] success in
                            if success {
                               // self?.completion?()
                                self?.viewModels.remove(at: index)
                                DispatchQueue.main.async {
                                    self?.collectionView?.reloadData()
                                }
                                
                                
                            }
                        })
                    }))
                    ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
                    self?.present(ac, animated: true)
            }))
            present(sheet, animated: true)
            
        } else {
            let sheet = UIAlertController(title: "post action", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
            sheet.addAction(UIAlertAction(title: "block user", style: .default, handler: {
                [weak self] _ in
                guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
                self?.blockAUser(email: post.posterEmail, currentEmail: currentEmail, index: index)
            }))
            sheet.addAction(UIAlertAction(title: "report post", style: .destructive, handler: {
                [weak self] _ in
                DatabaseManager.shared.reportPost(post: post, completion: {
                    [weak self] success in
                    let ac = UIAlertController(title: "post reported", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                    DispatchQueue.main.async {
                        self?.present(ac,animated: true)
                    }
                })
            }))
            
            present(sheet, animated: true)
        }
        
        
    }
    
    func posterCollectionViewCellDidUsername(_ cell: PosterCollectionViewCell, email: String, username: String, region: String) {
        
        //goes to poster profile
        
        let vc = ProfileViewController(user: User(username: username, email: email, region: region))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension HomeViewController: titleCollectionViewCellDelegate {
    func titleCollectionViewCellDelegateDidTapTitle(_ cell: titleCollectionViewCell) {
        //does nothing
    }
    

}

//MARK: multi image view delegate

extension HomeViewController: MultiImageViewDelegate {
    func MultiImageViewDelegateDidDoubleTap(_ cell: MultiPhotoCollectionViewCell, post: Post, index: Int, type: String) {
        
        //update like data
        
        if type == "post" {
            guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
            
            let actionIndex = IndexPath(row: 2, section: index)
            guard let cell = collectionView?.cellForItem(at: actionIndex) as? NormalPostActionsCollectionViewCell else {return}
            
            if cell.isLiked {
                cell.isLiked = false
                let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .label
                DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
                cell.updateNormalLikeLabel(with: currentEmail)
                let likers = cell.likers
                let count = cell.likeCount
                
                //update view model at the index
                
                self.viewModels[index][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: false, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
            } else {
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .systemRed
                cell.isLiked = true
                DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
                cell.updateNormalLikeLabel(with: currentEmail)
                let likers = cell.likers
                let count = cell.likeCount
                
                //update view model at the index
                
                self.viewModels[index][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: true, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
                
            }
        
        
        }
        
        
        
    }
    
    func MultiImageViewDelegateDidScroll(_ cell: MultiPhotoCollectionViewCell, page: Int, index: Int, type: String) {
        
        print(cell.type)
        
        if cell.type == "spot" {
            let actionIndex = IndexPath(row: 2, section: index)
            guard let actionCell = collectionView?.cellForItem(at: actionIndex) as? SpotActionsCollectionViewCell else {return}
            print(actionCell)
            actionCell.pageTurner.currentPage = page
            
        }
        
        if cell.type == "post" {
            let actionIndex = IndexPath(row: 2, section: index)
            guard let actionCell = collectionView?.cellForItem(at: actionIndex) as? NormalPostActionsCollectionViewCell else {return}
            actionCell.pageTurner.currentPage = page
            
        }
        
        if cell.type == "ad" {
            let pageIndex = IndexPath(row: 2, section: index)
            guard let pageCell = collectionView?.cellForItem(at: pageIndex) as? pageTurnerCollectionViewCell else {return}
            pageCell.pageTurner.currentPage = page
            
        }
        
        if cell.type == "gear" {
            let actionIndex = IndexPath(row: 2, section: index)
            guard let actionCell = collectionView?.cellForItem(at: actionIndex) as? GearActionsCollectionViewCell else {return}
            actionCell.pageTurner.currentPage = page
            
        }
        
    }
    
    
    
    
}

//MARK: normal post delegate

extension HomeViewController: normalPostActionCollectionViewCellDelegate {
    func normalPostActionsCollectionViewCellDidTapLike(_ cell: NormalPostActionsCollectionViewCell, isLiked: Bool, post: Post, index: Int) {
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        //update like data
        
        if isLiked {
            cell.isLiked = !isLiked
            let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .label
            DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
            cell.updateNormalLikeLabel(with: currentEmail)
            let likers = cell.likers
            let count = cell.likeCount
            
            //update view model
            
            self.viewModels[index][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: false, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
        } else {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .systemRed
            cell.isLiked = !isLiked
            DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
            cell.updateNormalLikeLabel(with: currentEmail)
            let likers = cell.likers
            let count = cell.likeCount
            
            //update view model
            
            self.viewModels[index][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: true, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
        }
        
        
    }
    
    func normalPostActionsCollectionViewCellDidTapComment(_ cell: NormalPostActionsCollectionViewCell, post: Post) {
        
        //go to comments for the post
        
        let vc = commentViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapLikers(_ cell: NormalPostActionsCollectionViewCell, likers: [String], likeCount: Int) {
        
        //goes to liker view controller
        
        let vc = likerTableViewController(likers: likers, likeCount: likeCount)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}

//MARK: advertisements extensions

extension HomeViewController: AdvertisementWebLinkCollectionViewCellDelegate {
    func AdvertisementDidTapLink(_ cell: AdvertisementWebLinkCollectionViewCell, link: String) {
        
        //opens up link
        
        let result = urlOpener.shared.verifyUrl(urlString: link)
        if result == true {
            if let url = URL(string: link) {
                let vc = SFSafariViewController(url: url)
               present(vc, animated: true)
            }
        } else {
            print("cant opemn url")
            let ac = UIAlertController(title: "invalid url", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            present(ac, animated: true)
        }
        
    }
    
    
}

extension HomeViewController: AdvertisementHeaderDelegate {
    func advertisementheaderDidTapMore(_ cell: AdvertisementHeaderCollectionViewCell, link: String) {
        
        //takes user to the advertiser website
        
        let ac = UIAlertController(title: "actions", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "visit their website", style: .default, handler: {
            [weak self] _ in
            if let url = URL(string: link) {
                let safariVC = SFSafariViewController(url: url)
                self?.present(safariVC, animated: true)
            }
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }

    
}

extension HomeViewController: SingleVideoCollectionViewCellDelegate {
    
    func SingleVideoCollectionViewCellDidDoubleTap(_ cell: SingleVideoCollectionViewCell, index: Int, post: Post, viewers: Int, type: String) {
        
        //updates like data
        
        if type == "clip" {
            guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
            
            let actionIndex = IndexPath(row: 2, section: index)
            
            guard let cell = collectionView?.cellForItem(at: actionIndex) as? PostActionCollectionViewCell else { return }
            
            if cell.isLiked {
                cell.isLiked = !cell.isLiked
                let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .label
                DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
                cell.updateLikeLabel(with: currentEmail)
                let likers = cell.likers
                
                //update view model
                
                self.viewModels[index][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false, likeCount: likers.count, viewCount: cell.viewers, post: post, likers: likers))
               
                
            } else {
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.tintColor = .systemRed
                cell.isLiked = !cell.isLiked
                DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
                cell.updateLikeLabel(with: currentEmail)
                let likers = cell.likers
                
                //update view model
                
                self.viewModels[index][2] = HomeFeedCellType.postActions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true, likeCount: likers.count, viewCount: cell.viewers, post: post, likers: likers))
                
            }
        }
        
    }
    
}



