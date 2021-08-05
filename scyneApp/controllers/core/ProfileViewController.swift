//
//  ProfileViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import SafariServices

enum urlError: Error {
    case inValidUrl
}

class ProfileViewController: UIViewController {

    // MARK: properties

    private let user: User

    private var collectionView: UICollectionView?
    
    private var bio: String?
    
    private var link: String?

    private var posts: [Post] = []
    
    private var unreadMessages = 0

    private var headerViewModel: ProfileHeaderViewModel?
    
    private var hasCountedViews = false
    
    private var hasFullLengthBeenUpdated = false


    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username") ?? ""
    }


    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureCollectionView()
        fetchProfileInfo()
        fetchClipPosts(user: user.email)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didFollowSomeone), name: Notification.Name("didTapFollow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnfollowSomeone), name: Notification.Name("didTapUnfollow"), object: nil)

        if isCurrentUser {
            print("current user")
            NotificationCenter.default.addObserver(self, selector: #selector(userDidPost), name: Notification.Name("didPost"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(userDidRead), name: Notification.Name("didRead"), object: nil)
            updateFullLengthViews()
        }
        
        self.headerViewModel?.clipCount = posts.count
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //changes title so tab bar doesnt have a really long username at the bottom
        title = "profile"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = user.username.uppercased()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    //MARK: configure nav bar and get unread messages


    private func configureNavBar() {
        print("configure")
        if isCurrentUser {
            print("current user")
            let group = DispatchGroup()
            
            group.enter()
            
            DatabaseManager.shared.getUnreadMessages(for: user.email, completion: {
                [weak self] num in
                group.leave()
                self?.unreadMessages = num
                var string = ""
                if num == 0 {
                    string = ""
                    //if no unread messages then there will be no number image

                } else if num == 1 {
                   string = "1.circle.fill"
                } else if num == 2 {
                   string = "2.circle.fill"
                } else if num == 3 {
                    string = "3.circle.fill"
                } else if num == 4 {
                    string = "4.circle.fill"
                } else if num == 5 {
                    string = "5.circle.fill"
                } else if num == 6 {
                   string = "6.circle.fill"
                } else if num == 7 {
                   string = "7.circle.fill"
                } else if num == 8 {
                    string = "8.circle.fill"
                } else if num == 9 {
                   string = "9.circle.fill"
                } else if num == 10 {
                    string = "10.circle.fill"
                } else {
                    string = "10.circle.fill"
                }
                
                let message = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self?.didTapComposeButton))
                let number = UIBarButtonItem(image: UIImage(systemName: string), style: .done, target: self, action: #selector(self?.didTapComposeButton))
                let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                self?.navigationItem.rightBarButtonItems = [message, number, spacer]
                let gear = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(self?.didTapSettings))
                let notification = UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: #selector(self?.didTapNotifications))
                self?.navigationItem.leftBarButtonItems = [gear, notification, spacer]
                
                
            })
            
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(didTapMessage))
        }
    }
    

    //MARK: nav bar actions

    @objc func didTapSettings() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }


    @objc func didTapMessage() {
        print("message tapped")
        guard let email1 = UserDefaults.standard.string(forKey: "email") else {return}

        let email2 = user.email
        
        if email1 == email2 {
            print("same person")
            //its the same person this function should fail
            return
        }
        
        //if not the current user profile then this will execute and check if these people have had a conversation before, then show chat view controller

        DatabaseManager.shared.checkIfConversationExistsInDatabase(email1: email1, email2: email2, completion: {
            [weak self] result in
            
            guard let userUsername = self?.user.username else {return}
            
            guard let userEmail = self?.user.email else {return}

            guard let convoId = result else {
                
                //new conversation
                
                let vc = ChatViewController(with: userUsername, email: email2, id: nil)
                vc.title = self?.user.username
                vc.isNewConversation = true
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
                return
            }
            
            //have already had a conversation

            let vc = ChatViewController(with: userUsername, email: userEmail, id: convoId)
            self?.navigationController?.pushViewController(vc, animated: true)

        })
        

    }

    @objc func didTapComposeButton() {
        
        //if it is the current user then this will execute and show all their conversations in mesage room view controller
        
        let vc = messageRoomListViewController()
        vc.title = "convos"
        navigationController?.pushViewController(vc, animated: true)

    }
    
    //MARK: if a user read a message change the nav bar icon
    
    
    @objc func userDidRead() {
        let group = DispatchGroup()
        
        group.enter()
        
        DatabaseManager.shared.getUnreadMessages(for: user.email, completion: {
            [weak self] num in
            group.leave()
            
            //put number of unread messages in the nav bar
            self?.unreadMessages = num
            var string = ""
            if num == 0 {
                //if no unread messages no number in nav bar
                string = ""

            } else if num == 1 {
               string = "1.circle.fill"
            } else if num == 2 {
               string = "2.circle.fill"
            } else if num == 3 {
                string = "3.circle.fill"
            } else if num == 4 {
                string = "4.circle.fill"
            } else if num == 5 {
                string = "5.circle.fill"
            } else if num == 6 {
               string = "6.circle.fill"
            } else if num == 7 {
               string = "7.circle.fill"
            } else if num == 8 {
                string = "8.circle.fill"
            } else if num == 9 {
               string = "9.circle.fill"
            } else if num == 10 {
                string = "10.circle.fill"
            } else {
                string = "10.circle.fill"
            }
            
            let message = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self?.didTapComposeButton))
            let number = UIBarButtonItem(image: UIImage(systemName: string), style: .done, target: self, action: #selector(self?.didTapComposeButton))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            self?.navigationItem.rightBarButtonItems = [message, number, spacer]
            self?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(self?.didTapSettings))
            
        })
    }

    
    //MARK: get profile info

    
    private func fetchProfileInfo() {
        var buttonType: ProfileButtonType = .edit
        let group = DispatchGroup()
        var profilePictureurl: URL?
        var following = 0
        var followers = 0
        var name: String?
        var bio: String?
        var link: String?
        let noLink = ""

        //profilePictureUrl
        group.enter()
        StorageManager.shared.profilePictureUrl(for: user.email) { url in
            defer {
                group.leave()
            }
            profilePictureurl = url
        }

        //if profile is not current user
        if !isCurrentUser {
            //get follow state
            group.enter()
            DatabaseManager.shared.isFollowing(targetUserEmail: user.email) {
                isFollowing in
                defer {
                    group.leave()
                }
                buttonType = .follow(isFollowing: isFollowing)
            }
        }
        group.enter()
        
        //get followers and following
       DatabaseManager.shared.getUsers(email: user.email) {
            result in
            defer {
                group.leave()
            }
            followers = result.followers
            following = result.following

       }
        //bio, name
        group.enter()
        DatabaseManager.shared.getUserInfo(email: user.email) { userInfo in
            group.leave()
            name = userInfo?.name
            bio = userInfo?.bio
            link = userInfo?.link
            self.bio = userInfo?.bio
        }

        group.notify(queue: .main) {
            
            if let link = link {
                self.headerViewModel = ProfileHeaderViewModel(profilePictureUrl: profilePictureurl, followerCount: followers, followingCount: following, buttonType: buttonType, clipCount: self.posts.count, name: name, bio: bio, webLink: link)
                self.link = link
            } else {
                self.headerViewModel = ProfileHeaderViewModel(profilePictureUrl: profilePictureurl, followerCount: followers, followingCount: following, buttonType: buttonType, clipCount: self.posts.count, name: name, bio: bio, webLink: noLink)
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()

            }
        }
    }
    
    //MARK: get all the users clip posts for the collectionview


    private func fetchClipPosts(user: String) {

        DatabaseManager.shared.getAllClipPostsForUser(email: user, completion: {
            [weak self] posts in
            //set collection view posts to these clips
            self?.posts = posts
            if let bool = self?.isCurrentUser {
                if bool == true {
                    if self?.hasCountedViews == false {
                        self?.hasCountedViews = true
                        for post in posts {
                            
                            //update total views for their clips everytime a user visits their own profile, to update its index on the backend, instead of updating it everytime someone views it.
                            
                            DatabaseManager.shared.getTotalViews(for: post, completion: {
                                views in
                                if let previousViews = post.viewers {
                                    if views > previousViews {
                                        DatabaseManager.shared.updateClipViewsForUsersPost(post: post, views: views, completion: { success in
                                            if success {
                                                print("success")
                                            }
                                        })
                                        
                                    }
                                }
                            })
                            
                        }
                    }
                }
                
            }
            
            self?.headerViewModel?.clipCount = posts.count
            print("posts: \(posts.count)")
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
            
        })
    }
    

    @objc func userDidPost() {
        guard let header = collectionView?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? ProfileHeaderCollectionReusableView else {return}


        ProfileHeaderViewCollectionReusableViewDidTapClips(header)

    }
    
    //MARK: notification controller
    
    @objc func didTapNotifications() {
        let vc = NotificationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: when they unfollow somebody decrease their following count
    
    @objc func didUnfollowSomeone() {
        if isCurrentUser {
            headerViewModel?.followingCount -= 1
            guard let num = headerViewModel?.followingCount else {return}
            let header = collectionView?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: [0,0]) as? ProfileHeaderCollectionReusableView
            header?.countContainerView.followingCountButton.setTitle("\(num)\nfollowing", for: .normal)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }
    }
    
    //MARK: when they follow somebody increment their follower count
    
    @objc func didFollowSomeone() {
        if isCurrentUser {
            headerViewModel?.followingCount += 1
            guard let num = headerViewModel?.followingCount else {return}
            let header = collectionView?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: [0,0]) as? ProfileHeaderCollectionReusableView
            DispatchQueue.main.async {
                header?.countContainerView.followingCountButton.setTitle("\(num)\nfollowing", for: .normal)
                self.collectionView?.reloadData()
            }
        }
        
    }

}

//MARK: collection view delegate


extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
        fatalError()
    }
    let post = posts[indexPath.row]

    let postType = post.postType

    if postType == "clip" {
        //set thumbnail image
        guard let imageUrl = post.videoThumbnail else {return cell}
        cell.configure(with: URL(string: imageUrl), id: post.postId)
        return cell
    } else {
        let postUrls = post.photoUrls

        //set thumbnail as first image, for all other types of posts
        if !postUrls.isEmpty {
            let firstUrl = postUrls[0]
            cell.configure(with: URL(string: firstUrl ), id: post.postId)
        }

        return cell
    }

}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated:true)
    var post = posts[indexPath.row]
    let type = post.postType
    print(type)

    guard let email = UserDefaults.standard.string(forKey: "email") else {return}

    if type == "spot" {

        //show spot detail view controller
        
        guard let addy = post.address else {return}
        guard let spotType = post.spotType else {return}
        guard let nickName = post.nickname else {return}
        guard let latitude = post.latitude else {return}
        guard let longitude = post.longitude else {return}
        guard let spotId = post.spotId else {return}
        let savers = post.savers
        guard let spotInfo = post.caption else {return}
        
        let saveStatus = post.savers.contains(email)

        let vc = SpotDetailViewController(spot: SpotModel(location: addy, spotPhotoUrl: post.photoUrls, spotType: spotType , nickName: nickName, postedBy: post.posterUsername, latitude: latitude, longitude: longitude, spotId: spotId , savers: savers, spotInfo: spotInfo, isSaved: saveStatus), post: post)
        vc.completion = { [weak self] bool in
            guard let email = UserDefaults.standard.string(forKey: "email") else {return}
            if bool == true {
                NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
                
                if post.savers.contains(email) {
                    post.savers.removeAll { $0 == email }
                } else {
                    post.savers.append(email)
                }
                self?.posts[indexPath.row] = post
            }
            
        }
        navigationController?.pushViewController(vc, animated: true)

    } else if type == "gear" {
        print("gear")
        
        //show item detail view controller
        
        let vc = ItemDetailViewController(post: post)
        vc.completion = { [weak self] bool in
            NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
            
            if post.savers.contains(email) {
                post.savers.removeAll { $0 == email }
            } else {
                post.savers.append(email)
            }
            self?.posts[indexPath.row] = post
            
        }
        navigationController?.pushViewController(vc, animated: true)
    } else if type == "clip" {
        print("clip")
        //show single clip view controller
        let vc = singleClipViewerViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    } else if type == "normal" {
        //show normal post detail view controller
        let vc = NormalPostDetailViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }

}

func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    //set up profile header
    
    guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier, for: indexPath) as? ProfileHeaderCollectionReusableView else {
        return UICollectionReusableView()
    }
    print("header index")
    print(indexPath)
    if let viewModel = headerViewModel {
        headerView.configure(with: viewModel)
        headerView.countContainerView.delegate = self
    }
    headerView.delegate = self
    return headerView
}
}

//MARK: configure collection view

extension ProfileViewController {
func configureCollectionView() {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {
        index, _ -> NSCollectionLayoutSection? in

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.33)), subitem: item, count: 3)

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.71)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]

        return section
    })

    )
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
    collectionView.register(ProfileHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier)
    collectionView.backgroundColor = .systemBackground
    view.addSubview(collectionView)
    self.collectionView = collectionView
}
}


extension ProfileViewController: ProfileHeaderCountViewDelegate {
func profileHeaderCountViewDidTapFollowers(_ countainerView: ProfileHeaderCountView) {
    
    //list view controller for followers
    
    let vc = ListViewController(type: .followers(user: user))
    navigationController?.pushViewController(vc, animated: true)

}

func profileHeaderCountViewDidTapFollowing(_ countainerView: ProfileHeaderCountView) {
    
    //list view controller for following
    
    let vc = ListViewController(type: .Following(user: user))
    navigationController?.pushViewController(vc, animated: true)

}

func profileHeaderCountViewDidTapPosts(_ countainerView: ProfileHeaderCountView) {
    guard posts.count >= 18 else {return}
    collectionView?.setContentOffset(CGPoint(x: 0, y: (view.width * 0.7)), animated: true)
}

func profileHeaderCountViewDidTapEditProfile(_ countainerView: ProfileHeaderCountView) {
    
    //go to edit profile view controller
    
    let vc = editProfileViewController()
    vc.completion = { [weak self] in
        //refresher header info
        self?.headerViewModel = nil
        self?.fetchProfileInfo()
    }
    let navVC = UINavigationController(rootViewController: vc)
    present(navVC, animated: true)

}

func profileHeaderCountViewDidTapFollow(_ countainerView: ProfileHeaderCountView) {
    
    //update follow status on backend
    
    DatabaseManager.shared.updateRelationship(state: .follow, for: user.username, targetEmail: user.email) { [weak self] success in
            if success {
                NotificationCenter.default.post(name: Notification.Name("didTapFollow"), object: nil)
                guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
                
                guard let otherUserEmail = self?.user.email else {return}
                
                DatabaseManager.shared.addFollowNotification(username: currentUsername, otherUserEmail: otherUserEmail, completion: {
                    success in
                    if success {
                        print("sent notification")
                    }
                })
                
            } else {
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }
        }
}

func profileHeaderCountViewDidTapUnfollow(_ countainerView: ProfileHeaderCountView) {
    
    //update follow status on backend
    
    DatabaseManager.shared.updateRelationship(state: .unfollow, for: user.username, targetEmail: user.email) { [weak self] success in
       
        if success {
            NotificationCenter.default.post(name: NSNotification.Name("didTapUnfollow"), object: nil)
            guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
            
            guard let otherUserEmail = self?.user.email else {return}
            
            DatabaseManager.shared.removeFollowNotification(username: currentUsername, otherUserEmail: otherUserEmail, completion: {
                success in
                if success {
                    print("sent notification")
                }
            })
        } else {
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
            
            
        }
    }

}


}

//MARK: profile header functions

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func ProfileHeaderViewCollectionReusableViewDidTapLink(_ header: ProfileHeaderCollectionReusableView) {
        
        //open up web page for link
        
        guard let linky = self.link else {return}
        
        let result = urlOpener.shared.verifyUrl(urlString: linky)
        if result == true {
            if let url = URL(string: linky) {
                let vc = SFSafariViewController(url: url)
               present(vc, animated: true)
            }
        } else {
            print("cant opemn url")
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "invalid url", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(ac, animated: true)
            }
            
        }
        
        
        
    }
    
    func ProfileHeaderViewCollectionReusableViewDidTapBio(_ header: ProfileHeaderCollectionReusableView) {
        
        //show bio detail view controller
        
        guard let bio = self.bio else {return}
        let vc = BioDetailViewController(bio: bio)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func ProfileHeaderViewCollectionReusableViewDidTapPosts(_ header: ProfileHeaderCollectionReusableView) {
        
        //grab all noraml posts and fill up collection view
        
        DatabaseManager.shared.getAllNormalPostsForUser(email: user.email, completion: {
            [weak self] posts in
            self?.posts = posts
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        })
        
        
    }
    
    func ProfileHeaderViewCollectionReusableViewDidTapItems(_ header: ProfileHeaderCollectionReusableView) {
        
        //grab all items for sale and fill up collection view

        DatabaseManager.shared.getAllItemPostsForUser(email: user.email, completion: {
            [weak self] posts in
            self?.posts = posts
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        })

    }

    func ProfileHeaderViewCollectionReusableViewDidTapSpots(_ header: ProfileHeaderCollectionReusableView) {
        
        //grab all spots user posted and fill up collection view

        DatabaseManager.shared.getAllSpotPostsForUser(email: user.email, completion: {
            [weak self] posts in
            self?.posts = posts
            print("posts: \(posts.count)")
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        })
    }

    func ProfileHeaderViewCollectionReusableViewDidTapClips(_ header: ProfileHeaderCollectionReusableView) {
        
        //grab all clips and fill up collection view
        
        DatabaseManager.shared.getAllClipPostsForUser(email: user.email, completion: {
            [weak self] posts in
            self?.posts = posts
            print("posts: \(posts.count)")
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        })
    }
    
    func ProfileHeaderViewCollectionReusableViewDidTapImage(_ header: ProfileHeaderCollectionReusableView) {
        
        // let user change their profile picture
        
        let sheet = UIAlertController(title: "profile picture", message:"how would you like to select a profile picture", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "take photo", style: .default, handler: {
            [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                self?.present(picker, animated: true)
            }
        }))

        sheet.addAction(UIAlertAction(title: "choose photo", style: .default, handler: {
            [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                self?.present(picker, animated: true)
            }

        }))
        present(sheet, animated: true)
        }


    }



//MARK: profile image picker controller delegate


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
    StorageManager.shared.uploadProfilePicture(email: user.email, data: image.pngData()) {
        [weak self] success in
        if success {
            self?.headerViewModel = nil
            self?.posts = []
            self?.fetchProfileInfo()
        }
    }
}

}

//MARK: when they visit there profile update total number of views on a full length to update query index for post on backend, instead of updating it every time a user watches it to save on database cost

extension ProfileViewController {
    private func updateFullLengthViews() {
        if hasFullLengthBeenUpdated == false {
            guard let email = UserDefaults.standard.string(forKey: "email") else {return}
            DatabaseManager.shared.updateFullLengthViewsForUser(email: email, completion: {
                [weak self] success in
                if success == false {
                    self?.hasFullLengthBeenUpdated = false
                }
                if success == true {
                    self?.hasFullLengthBeenUpdated = true
                }
                                                                
            })
        }
    }
}



