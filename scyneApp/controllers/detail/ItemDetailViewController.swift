//
//  ItemDetailViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/9/21.
//

import UIKit
import JGProgressHUD

class ItemDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var viewModels = [[HomeFeedCellType]]()
    
    private var isSaved: Bool = false
    
    private var post: Post
    
    private var collectionView: UICollectionView?
    
    public var completion: ((Bool) -> Void)?
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
                print(success)
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView?.reloadData()
                }
            } else {
                print("something went wrong")
            }
            
            
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func blockAUser(email: String, currentEmail: String) {
        let ac = UIAlertController(title: "are you sure?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "block", style: .destructive, handler: {
            [weak self] _ in
            DatabaseManager.shared.blockUser(email: email, currentEmail: currentEmail, completion: {
                [weak self] success in
                if success {
                    NotificationCenter.default.post(name: Notification.Name("userDidChangeBlock"), object: nil)
                    let ac = UIAlertController(title: "user blocked", message: "when app refreshes you will no longer see there content", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    DispatchQueue.main.async {
                        self?.present(ac, animated: true)
                    }
                }
            })
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    func configureCollectionView() {
        let sectionHeight: CGFloat = 260 + view.width
        
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
        collectionView.register(GearActionsCollectionViewCell.self, forCellWithReuseIdentifier: GearActionsCollectionViewCell.identifier)
        collectionView.register(titleCollectionViewCell.self, forCellWithReuseIdentifier: titleCollectionViewCell.identifier)
        collectionView.register(MultiPhotoCollectionViewCell.self, forCellWithReuseIdentifier: MultiPhotoCollectionViewCell.identifier)
        collectionView.register(SingleVideoCollectionViewCell.self, forCellWithReuseIdentifier: SingleVideoCollectionViewCell.identifier)
        collectionView.register(pageTurnerCollectionViewCell.self, forCellWithReuseIdentifier: pageTurnerCollectionViewCell.identifier)
        collectionView.register(AdvertisementHeaderCollectionViewCell.self, forCellWithReuseIdentifier: AdvertisementHeaderCollectionViewCell.identifier)
        collectionView.register(AdvertisementWebLinkCollectionViewCell.self, forCellWithReuseIdentifier: AdvertisementWebLinkCollectionViewCell.identifier)
        self.collectionView = collectionView
    }
    
    
    public func createViewModel(post: Post, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {
            completion(false)
            return
            
        }
        
        StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
            guard let profilePhotoUrl = profilePictureUrl else {
                    print("failed to get urls")
                completion(false)
                    return
                }
            
            let isSavedData = post.savers.contains(currentEmail)
            print(isSavedData)
            self?.isSaved = isSavedData
            guard let askingPrice = post.askingPrice else {return}
            
            
            guard let description = post.caption else {return}
        
            let postData: [HomeFeedCellType] = [
                .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "gear", profilePicture: profilePhotoUrl)
                ),
                .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "gear")
                      ),
                .gearAction(viewModel: gearActionsCollectionViewCellViewModel(photoCount: post.urlCount, isSaved: isSavedData, post: post)),
                .title(viewModel: TitleCollectionViewCellViewModel(title: "\(askingPrice) $")),
                .caption(viewModel: PostCaptionCollectionViewCellModel(caption: description)),
                .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
            ]
            self?.viewModels.append(postData)
            completion(true)
            
    }
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
            cell.delegate = self
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
    
    

}

extension ItemDetailViewController: GearActionsCollectionViewCellDelegate {
    func GearActionsCollectionViewCellDidTapMessageButton(_ cell: GearActionsCollectionViewCell, post: Post) {
        print("message tapped")
        guard let email1 = UserDefaults.standard.string(forKey: "email") else {return}
        let selectedItem = self.post

        let email2 = selectedItem.posterEmail
        
        if email1 == email2 {
            print("same person")
            return
        }

        DatabaseManager.shared.checkIfConversationExistsInDatabase(email1: email1, email2: email2, completion: {
            [weak self] result in

            guard let convoId = result else {
                let vc = ChatViewController(with: selectedItem.posterUsername, email: email2, id: nil)
                vc.title = selectedItem.posterUsername
                vc.isNewConversation = true
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                return
            }

            let vc = ChatViewController(with: selectedItem.posterUsername, email: selectedItem.posterEmail, id: convoId)
            DispatchQueue.main.async {
                self?.navigationController?.pushViewController(vc, animated: true)
            }

        })
        
    }
    
    func GearActionsCollectionViewCellDidTapSaveButton(_ cell: GearActionsCollectionViewCell, isSaved: Bool, post: Post) {
        print("saved tapped")
        
        spinner.show(in: view)

        DatabaseManager.shared.updateItemSaved(state: self.isSaved ? .unSaved : .save, itemId: self.post.postId, completion: {
            [weak self] success in
            if success {
                guard let savedState = self?.isSaved else {return}
                self?.isSaved = !savedState
                self?.completion?(true)
                NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
                self?.spinner.dismiss()
                print("success")
            } else {
                print("failed to save")
                self?.spinner.dismiss()
            }
        })
    }
}


//MARK: header functions


extension ItemDetailViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, post: Post, type: String, index: Int) {
       
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        if currentEmail == post.posterEmail {
            let sheet = UIAlertController(title: "post action", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
            sheet.addAction(UIAlertAction(title: "delete post", style: .default, handler: {
                [weak self] _ in
                if type == "item" {
                    let ac = UIAlertController(title: "are you sure?", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "delete", style: .default, handler: { [weak self] _ in
                        let postId = post.postId
                        DatabaseManager.shared.deleteClipOrNormalPost(postId: postId, completion: {
                            [weak self] success in
                            if success {
                                //self?.completion?()
                                DispatchQueue.main.async {
                                    self?.tabBarController?.selectedIndex = 4
                                    self?.navigationController?.popToRootViewController(animated: false)
                                }
                            }
                        })
                    }))
                    ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
                    self?.present(ac, animated: true)
                }
                
            }))
            present(sheet, animated: true)
            
        } else {
            let sheet = UIAlertController(title: "post action", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
            sheet.addAction(UIAlertAction(title: "block user", style: .default, handler: {
                [weak self] _ in
                guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
                self?.blockAUser(email: post.posterEmail, currentEmail: currentEmail)
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
        
        let post = post
        
        let vc = ProfileViewController(user: User(username: post.posterUsername, email: post.posterEmail, region: region))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: useless for this controller


extension ItemDetailViewController: titleCollectionViewCellDelegate {
    func titleCollectionViewCellDelegateDidTapTitle(_ cell: titleCollectionViewCell) {
        print("title tapped")
    }
}


extension ItemDetailViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption: String) {
        let vc = captionDetailViewController(caption: caption)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension ItemDetailViewController: MultiImageViewDelegate {
    func MultiImageViewDelegateDidDoubleTap(_ cell: MultiPhotoCollectionViewCell, post: Post, index: Int, type: String) {
        //nothing
    }
    
    func MultiImageViewDelegateDidScroll(_ cell: MultiPhotoCollectionViewCell, page: Int, index: Int, type: String) {
        let actionIndex = IndexPath(row: 2, section: 0)
        print("here")
        guard let actionCell = collectionView?.cellForItem(at: actionIndex) as? GearActionsCollectionViewCell else {
            print("returned")
            return}
        print(page)
        actionCell.pageTurner.currentPage = page
        
    }
    
    
}



