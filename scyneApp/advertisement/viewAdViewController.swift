//
//  viewAdViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit
import SafariServices

class viewAdViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private var AllAds = [[HomeFeedCellType]]()
    
    private var collectionView: UICollectionView?
    
    private var currentIndex = 0
    
    private var isCurrentViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        getAd()
        configureCollectionView()
        presentInformation()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top - 5, width: view.width, height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
    }
    
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
    
    func getAd() {
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        DatabaseManager.shared.grabAdForCompany(with: email, completion: {
            [weak self] adv in
            guard let ad = adv else {
                let ac = UIAlertController(title: "ad not created yet for comapny", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true, completion: nil)
                return
            }
            
            let type = ad.adType
            
            guard let firstUrl = ad.Urls.first else {
                return}
            
            guard let vidUrl = URL(string: firstUrl) else {
                return}
            
            let group = DispatchGroup()
            
                
            if type == "video" {
                group.enter()
                let adData: [HomeFeedCellType] = [
                    .advertisementheader(viewModel: advertisementHeaderViewModel(company: ad.company, link: ad.companyLink, photoUrl: ad.companyPhoto)),
                    .singleVideo(viewModel: SingleVideoCollectionViewCellViewModel(url: vidUrl, post: nil, viewers:0, type: "ad")),
                    .AdPageTurner(viewModel: AdvertisementPageTurnerViewModel(urlCount: ad.urlCount)),
                    .title(viewModel: TitleCollectionViewCellViewModel(title: ad.company)),
                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: ad.caption)),
                    .advertisementLink(viewModel: AdvertisementWebLinkViewModel(link: ad.productLink, linkTitle: ad.productLinkLabel))
                ]
                self?.AllAds.append(adData)
                self?.AllAds.append(adData)
                self?.AllAds.append(adData)
                group.leave()
               
            }
            
            if type == "photo" {
                group.enter()
                let adData: [HomeFeedCellType] = [
                    .advertisementheader(viewModel: advertisementHeaderViewModel(company: ad.company, link: ad.companyLink, photoUrl: ad.companyPhoto)),
                    .MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel(urls: ad.Urls, post: nil, type: "ad")),
                    .AdPageTurner(viewModel: AdvertisementPageTurnerViewModel(urlCount: ad.urlCount)),
                    .title(viewModel: TitleCollectionViewCellViewModel(title: ad.company)),
                    .caption(viewModel: PostCaptionCollectionViewCellModel(caption: ad.caption)),
                    .advertisementLink(viewModel: AdvertisementWebLinkViewModel(link: ad.productLink, linkTitle: ad.productLinkLabel))
                ]
                self?.AllAds.append(adData)
                self?.AllAds.append(adData)
                self?.AllAds.append(adData)
                group.leave()
            }
            
            group.notify(queue: .main, execute: {
                self?.collectionView?.reloadData()
            })
        
        })
    }
    
    private func presentInformation() {
        let ac = UIAlertController(title: "this is what your ad will look like as you scroll through a feed", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return AllAds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = AllAds[indexPath.section][indexPath.row]
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
        return AllAds[section].count
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
            currentIndex = indexPath.section
            cell.index = indexPath.section
            if isCurrentViewController {
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
        
        if cell.reuseIdentifier == NormalPostActionsCollectionViewCell.identifier {
            guard let cell = cell as? NormalPostActionsCollectionViewCell else { return }
            
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
            let actionCell = AllAds[indexPath.section][2]
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

}

extension viewAdViewController: AdvertisementWebLinkCollectionViewCellDelegate {
    func AdvertisementDidTapLink(_ cell: AdvertisementWebLinkCollectionViewCell, link: String) {
        let result = urlOpener.shared.verifyUrl(urlString: link)
        if result == true {
            if let url = URL(string: link) {
                let vc = SFSafariViewController(url: url)
               present(vc, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "invalid url", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            present(ac, animated: true)
        }
        
    }
    
    
}

extension viewAdViewController: AdvertisementHeaderDelegate {
    func advertisementheaderDidTapMore(_ cell: AdvertisementHeaderCollectionViewCell, link: String) {
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

extension viewAdViewController: MultiImageViewDelegate {
    func MultiImageViewDelegateDidScroll(_ cell: MultiPhotoCollectionViewCell, page: Int, index: Int, type: String) {
        
        if cell.type == "spot" {
            let actionIndex = IndexPath(row: 2, section: index)
            guard let actionCell = collectionView?.cellForItem(at: actionIndex) as? SpotActionsCollectionViewCell else {return}
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
    
    func MultiImageViewDelegateDidDoubleTap(_ cell: MultiPhotoCollectionViewCell, post: Post, index: Int, type: String) {
        
    }
    
    
}

extension viewAdViewController: SingleVideoCollectionViewCellDelegate {
    func SingleVideoCollectionViewCellDidDoubleTap(_ cell: SingleVideoCollectionViewCell, index: Int, post: Post, viewers: Int, type: String) {
        
    }
    
    
}

extension viewAdViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption: String) {
        let vc = captionDetailViewController(caption: caption)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}

