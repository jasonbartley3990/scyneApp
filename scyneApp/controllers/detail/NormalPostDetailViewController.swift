//
//  NormalPostDetailViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/22/21.
//

import Foundation
import UIKit

class NormalPostDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var viewModels = [[HomeFeedCellType]]()
    
    private var isLiked: Bool = false
    
    private var post: Post
    
    public var completion: (() -> Void)?
    
    private var likers = [String]()
    
    private var collectionView: UICollectionView?
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func showAlert() {
        let ac = UIAlertController(title: "Something went wrong", message: "Please try again later", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        DispatchQueue.main.async {
            self.present(ac,animated: true)
        }
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
                    ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    self?.present(ac, animated: true)
                }
            })
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    
    private func createViewModel(post: Post, completion: @escaping (Bool) -> Void) {
        
        StorageManager.shared.profilePictureUrl(for: post.posterEmail) { [weak self] profilePictureUrl in
            
            guard let profilePic = profilePictureUrl else {
                completion(false)
                return}
            
            guard let email = UserDefaults.standard.string(forKey: "email") else {
                completion(false)
                return}
            
                
            DatabaseManager.shared.getTotalLikers(for: post, completion: {
                [weak self] likers in
                    
                let isPostLiked = likers.contains(email)
                self?.likers = likers
                
                    
                    let clipData: [HomeFeedCellType] = [
                        .poster(viewModel: PosterCollectionViewCellviewModel(email: post.posterEmail, username: post.posterUsername, region: post.region, post: post, postType: "clip", profilePicture: profilePic)
                        ),
                        .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: post.photoUrls, post: post, type: "post")),
                        .normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: isPostLiked, likeCount: likers.count, post: post, likers: likers, numberOfPhotos: post.urlCount)),
                        .title(viewModel: TitleCollectionViewCellViewModel(title: post.posterUsername)),
                        .caption(viewModel: PostCaptionCollectionViewCellModel(caption: post.caption)),
                        .timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel(date: post.postedDateNum, dateString: post.postedDateString))
                        ]
                    self?.viewModels.append(clipData)
                    completion(true)
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
        collectionView.register(NormalPostActionsCollectionViewCell.self, forCellWithReuseIdentifier: NormalPostActionsCollectionViewCell.identifier)
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
            cell.delegate = self
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

extension NormalPostDetailViewController: PosterCollectionViewCellDelegate {
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

extension NormalPostDetailViewController: MultiImageViewDelegate {
    func MultiImageViewDelegateDidScroll(_ cell: MultiPhotoCollectionViewCell, page: Int, index: Int, type: String) {
        let actionIndex = IndexPath(row: 2, section: 0)
        guard let actionCell = collectionView?.cellForItem(at: actionIndex) as? NormalPostActionsCollectionViewCell else {
            return}
        actionCell.pageTurner.currentPage = page
        
    }
    
    func MultiImageViewDelegateDidDoubleTap(_ cell: MultiPhotoCollectionViewCell, post: Post, index: Int, type: String) {
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        let actionIndex = IndexPath(row: 2, section: index)
        
        guard let cell = collectionView?.cellForItem(at: actionIndex) as? NormalPostActionsCollectionViewCell else { return }
        
        if self.isLiked {
            cell.isLiked = !isLiked
            let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .label
            DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
            cell.updateNormalLikeLabel(with: currentEmail)
            let likers = cell.likers
            self.isLiked = false
            self.likers.removeAll { $0 == currentEmail }
            let count = cell.likeCount
            self.viewModels[0][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: false, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
            NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
        } else {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .systemRed
            cell.isLiked = !isLiked
            DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
            cell.updateNormalLikeLabel(with: currentEmail)
            let likers = cell.likers
            self.isLiked = true
            self.likers.append(currentEmail)
            let count = cell.likeCount
            self.viewModels[0][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: true, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
            NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
            
        }
    }

}

extension NormalPostDetailViewController: normalPostActionCollectionViewCellDelegate {
    func normalPostActionsCollectionViewCellDidTapLike(_ cell: NormalPostActionsCollectionViewCell, isLiked: Bool, post: Post, index: Int) {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        if isLiked {
            cell.isLiked = !isLiked
            let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .label
            DatabaseManager.shared.removeLikeFromArray(for: post, email: currentEmail)
            cell.updateNormalLikeLabel(with: currentEmail)
            let likers = cell.likers
            self.likers.removeAll { $0 == currentEmail }
            let count = cell.likeCount
            self.viewModels[0][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: false, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
        } else {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            cell.likeButton.setImage(image, for: .normal)
            cell.likeButton.tintColor = .systemRed
            cell.isLiked = !isLiked
            DatabaseManager.shared.addLikeToArray(for: post, email: currentEmail)
            cell.updateNormalLikeLabel(with: currentEmail)
            let likers = cell.likers
            self.likers.append(currentEmail)
            let count = cell.likeCount
            self.viewModels[0][2] = HomeFeedCellType.normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel(isLiked: true, likeCount: count, post: post, likers: likers, numberOfPhotos: post.urlCount))
        }
        
    }
    
    func normalPostActionsCollectionViewCellDidTapComment(_ cell: NormalPostActionsCollectionViewCell, post: Post) {
        let vc = commentViewController(post: self.post)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func postActionsCollectionViewCellDidTapLikers(_ cell: NormalPostActionsCollectionViewCell, likers: [String], likeCount: Int) {
        
        let vc = likerTableViewController(likers: self.likers, likeCount: self.likers.count)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NormalPostDetailViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption: String) {
        guard let cap = self.post.caption else {return}
        let vc = captionDetailViewController(caption: cap)
        navigationController?.pushViewController(vc, animated: true)
    }
}
