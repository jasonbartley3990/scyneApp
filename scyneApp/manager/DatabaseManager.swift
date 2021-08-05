//
//  DatabaseManager.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//


import Foundation
import FirebaseFirestore
import MessageKit

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    
    public var isPaginating = false
    
    
    enum scynePostType: Int {
        case clip = 1
        case spot = 2
        case gear = 3
    }
    
    enum RelationshipState {
        case follow
        case unfollow
    }
    
    enum LikeState {
        case Like, Unlike
    }
    
    enum saveState {
        case save
        case unSaved
    }
    
    enum DatabaseError {
        case failedToFetch
    }
    
    // MARK: this creates a user when signing up
    
    public func createUser(newuser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newuser.email)")
        guard let data = newuser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) {
            error in
            completion(error == nil)
        }
        
    }
    
    public func timeStamp(from date: Date) -> Timestamp {
        let date = FirebaseFirestore.Timestamp(date: date)
        return date
    }
    
    
    
    
    // MARK: find user with email or username
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.whereField("email", isEqualTo: email).getDocuments(completion: { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.email == email })
            completion(user)
        })
    }
    
    public func findUserWithUsername(with username: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.whereField("username", isEqualTo: username).getDocuments(completion: {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data() )}), error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.username == username})
            completion(user)
        })
    }
    
    
    public func findUsers(with usernamePrefix: String, completion: @escaping ([User]) -> Void) {
        let ref = database.collection("users")
        ref.whereField("username", isGreaterThanOrEqualTo: usernamePrefix).limit(to: 10).getDocuments(completion: {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                print("an error")
                completion([])
                return
            }
            let subset = users.filter({ $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())})
            completion(subset)
        })
    }
    
    

    
    public func findUser(username: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.whereField("username", isEqualTo: username).getDocuments(completion: {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.username == username })
            completion(user)
        })
    }
    
    
    
    //MARK: update follow status
    
    
    public func updateRelationship(state: RelationshipState, for targetUsername: String, targetEmail: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            completion(false)
            return
        }
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
        
        let currentFollowing = database.collection("users").document(currentUserEmail).collection("following")
        let targetUserFollowers = database.collection("users").document(targetEmail).collection("followers")
        
        let currentFollowingEmail = database.collection("users").document(currentUserEmail).collection("followingEmail")
        let targetUserFollowersEmail = database.collection("users").document(targetEmail).collection("followersEmail")
        
        switch state {
        case .unfollow:
            //remove follower from currentUser followers list
            currentFollowing.document(targetUsername).delete()
            targetUserFollowers.document(currentUsername).delete()
            
            currentFollowingEmail.document(targetEmail).delete()
            targetUserFollowersEmail.document(currentUserEmail).delete()
            
            completion(true)
            
        case .follow:
            currentFollowing.document(targetUsername).setData(["valid": "1"])
            targetUserFollowers.document(currentUsername).setData(["valid": "1"])
            
            currentFollowingEmail.document(targetEmail).setData(["valid": "1"])
            targetUserFollowersEmail.document(currentUserEmail).setData(["valid": "1"])
            completion(true)
        
        }
    
}
    
    public func getFollowNotification(email: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users").document(email).collection("followNotification").document("follows")
        ref.getDocument(completion: { snapshot, error in
            guard error == nil else {
                print("error in getting follows")
                completion([])
                return
            }
            guard let data = snapshot?.data() else {
                print("snap data")
                completion([])
                return}

            guard let follows = data["follows"] as? [String] else {
                print("not array of strings")
                completion([])
                return}
            completion(follows)
        })
    }
    
    
    public func addFollowNotification(username: String, otherUserEmail: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(otherUserEmail).collection("followNotification").document("follows")
        ref.getDocument(completion: { snapshot, error in
            guard error == nil else {
                print("error in getting follows")
                completion(false)
                return
            }
            guard let data = snapshot?.data() else {
                print("snap data")
                //create new document
                
                let newStringArray: [String] = [username]
                let value = ["follows" : newStringArray]
                ref.setData(value, completion: {
                    error in
                    completion(error == nil)
                })
                return
            }
            
            guard var follows = data["follows"] as? [String] else {
                print("not array of strings")
                completion(false)
                return
            }
            follows.append(username)
            let value = ["follows": follows]
            ref.setData(value, completion: {
                err in
                completion(err == nil)
            })
        })
    }
    
    public func removeFollowNotification(username: String, otherUserEmail: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(otherUserEmail).collection("followNotification").document("follows")
        ref.getDocument(completion: { snapshot, error in
            guard error == nil else {
                print("error in getting follows")
                completion(false)
                return
            }
            guard let data = snapshot?.data() else {
                print("snap data")
                completion(false)
                return
            }
            
            guard var follows = data["follows"] as? [String] else {
                print("not array of strings")
                completion(false)
                return
            }
            follows.removeAll(where: { $0.contains(username)})
            let value = ["follows": follows]
            ref.setData(value, completion: {
                err in
                completion(err == nil)
            })
        })
    }
    
    public func shortenNotificationCount(email: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(email).collection("followNotification").document("follows")
        
        database.runTransaction( {
            (transaction, errorPointer) -> Any? in
            
            let followsDocument: DocumentSnapshot
                do {
                    try followsDocument = transaction.getDocument(ref)
                } catch let fetchError {
                    print(fetchError.localizedDescription)
                    completion(false)
                    return nil
                    
                }
            
            guard let data = followsDocument.data() as? [String: Any] else {
                completion(false)
                return nil
                
            }
            
            guard var dictionary = data["follows"] as? [String] else {
                completion(false)
                return nil}
            
            while dictionary.count > 100 {
                dictionary.removeFirst()
            }
            
            transaction.updateData(["follows" : dictionary], forDocument: ref)
            completion(true)
            return nil
            
        }) { (object, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            print("success")
            
        }
        
    }
    
    
    
    // MARK: returns a bool if the user is following
    
    public func isFollowing(targetUserEmail: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let ref = database.collection("users").document(targetUserEmail).collection("followers").document(currentUserEmail)
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
        
    }
    
    
    //MARK: grabs the followers for a email
    
    public func followers(for email: String, completion: @escaping ([String], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("users").document(email).collection("followers").limit(to: 15)
        ref.getDocuments { [weak self] snapshot, error in
            guard let usernames = snapshot?.documents.compactMap( { $0.documentID }), error == nil else {
                self?.isPaginating = false
                completion([], nil)
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                self?.isPaginating = false
                completion([], nil)
                return
            }
            completion(usernames, lastDoc)
            self?.isPaginating = false
        }
    }
    
    
    //MARK: grabs what a username is following
    
    
    public func following(for email: String, completion: @escaping ([String], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("users").document(email).collection("following").limit(to: 15)
        ref.getDocuments { [weak self] snapshot, error in
            guard let usernames = snapshot?.documents.compactMap( { $0.documentID }), error == nil else {
                self?.isPaginating = false
                completion([], nil)
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                self?.isPaginating = false
                completion([], nil)
                return
                
            }
            
            completion(usernames, lastDoc)
            self?.isPaginating = false
        }
    }
    
    public func continueGettingFollowers(for email: String, lastDoc: DocumentSnapshot, completion: @escaping ([String], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("users").document(email).collection("followers").start(afterDocument: lastDoc).limit(to: 15)
        ref.getDocuments { [weak self] snapshot, error in
            guard let usernames = snapshot?.documents.compactMap( { $0.documentID }), error == nil else {
                self?.isPaginating = false
                completion([], nil)
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                self?.isPaginating = false
                completion([], nil)
                return
            }
            completion(usernames, lastDoc)
        }
    }
    
    
    
    public func continueGettingFollowing(for email: String, lastDoc: DocumentSnapshot, completion: @escaping ([String], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("users").document(email).collection("following").start(afterDocument: lastDoc).limit(to: 15)
        ref.getDocuments { [weak self] snapshot, error in
            guard let usernames = snapshot?.documents.compactMap( { $0.documentID }), error == nil else {
                self?.isPaginating = false
                completion([], nil)
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                self?.isPaginating = false
                completion([], nil)
                return
                
            }
            
            completion(usernames, lastDoc)
            self?.isPaginating = false
        }
    }
    
    
    
    
    public func followingEmail(for email: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users").document(email).collection("followingEmail")
        ref.getDocuments(completion: {
            snapshot, error in
            guard let emails = snapshot?.documents.compactMap( { $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(emails)
        })
    }
    
    
    
    
    
    // MARK: gets user basic info for profile
    
    public func getUserInfo(email: String, completion: @escaping (UserInfo?) -> Void) {
        let ref = database.collection("users").document(email).collection("information").document("basic")
        ref.getDocument { snapshot, error in
            guard error == nil else {
                completion(nil)
                return
            }
            guard let data = snapshot?.data(), let userInfo = UserInfo(with: data) else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }
    
    
    
    
    
    
    //MARK: making and fetching post
    
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            completion(false)
            return
        }
        let reference = database.collection("posts").document(newPost.postId)
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) {
            error in
            completion(error == nil)
        }
    }
    
    
    public func getAllPostsForRegion(region: String, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).order(by: "postedDateNum", descending: true).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([], nil)
                    self?.isPaginating = false
                    return
                }
                guard let lastSnapshot = snapshot?.documents.last else {
                    completion([], nil)
                    self?.isPaginating = false
                    return
                }
                completion(posts, lastSnapshot)
                self?.isPaginating = false
            } else {
                print("error in getting posts")
                completion([], nil)
                self?.isPaginating = false
            }
        })
    }
    
    public func continueAllPostForRegion(region: String, lastDoc: DocumentSnapshot, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
       
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).order(by: "postedDateNum", descending: true).start(afterDocument: lastDoc).limit(to: 10)
        ref.getDocuments(completion: {
            snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([], nil)
                    self.isPaginating = false
                    return
                }
                guard let lastSnapshot = snapshot?.documents.last else {
                    completion([], nil)
                    self.isPaginating = false
                    return
                }
                completion(posts, lastSnapshot)
                self.isPaginating = false
            } else {
                print("error in getting posts")
                completion([], nil)
                self.isPaginating = false
            }
        })
       
        
        
    }
    
    public func getAllClipPostsForUser(email: String, completion: @escaping ([Post]) -> Void) {
    
        let ref = database.collection("posts").whereField("posterEmail", isEqualTo: email)
            .whereField("postType", isEqualTo: "clip")
            .order(by: "postedDateNum", descending: true)
        ref.getDocuments(completion: {
            snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([])
                    return
                }
                completion(posts)
            } else {
                completion([])
                print("there was an error")
            }
        })
    
    }
    
    public func updateClipViewsForUsersPost(post: Post, views: Int, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("posts").document(post.postId)
        ref.updateData(["viewers": views], completion: {
            error in
            completion(error == nil)
        })
        
    }
    
    
    
    public func getAllNormalPostsForUser(email: String, completion: @escaping ([Post]) -> Void) {
    
        let ref = database.collection("posts").whereField("posterEmail", isEqualTo: email)
            .whereField("postType", isEqualTo: "normal")
            .order(by: "postedDateNum", descending: true)
        ref.getDocuments(completion: {
            snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([])
                    return
                }
                completion(posts)
            } else {
                completion([])
                print("there was an error")
            }
        })
    
    }
    
    
    
    public func getAllItemPostsForUser(email: String, completion: @escaping ([Post]) -> Void) {
    
        let ref = database.collection("posts").whereField("posterEmail", isEqualTo: email)
            .whereField("postType", isEqualTo: "gear")
            .order(by: "postedDateNum", descending: true)
        ref.getDocuments(completion: {
            snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([])
                    return
                }
                completion(posts)
            } else {
                completion([])
                print("there was an error")
            }
        })
    
    }
    
    public func getMostViewedClipsForRegion(region: String, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).order(by: "viewers", descending: true).limit(to: 10)
        ref.getDocuments(completion: { [weak self]snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([], nil)
                    self?.isPaginating = false
                    return
                }
                guard let lastSnapshot = snapshot?.documents.last else {
                    completion([], nil)
                    self?.isPaginating = false
                    return
                }
                completion(posts, lastSnapshot)
                self?.isPaginating = false
            } else {
                completion([],nil)
                self?.isPaginating = false
                print("there was an error")
            }
        })
    }
    
    
    public func continueGetMostViewedClipsForRegion(region: String, lastDoc: DocumentSnapshot, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).order(by: "viewers", descending: true).limit(to: 10).start(afterDocument: lastDoc)
        ref.getDocuments(completion: { [weak self]snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([], nil)
                    self?.isPaginating = false
                    return
                }
                guard let lastSnapshot = snapshot?.documents.last else {
                    completion([], nil)
                    self?.isPaginating = false
                    return
                }
                completion(posts, lastSnapshot)
                self?.isPaginating = false
            } else {
                completion([],nil)
                self?.isPaginating = false
                print("there was an error")
            }
        })
    }
    
    
    
    public func getAllSpotPostsForUser(email: String, completion: @escaping ([Post]) -> Void) {
    
        let ref = database.collection("posts").whereField("posterEmail", isEqualTo: email)
            .whereField("postType", isEqualTo: "spot")
            .order(by: "postedDateNum", descending: true)
        ref.getDocuments(completion: {
            snapshot, error in
            if error == nil {
                guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                    completion([])
                    return
                }
                completion(posts)
            } else {
                completion([])
                print("there was an error")
            }
        })
    
    }
    
    
    
    //MARK:Item calls
    
    
    
    public func getAllItemsForRegion(region: String, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).whereField("postType", isEqualTo: "gear").order(by: "postedDateNum", descending: true).limit(to: 15)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let items = snapshot?.documents.compactMap({ Post(with: $0.data() ) }), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(items, lastSnapshot)
            self?.isPaginating = false
        })
    }
    
    public func continueGetAllItemsForRegion(region: String, lastDoc: DocumentSnapshot, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).whereField("postType", isEqualTo: "gear").order(by: "postedDateNum", descending: true).start(afterDocument: lastDoc).limit(to: 15)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let items = snapshot?.documents.compactMap({ Post(with: $0.data() ) }), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(items, lastSnapshot)
            self?.isPaginating = false
        })
        
    }
    
    
    public func filterItemsForRegion(region: String, type: String, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).whereField("postType", isEqualTo: "gear").whereField("itemType", isEqualTo: type).order(by: "postedDateNum", descending: true).limit(to: 15)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let items = snapshot?.documents.compactMap({ Post(with: $0.data()) }) else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(items, lastSnapshot)
            self?.isPaginating = false
        })
    }
    
    public func continueFilteritemsForRegion(region: String, type: String, lastDoc: DocumentSnapshot, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("region", isEqualTo: region).whereField("postType", isEqualTo: "gear").whereField("itemType", isEqualTo: type).order(by: "postedDateNum", descending: true).start(afterDocument: lastDoc).limit(to: 15)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let items = snapshot?.documents.compactMap({ Post(with: $0.data()) }) else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(items, lastSnapshot)
            self?.isPaginating = false
        })
        
    }
    
    public func getPost(with id: String, completion: @escaping (Post?) -> Void) {
        let ref = database.collection("posts").whereField("postId", isEqualTo: id)
        ref.getDocuments(completion: {
            snapshot, error in
            guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}), error == nil else {
                print("couldnt convert to a post")
                completion(nil)
                return
            }
            if !posts.isEmpty {
                completion(posts[0])
            } else {
                print("empty")
                completion(nil)
            }
        })
    }
    
    
    public func getClipPostForUserThreeDaysAgo(date: Double, email: String, completion: @escaping ([Post]) -> Void) {
        let ref = database.collection("posts").whereField("posterEmail", isEqualTo: email).whereField("postType", isEqualTo: "clip").whereField("postedDateNum", isGreaterThan: date)
        ref.getDocuments(completion: {
            snapshot, error in
            guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}), error == nil else {
                completion([])
                print("could not get posts")
                return
                
            }
            completion(posts)
            
        })
    }
    
    public func getNormalPostForUserThreeDaysAgo(date: Double, email: String, completion: @escaping ([Post]) -> Void) {
        let ref = database.collection("posts").whereField("posterEmail", isEqualTo: email).whereField("postType", isEqualTo: "normal").whereField("postedDateNum", isGreaterThan: date)
        ref.getDocuments(completion: {
            snapshot, error in
            guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}), error == nil else {
                completion([])
                print("could not get posts")
                return
                
            }
            completion(posts)
            
        })
    }
    
    
    
    
    
    //MARK: comments
    
    public func createComment(for post: Post, comment: Comment, id: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("posts").document(post.postId).collection("comments").document(id)
        if comment.comment.count == 0 {
            completion(false)
            return
        }
        guard let data = comment.asDictionary() else {
            completion(false)
            return
        }
        ref.setData(data) {
            error in
            completion(error == nil)
        }
        
    }
    
    public func createCommentFullLength(for video: FullLength, comment: Comment, id: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("FullLengths").document(video.videoId).collection("comments").document(id)
        if comment.comment.count == 0 {
            completion(false)
            return
        }
        
        guard let data = comment.asDictionary() else {
            completion(false)
            return
        }
        ref.setData(data) {
            error in
            completion(error == nil)
        }
    }
    
    
    public func getCommentsForPost(post: Post, completion: @escaping ([Comment], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").document(post.postId).collection("comments").limit(to: 12)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let comments = snapshot?.documents.compactMap({ Comment(with: $0.data() )}), error == nil else {
                print("couldnt grab comments")
                self?.isPaginating = false
                completion([], nil)
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(comments, lastSnapshot)
            self?.isPaginating = false
            
        })
    }
    
    public func continueGetCommentsForPost(post: Post, lastDoc: DocumentSnapshot, completion: @escaping ([Comment], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").document(post.postId).collection("comments").start(afterDocument: lastDoc).limit(to: 12)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let comments = snapshot?.documents.compactMap({ Comment(with: $0.data() )}), error == nil else {
                print("couldnt grab comments")
                self?.isPaginating = false
                completion([], nil)
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(comments, lastSnapshot)
            self?.isPaginating = false
            
        })
    }
    
    
    public func getCommentsForFullLength(video: FullLength, completion: @escaping ([Comment], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").document(video.videoId).collection("comments").limit(to: 12)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let comments = snapshot?.documents.compactMap({ Comment(with: $0.data()) }), error == nil else {
                print("couldnt grab comments")
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(comments, lastSnapshot)
        })
    }
    
    public func continueGetCommentsForFullLength(video: FullLength, lastDoc: DocumentSnapshot, completion: @escaping ([Comment], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").document(video.videoId).collection("comments").start(afterDocument: lastDoc).limit(to: 12)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let comments = snapshot?.documents.compactMap({ Comment(with: $0.data()) }), error == nil else {
                print("couldnt grab comments")
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(comments, lastSnapshot)
            self?.isPaginating = false
        })
    }
    
    
    

    //MARK: saving posts
    
    
    public func saveItem(for email: String, postId: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(email).collection("savedItems")
        ref.document(postId).setData(["valid": 1], completion: { error in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    public func removeSavedItem(for email: String, itemId: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(email).collection("savedItems")
        ref.document(itemId).delete(completion: { error in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    public func grabSavedItems(for email: String, completion: @escaping ([String]?) -> Void) {
        let ref = database.collection("users").document(email).collection("savedItems")
        ref.getDocuments(completion: {
            items, error in
            if error == nil {
                guard let data = items?.documents.compactMap( { $0.documentID }) else {return}
                completion(data)
                return
            } else {
                print("error: \(error)")
                completion(nil)
            }
            
            
        })
    }
    
    public func getItem(with id: String, completion: @escaping (Post?) -> Void) {
        let ref = database.collection("posts").whereField("postId", isEqualTo: id)
        ref.getDocuments(completion: {
            snapshot, error in
           
            guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data() )}), error == nil else {
                print("couldnt convert to a post")
                completion(nil)
                return
            }
            if !posts.isEmpty {
                completion(posts[0])
            } else {
                print("empty")
                completion(nil)
            }
            
        })
    }
    
    public func updateItemSaved(state: saveState, itemId: String, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        let ref = database.collection("posts").document(itemId)
        let userRef = database.collection("users").document(currentEmail).collection("savedItems")
        print(state)
        
        ref.getDocument(completion: {
            snapshot, error in
            guard error == nil else {
                completion(false)
        
                return
            }
            guard let data = snapshot?.data() else {
                completion(false)
                return
            }
            guard var item = Post(with: data) else {
                completion(false)
                return
                
            }
            
            print(state)
            switch state {
            case .save:
                print("save")
                if !item.savers.contains(currentEmail) {
                    item.savers.append(currentEmail)
                }
            case .unSaved:
                print("unsave")
                item.savers.removeAll(where: { $0.contains(currentEmail)})
            }
            
            guard let newData = item.asDictionary() else {
                completion(false)
                return}
            
            ref.setData(newData, completion: {
                error in
                if error == nil {
                    switch state {
                    case .save:
                        print("saved to uses")
                        userRef.document(itemId).setData(["doc": "\(itemId)"], completion: { error in
                            if error == nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                    case.unSaved:
                        print("unsaved from users")
                        userRef.document(itemId).delete(completion: {
                            error in
                            completion(error == nil)
                            
                        })
                    }
                } else {
                    completion(false)
                }
            })
        })
    }
    
    //MARK: video count and likers
    
    
    public func incrementVideoCount(post: Post) {
        let ref = database.collection("posts").document(post.postId).collection("views").document("views")
        firestoreDistributedCounter.incrementCounter(by: 1, ref: ref, numShards: 8, completion: { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                print("failure")
            }
        })

    }
    
    public func createDistributedCounterForVideoCount(post: Post, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("posts").document(post.postId).collection("views").document("views")
        let numShards = 8
        firestoreDistributedCounter.createCounter(ref: ref, numShards: numShards, completion: { result in
            switch result {
            
            case .success(_):
                print("success")
                completion(true)
            case .failure(let error):
                print("failure to do it \(error.localizedDescription)")
                completion(false)
            }
        })
    }
    
    public func getTotalViews(for post: Post, completion: @escaping (Int) -> Void) {
        let ref = database.collection("posts").document(post.postId).collection("views").document("views")
        firestoreDistributedCounter.getCount(ref: ref, completion: {
            result in
            switch result {
                
            case .success(let count):
                print(count)
                completion(count)
            case .failure(_):
                completion(0)
            }
        })
    }
    
    public func createDistributedLikeCounterForPost(for post: Post, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("posts").document(post.postId).collection("likes").document("likes")
        let numShards = 4
        firestoreDistributedArray.createArrays(ref: ref, numShards: numShards, completion: { result in
            switch result {
            
            case .success(_):
                print("success")
                completion(true)
            case .failure(let error):
                print("failure to do it \(error.localizedDescription)")
                completion(false)
            }
        })
    
    }
    
    public func addLikeToArray(for post: Post, email: String) {
        let ref = database.collection("posts").document(post.postId).collection("likes").document("likes")
        firestoreDistributedArray.appendArray(with: email, ref: ref, numShards: 4, completion: { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                print("failure")
            }
        })
        
    }
    
    public func removeLikeFromArray(for post: Post, email: String) {
        let ref = database.collection("posts").document(post.postId).collection("likes").document("likes")
        firestoreDistributedArray.removeFromArray(with: email, ref: ref, numShards: 4, completion: { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                print("failure")
            }
        })
        
    }
    
    public func getTotalLikers(for post: Post, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("posts").document(post.postId).collection("likes").document("likes")
        firestoreDistributedArray.getArrayCount(ref: ref, completion: {
            result in
            switch result {
            
            case .success(let likers):
                print("success")
                completion(likers)
            case .failure(_):
                print("failure")
                completion([])
            }
        })
        
    }
    
    
    
    //MARK: spot functions
    
    
    public func getAllSpotsForCenter(latitude: Double, longitude: Double, completion: @escaping ([Post]) -> Void) {
        let minLatitude = latitude - 0.06
        let maxLatitude = latitude + 0.06
        let flatLong = floor(longitude)
        
        let ref = database.collection("posts").whereField("postType", isEqualTo: "spot").whereField("floorLong", isEqualTo: flatLong)
            .whereField("latitude", isGreaterThan: minLatitude)
            .whereField("latitude", isLessThan: maxLatitude)
        ref.getDocuments(completion: { snapshot, error in
            guard error == nil else {
                completion([])
                return}
            guard let spots = snapshot?.documents.compactMap({ Post(with: $0.data() )}) else {
                completion([])
                return}
            completion(spots)
            
        })
    }
    
    public func removeSavedSpot(for email: String, itemId: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(email).collection("savedSpots")
        ref.document(itemId).delete(completion: { error in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    
    
    public func getSpot(with id: String, completion: @escaping (SpotModel?) -> Void) {
        
        let ref = database.collection("spots").document(id)
        ref.getDocument(completion: {
            snapshot, error in
            if error == nil {
                guard let data = snapshot?.data() else {
                    completion(nil)
                    return
                }
                guard let post = SpotModel(with: data), error == nil else {
                    completion(nil)
                    return
                }
                completion(post)
            }
            
        })
    }
    
    
    public func grabSavedSpots(for email: String, completion: @escaping ([String]?) -> Void) {
        let ref = database.collection("users").document(email).collection("savedSpots")
        ref.getDocuments(completion: {
            spots, error in
            if error == nil {
                guard let data = spots?.documents.compactMap( { $0.documentID }) else {return}
                completion(data)
                return
            } else {
                print("error:")
                completion(nil)
            }
            
            
        })
        
    }
    
    
    public func saveSpot(for email: String, spotId: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(email).collection("savedSpots")
        ref.document(spotId).setData(["valid": 1], completion: { error in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    public func updateSpotSaved(state: saveState, postId: String, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        let ref = database.collection("posts").document(postId)
        let userRef = database.collection("users").document(currentEmail).collection("savedSpots")
        print(state)
        
        ref.getDocument(completion: {
            snapshot, error in
            guard error == nil else {
                completion(false)
        
                return
            }
            guard let data = snapshot?.data() else {
                completion(false)
                return
            }
            guard var spot = Post(with: data) else {
                completion(false)
                return
                
            }
            
            print(state)
            switch state {
            case .save:
                print("save")
                if !spot.savers.contains(currentEmail) {
                    spot.savers.append(currentEmail)
                }
            case .unSaved:
                print("unsave")
                spot.savers.removeAll(where: { $0.contains(currentEmail)})
            }
            
            guard let newData = spot.asDictionary() else {
                completion(false)
                return}
            
            ref.setData(newData, completion: {
                error in
                if error == nil {
                    switch state {
                    case .save:
                        print("saved to uses")
                        userRef.document(postId).setData(["valid": 1], completion: { error in
                            if error == nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                    case.unSaved:
                        print("unsaved from users")
                        userRef.document(postId).delete(completion: {
                            error in
                            completion(error == nil)
                            
                        })
                    }
                } else {
                    completion(false)
                }
            })
        })
    }
    
    
    public func findSpotId(with videoPrefix: String, completion: @escaping ([Post]) -> Void) {
        print("here")
        let videoPrefixLowercased = videoPrefix.lowercased()
        let ref = database.collection("posts")
        ref.whereField("nicknameLowercase", isGreaterThanOrEqualTo: videoPrefixLowercased).limit(to: 8).getDocuments(completion: { snapshot, error in
            guard let spots = snapshot?.documents.compactMap({ Post(with: $0.data()) }), error == nil else {
                print("completion: []")
                completion([])
                return
            }
            completion(spots)
        })
        
    }
    
    public func getAllClipsForSpot(for spot: String, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("spotId", isEqualTo: spot).whereField("postType", isEqualTo: "clip").limit(to: 10)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let clips = snapshot?.documents.compactMap({ Post(with: $0.data()) }), error == nil else {
                print("completion: []")
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(clips, lastSnapshot)
            self?.isPaginating = false
        })
    }
    
    public func continueGetClipsForSpot(for spot: String, lastDoc: DocumentSnapshot, completion: @escaping ([Post], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("posts").whereField("spotId", isEqualTo: spot).whereField("postType", isEqualTo: "clip").start(afterDocument: lastDoc).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let clips = snapshot?.documents.compactMap({ Post(with: $0.data()) }), error == nil else {
                print("completion: []")
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastSnapshot = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            completion(clips, lastSnapshot)
            self?.isPaginating = false
        })
    }
    
    public func grabASpot(with spot: String, completion: @escaping ([Post]) -> Void) {
        let ref = database.collection("posts").whereField("postType", isEqualTo: "spot").whereField("spotId", isEqualTo: spot)
        ref.getDocuments(completion: {
            snapshot, error in
            guard let spot = snapshot?.documents.compactMap({ Post(with: $0.data()) }), error == nil else {
                print("completion: []")
                completion([])
                return
            }
            completion(spot)
            
        })
    }
    
    
    
    //MARK: get profile header info
    
    public func getUsers(email: String, completion: @escaping ((followers: Int, following: Int)) -> Void) {
        let userRef = database.collection("users").document(email)

        var followers = 0
        var following = 0

        let group = DispatchGroup()
        group.enter()
        group.enter()

        userRef.collection("followers").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else { return
            }
            followers = count
        }
        userRef.collection("following").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else { return
            }
            following = count
        }
        group.notify(queue: .global()) {
            let result = (followers: followers, following: following)
            completion(result)
        }
    }
    
    public func setUserInfo(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        guard let data = userInfo.asDictionary() else {return}
        
        
        let ref = database.collection("users").document(email).collection("information").document("basic")
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func setUserInfoWithEmail(userInfo: UserInfo, email: String, completion: @escaping (Bool) -> Void) {
        guard let data = userInfo.asDictionary() else {return}
        let ref = database.collection("users").document(email).collection("information").document("basic")
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    
    
    
    
    
    
    //MARK: conversation functions
    
    public func checkIfConversationExistsInDatabase(email1: String, email2: String, completion: @escaping (String?) -> Void) {
        
        let string1 = "\(email1)_\(email2)"
        let string2 = "\(email2)_\(email1)"
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        let ref = database.collection("users").document(currentEmail).collection("conversations")
        ref.getDocuments { snapshot, error in
            guard let groups = snapshot?.documents.compactMap( { $0.documentID } ) else {
                completion(nil)
                return}
        
            let subset1 = groups.filter({ $0.hasPrefix(string1)} )
            let subset2 = groups.filter( { $0.hasPrefix(string2)} )
            let final = subset1 + subset2
            
            if final.isEmpty {
                completion(nil)
                return
            } else {
                completion(final.first)
            }
            
        
    }
    }
    
    

    
    
    public func pullAnExistingConversationId(username: String, email1: String, email2: String, completion: @escaping (String?) -> Void) {
        
        let string1 = "\(email1)_\(email2)"
        let string2 = "\(email2)_\(email1)"
        
        
        let ref = database.collection("users").document(username).collection("conversations")
        ref.getDocuments { snapshot, error in
            guard let groups = snapshot?.documents.compactMap( { $0.documentID } ) else {
                completion(nil)
                return}
            let subset1 = groups.filter({ $0.hasPrefix(string1)} )
            let subset2 = groups.filter( { $0.hasPrefix(string2)} )
            let final = subset1 + subset2
            guard !final.isEmpty  else {
                completion(nil)
                return
            }
            let chatId = final[0]
            
            completion(chatId)
            
    
        
    }
    }
    
    
    
    public func createNewConversation(with otherUserEmail: String, otherUsername: String, firstMessage: Message, chatId: String, completion: @escaping (Bool) -> Void) {
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return}
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {
            completion(false)
            return}
        
        let userRef = database.collection("users").document(currentEmail).collection("conversations").document(chatId)
        
        let convoRef = database.collection("conversations").document(chatId)
        
        let otherUserRef = database.collection("users").document(otherUserEmail).collection("conversations").document(chatId)
        
        guard let dateString = String.date(from: firstMessage.sentDate) as String? else {
            completion(false)
            return}
        
        let unixDate = NSDate().timeIntervalSince1970
        let dateNumString = String(unixDate)
        
        var message = ""
        
        switch firstMessage.kind {
        
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        
        let newConversationData: [String: Any] = [
            "id": "\(chatId)",
            "dateNum": dateNumString,
            "otherUserEmail": "\(otherUserEmail)",
            "otherUserName": "\(otherUsername)",
            "username2" : otherUsername,
            "sender": "\(currentEmail)",
            "isRead": false,
            "latestMessage": message,
            "date": dateString
    ]
        
        
        let messageForConvo: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "dateNum": dateNumString,
            "date": dateString,
            "senderUsername": currentUsername,
            "senderEmail": currentEmail,
            "isRead": false
        ]
        
        let newConversationDataOther: [String: Any] = [
            "id": "\(chatId)",
            "dateNum": dateNumString,
            "otherUserEmail": "\(currentEmail)",
            "otherUserName": "\(currentUsername)",
            "sender": "\(currentEmail)",
            "username2" : currentUsername,
            "isRead": false,
            "latestMessage": message,
            "date": dateString
    ]
        
        
        let value: [String: Any] = [
            "message": [
                messageForConvo
            ]
        ]
        
        userRef.setData(newConversationData, completion: { error in
            guard error == nil else {
                completion(false)
                return
            }
            
            otherUserRef.setData(newConversationDataOther, completion: {
                error in
                guard error == nil else {
                    completion(false)
                    return
                }
                convoRef.setData(value, completion: {
                    error in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
            })
            })
        })
    }
    
    public func getAllUserConversations(for email: String, completion: @escaping ([String]) -> Void) {
        var convos: [String] = []
        
        let ref = self.database.collection("users").document(email).collection("conversations")
        
        ref.getDocuments { snapshot, error in
            guard let groups = snapshot?.documents.compactMap({  $0.documentID }) else {
                return
            }
            groups.forEach  { group in
                convos.append(group)
            }
            completion(convos)
    }
    }
    
    
    public func getUnreadMessages(for user: String, completion: @escaping (Int) -> Void) {
        let ref = database.collection("users").document(user).collection("conversations").whereField("isRead", isEqualTo: false)
        ref.getDocuments(completion: { snapshot, error in
            if error == nil {
                guard let convos = snapshot?.documents.compactMap({  $0.data() }) else {
                    completion(0)
                    return
                }
                var count = 0
                print(convos)
                for convo in convos {
                
                    guard let sender = convo["sender"] as? String else {
                        return
                    }
                    if sender != user {
                        count += 1
                    }
                    
                }
                completion(count)
            }
        })
    }
    
    
    public func setUpListeners(group: String, email: String, completion: @escaping (Conversation) -> Void) {
        let ref = self.database.collection("users").document(email).collection("conversations")
        ref.document(group).addSnapshotListener { DocumentSnapshot, error in
            
            guard let data = DocumentSnapshot?.data() else {return}

            guard let id = data["id"] as? String else {return}
            guard let otherUserEmail = data["otherUserEmail"] as? String else {return}
            guard let message = data["latestMessage"] as? String else {return}
            guard let name = data["username2"] as? String else {return}
            guard let sender = data["sender"] as? String else {return}
            guard let otherUserName = data["otherUserName"] as? String else {return}
            guard let dateNum = data["dateNum"] as? String else {return}
            guard let isRead = data["isRead"] as? Bool else {return}
            guard let date = data["date"] as? String else {return}

            let latestMessage = LatestMessage(date: date, text: message, isRead: isRead)

            let convo = Conversation(id: id, name: name, otherUserEmail: otherUserEmail, otherUsername: name, latestmessage: latestMessage, sender: sender, isRead: isRead, dateNum: dateNum)
            completion(convo)
            
    }
    }
    
    public func getUserConvoForDelete(group: String, email: String, completion: @escaping (Conversation) -> Void) {
        let ref = self.database.collection("users").document(email).collection("conversations")
        ref.document(group).addSnapshotListener { DocumentSnapshot, error in

            guard let data = DocumentSnapshot?.data() else {return}

            guard let id = data["id"] as? String else {return}
            guard let otherUserEmail = data["otherUserEmail"] as? String else {return}
            guard let message = data["latestMessage"] as? String else {return}
            guard let name = data["username2"] as? String else {return}
            guard let sender = data["sender"] as? String else {return}
            guard let otherUserName = data["otherUserName"] as? String else {return}
            guard let dateNum = data["dateNum"] as? String else {return}
            guard let isRead = data["isRead"] as? Bool else {return}
            guard let date = data["date"] as? String else {return}

            let latestMessage = LatestMessage(date: date, text: message, isRead: isRead)

            let convo = Conversation(id: id, name: name, otherUserEmail: otherUserEmail, otherUsername: name, latestmessage: latestMessage, sender: sender, isRead: isRead, dateNum: dateNum)
            completion(convo)
            
        }
        
        
    }
    
    
    public func setUpListenerForCovo(with id: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("conversations").document(id)
        ref.addSnapshotListener { snapshot, error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    
    
    public func getAllMessagesForConvo(with id: String, completion: @escaping ([Message]) -> Void) {
        var messages: [Message] = []
    
        let ref = database.collection("conversations").document(id)
        
        let group = DispatchGroup()
        
        ref.getDocument { DocumentSnapshot, error in
            
            guard error == nil else {return}

            guard let data = DocumentSnapshot?.data() as? [String: Any] else {
                return}
            
            guard let dictionary = data["message"] as? [[String: Any]] else {
                return}
        
            
            for message in dictionary {
                group.enter()
                
                defer {
                    group.leave()
                }

                guard let isRead = message["isRead"] as? Bool else {
                    return
                }
                guard let messageId = message["id"] as? String else {
                    return
                }
                guard let content = message["content"] as? String else {
                    return
                }
                guard let senderEmail = message["senderEmail"] as? String else {
                    return
                }
                guard let type = message["type"] as? String else {
                    return
                }
                guard let dateString = message["date"] as? String else {
                    return
                }
                guard let senderUsername = message["senderUsername"] as? String else {
                    return
                }
                guard let date = DateFormatter.formatter.date(from: dateString) else {
                    return
                }
                guard let dateNum = message["dateNum"] else {return}
                
                var kind: MessageKind?
                
                if type == "photo" {
                    guard let imageUrl = URL(string: content) else {
                        return
                    }
                    guard let placeholder = UIImage(systemName: "photo") else {
                        return
                    }
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 200, height: 200))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoUrl = URL(string: content) else {
                        return
                    }
                    guard let placeholder = UIImage(systemName: "video") else {
                        return
                    }
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 200, height: 200))
                    kind = .video(media)
                    
                } else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else { return }
                
                let sender = sender(photoUrl: "", senderId: senderEmail, displayName: senderUsername)
                
                let sentMessage = Message(sender: sender, messageId: id, sentDate: date, kind: finalKind)
                messages.append(sentMessage)
                print("message appended")
                }
            
            group.notify(queue: .main, execute: {
                completion(messages)
                print(messages)
                print("completed")
                
            })
            }
        
        
        }
    
    public func sendMessage(to conversation: String, newMessage: Message, name: String,otherUserUsername: String, otherUserEmail: String, completion: @escaping (Bool) -> Void) {
        
        // add new message to messages
        //update sender last message
        //update recioeint last message
        
        
        self.database.collection("conversations").document(conversation).getDocument(completion: {
            [weak self] snapshot, error in
            
            guard let strongSelf = self else { return }
            
            guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
                                                                                        
            let group = DispatchGroup()
            
            guard error == nil else {
                completion(false)
                return
            }
            
            guard var currentMessages = snapshot?.data() as? [String: Any] else {return}
            guard var dictionary = currentMessages["message"] as? [[String: Any]] else {
                return}
            guard let dateString = String.date(from: newMessage.sentDate) as String? else {
                completion(false)
                return}
            
            var message = ""
            
            switch newMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
            
            let dateNum = NSDate().timeIntervalSince1970
            let dateNumString = String(dateNum)
            
            let messageForConvo: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "dateNum": dateNumString,
                "content": message,
                "date": dateString,
                "senderUsername": name,
                "senderEmail": currentEmail,
                "isRead": false
            ]
            
            dictionary.append(messageForConvo)
            
            currentMessages["message"] = dictionary
            
            strongSelf.database.collection("conversations").document(conversation).updateData(currentMessages, completion: {
                    error in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                
                let userRef = strongSelf.database.collection("users").document(currentEmail).collection("conversations").document(conversation)
                
                
                let otherUserRef = strongSelf.database.collection("users").document(otherUserEmail).collection("conversations").document(conversation)
                
                
                
                
                let newConversationDataOther: [String: Any] = [
                    "id": "\(conversation)",
                    "dateNum": dateNumString,
                    "otherUserEmail": "\(currentEmail)",
                    "otherUserName": "\(currentUsername)",
                    "username2" : currentUsername,
                    "sender": "\(currentEmail)",
                    "isRead": false,
                    "latestMessage": message,
                    "date": dateString
            ]
                
                let newConversationData: [String: Any] = [
                    "id": "\(conversation)",
                    "dateNum": dateNumString,
                    "otherUserEmail": "\(otherUserEmail)",
                    "otherUserName": "\(otherUserUsername)",
                    "username2" : otherUserUsername,
                    "sender": "\(currentEmail)",
                    "isRead": false,
                    "latestMessage": message,
                    "date": dateString
                    
                   
            ]
                
                userRef.setData(newConversationData, completion: { error in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    otherUserRef.setData(newConversationDataOther, completion: {
                        error in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                            completion(true)
                            
                        })
                })
                })
    }
)}
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        let ref = database.collection("users").document(email).collection("conversations").document(conversationId)
        ref.delete(completion: { error in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
            
        })
        
    }
    
    public func deletePostComment(comment: String, post: Post, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("posts").document(post.postId).collection("comments").whereField("comment", isEqualTo: comment)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            if error == nil {
                guard let comments = snapshot?.documents.compactMap({  $0.documentID }) else {
                    completion(false)
                    return
                }
                guard let firstCom = comments.first else {return}
                let ref = self?.database.collection("posts").document(post.postId).collection("comments").document(firstCom)
                ref?.delete(completion: { err in
                    completion(err == nil)
                })
            }
                
        })
    }
    
    public func deleteFullLengthPostComment(comment: String, video: FullLength, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("FullLengths").document(video.videoId).collection("comments").whereField("comment", isEqualTo: comment)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            if error == nil {
                guard let comments = snapshot?.documents.compactMap({  $0.documentID }) else {
                    completion(false)
                    return
                }
                guard let firstCom = comments.first else {return}
                let ref = self?.database.collection("posts").document(video.videoId).collection("comments").document(firstCom)
                ref?.delete(completion: { err in
                    completion(err == nil)
                })
            }
                
        })
    }
    
    
    
    public func deleteHalfOfMessages(convo: String, completion: @escaping (Bool) -> Void) {
    
        let ref = database.collection("conversations").document(convo)
        
        database.runTransaction( {
            (transaction, errorPointer) -> Any? in
            
            let messageDocument: DocumentSnapshot
                do {
                    try messageDocument = transaction.getDocument(ref)
                } catch let fetchError {
                    print(fetchError.localizedDescription)
                    completion(false)
                    return nil
                    
                }
            
            guard let data = messageDocument.data() as? [String: Any] else {
                completion(false)
                return nil}
            
            guard var dictionary = data["message"] as? [[String: Any]] else {
                completion(false)
                return nil}
            
            while dictionary.count > 50 {
                dictionary.removeFirst()
            }
            
            transaction.updateData(["message" : dictionary], forDocument: ref)
            completion(true)
            return nil
            
        }) { (object, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            print("success")
            
        }
            
    }
    
    
    
    public func updateMessageRead(convo: String, email: String, completion: @escaping (Bool) -> Void) {
        let ref = self.database.collection("users").document(email).collection("conversations")
        ref.document(convo).getDocument(completion:) { DocumentSnapshot, error in
            


            guard let data = DocumentSnapshot?.data() else {return}

            guard let id = data["id"] as? String else {return}
            guard let otherUserEmail = data["otherUserEmail"] as? String else {return}
            guard let latestMessage = data["latestMessage"] as? String else {return}
            guard let name = data["username2"] as? String else {return}
            guard let sender = data["sender"] as? String else {return}
            guard let otherUserName = data["otherUserName"] as? String else {return}
            guard let username2 = data["username2"] as? String else {return}
            guard let dateString = data["dateNum"] as? String else {return}
            guard var isRead = data["isRead"] as? Bool else {return}
            guard let date = data["date"] as? String else {return}
            
           
            
            isRead = true
            
            
            let newConversationDataOther: [String: Any] = [
                "id": "\(id)",
                "dateNum": dateString,
                "otherUserEmail": "\(otherUserEmail)",
                "otherUserName": "\(otherUserName)",
                "username2" : "\(username2)",
                "sender": "\(sender)",
                "isRead": isRead,
                "latestMessage": "\(latestMessage)",
                "date": "\(date)"
        ]
            
            let newConversationData: [String: Any] = [
                "id": "\(id)",
                "dateNum": dateString,
                "otherUserEmail": "\(otherUserEmail)",
                "otherUserName": "\(otherUserName)",
                "username2" : "\(username2)",
                "sender": "\(sender)",
                "isRead": isRead,
                "latestMessage": "\(latestMessage)",
                "date": "\(date)"
        ]
            
            ref.document(convo).setData(newConversationData, completion: { error in
                completion(error == nil)
            })
            
            
        }
        
    }
    
    
    //MARK: full lengths
    
    public func uploadFullLengthData(video: FullLength, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("FullLengths").document(video.videoId)
        guard let data = video.asDictionary() else {
            completion(false)
            return
        }
        ref.setData(data) { error in
            completion(error == nil)
        }
        
    }
    
    public func fetchFullLengths(completion: @escaping ([FullLength]?) -> Void) {
        let ref = database.collection("FullLengths")
        ref.getDocuments(completion: {
            snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data()) }), error == nil else {
                 completion(nil)
                 return
             }
            print(videos)
            completion(videos)
        })
    }
    
    public func fetchFullLengthsMostViewed(completion: @escaping ([FullLength], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").whereField("isAccepted", isEqualTo: true).order(by: "viewers", descending: true).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data() )}), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return}
            completion(videos, lastDoc)
            self?.isPaginating = false
        })
    }
    
    public func continueFetchFullLengthsMostViewed(lastDoc: DocumentSnapshot, completion: @escaping ([FullLength], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").whereField("isAccepted", isEqualTo: true).order(by: "viewers", descending: true).start(afterDocument: lastDoc).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data() )}), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return}
            completion(videos, lastDoc)
            self?.isPaginating = false
        })
    }
    
    
    
    
    public func fetchFullLengthsMostRecent(completion: @escaping ([FullLength], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").whereField("isAccepted", isEqualTo: true).order(by: "postedDateNum", descending: true).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data() )}), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
                
            }
            completion(videos, lastDoc)
            self?.isPaginating = false
        })
        
    }
    
    public func continueFetchingFullLengthsMostRecent(lastDoc: DocumentSnapshot, completion: @escaping ([FullLength], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").whereField("isAccepted", isEqualTo: true).order(by: "postedDateNum", descending: true).start(afterDocument: lastDoc).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data() )}), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
                
            }
            completion(videos, lastDoc)
            self?.isPaginating = false
        })
        
    }
    
    public func fetchFullLengthsForRegion(region: String, completion: @escaping ([FullLength], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").whereField("isAccepted", isEqualTo: true).whereField("region", isEqualTo: region).order(by: "postedDateNum", descending: true).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data() )}), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
                
            }
            completion(videos, lastDoc)
            self?.isPaginating = false
        })
        
    }
    
    public func continueFetchFullLengthsForRegion(region: String, lastDoc: DocumentSnapshot, completion: @escaping ([FullLength], DocumentSnapshot?) -> Void) {
        self.isPaginating = true
        let ref = database.collection("FullLengths").whereField("isAccepted", isEqualTo: true).whereField("region", isEqualTo: region).order(by: "postedDateNum", descending: true).start(afterDocument: lastDoc).limit(to: 5)
        ref.getDocuments(completion: {
            [weak self] snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data() )}), error == nil else {
                completion([], nil)
                self?.isPaginating = false
                return
            }
            guard let lastDoc = snapshot?.documents.last else {
                completion([], nil)
                self?.isPaginating = false
                return
                
            }
            completion(videos, lastDoc)
            self?.isPaginating = false
        })
    }
    
    
    public func findFullLengths(with videoPrefix: String, completion: @escaping ([FullLength]) -> Void) {
        print("here")
        let videoPrefixLowercased = videoPrefix.lowercased()
        let ref = database.collection("FullLengths")
        ref.whereField("isAccepted", isEqualTo: true).whereField("videoNameLowercased", isGreaterThanOrEqualTo: videoPrefixLowercased).limit(to: 8).getDocuments(completion: { snapshot, error in
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data()) }), error == nil else {
                print("completion: []")
                completion([])
                return
            }
            print(videos)
            let subset = videos.filter({
                $0.videoName.lowercased().hasPrefix(videoPrefix.lowercased())
            })
            print("subset: \(subset)")
            completion(subset)
        })
        
    }

    public func creatDistributedCounterForFullLength(for video: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("FullLengths").document(video).collection("views").document("views")
        let numShards = 10
        firestoreDistributedCounter.createCounter(ref: ref, numShards: numShards, completion: { result in
            switch result {
            
            case .success(_):
                print("success")
                completion(true)
            case .failure(_):
                print("failure")
                completion(false)
            }
        })
        
    }
    
    
    public func incrementFullLengthVideoCount(video: String) {
        let ref = database.collection("FullLengths").document(video).collection("views").document("views")
        firestoreDistributedCounter.incrementCounter(by: 1, ref: ref, numShards: 10, completion: { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                print("failure")
            }
        })

    }
    
    
    public func getTotalViewsForFullLength(for video: String, completion: @escaping (Int) -> Void) {
        let ref = database.collection("FullLengths").document(video).collection("views").document("views")
        firestoreDistributedCounter.getCount(ref: ref, completion: {
            result in
            switch result {
                
            case .success(let count):
                print(count)
                completion(count)
            case .failure(_):
                completion(0)
            }
        })
    }
    
    public func addLikeToArrayFullLength(for video: String, email: String) {
        let ref = database.collection("FullLengths").document(video).collection("likes").document("likes")
        firestoreDistributedArray.appendArray(with: email, ref: ref, numShards: 4, completion: { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                print("failure")
            }
        })
        
    }
    
    public func removeLikeFromArrayFullLength(for video: String, email: String) {
        let ref = database.collection("FullLengths").document(video).collection("likes").document("likes")
        firestoreDistributedArray.removeFromArray(with: email, ref: ref, numShards: 4, completion: { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                print("failure")
            }
        })
        
    }
    
    public func createDistributedLikeCounterForFullLength(for video: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("FullLengths").document(video).collection("likes").document("likes")
        let numShards = 4
        firestoreDistributedArray.createArrays(ref: ref, numShards: numShards, completion: { result in
            switch result {
            
            case .success(_):
                print("success")
                completion(true)
            case .failure(let error):
                print("failure to do it \(error.localizedDescription)")
                completion(false)
            }
        })
    
    }
    
    public func getTotalLikers(for video: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("FullLengths").document(video).collection("likes").document("likes")
        firestoreDistributedArray.getArrayCount(ref: ref, completion: {
            result in
            switch result {
            
            case .success(let likers):
                print("success")
                completion(likers)
            case .failure(_):
                print("failure")
                completion([])
            }
        })
        
    }
    
    public func updateFullLengthViewsForUser(email: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("FullLengths").whereField("posterEmail", isEqualTo: email).whereField("isAccepted", isEqualTo: true)
        ref.getDocuments(completion: { [weak self]snapshot, error in
            guard error == nil else {
                print("error")
                completion(false)
                return
            }
            guard let videos = snapshot?.documents.compactMap({ FullLength(with: $0.data() )}) else {
                completion(false)
                return
            }
            for video in videos {
                self?.getTotalViewsForFullLength(for: video.videoId, completion: {
                    [weak self] viewCount in
                    guard viewCount > video.viewers else {
                        print("view count not larger")
                        completion(false)
                        return
                    }
                    guard let ref = self?.database.collection("FullLengths").document(video.videoId) else {return}
                    ref.updateData(["viewers": viewCount])
                    
                })
            }
        })
        
        
    }
    
    //MARK: report posts
    
    
    public func reportPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let postData = post.asDictionary() else {
            completion(false)
            return
        }
        let ref = database.collection("ReportedPost").document(post.postId)
        ref.setData(postData) {
            error in
            completion(error == nil)
        }
    }
    
    public func reportIssue(issue: Issue, id: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("issues")
            .document(id)
        guard let issueData = issue.asDictionary() else {
            completion(false)
            return
            
        }
        ref.setData(issueData, completion: {
            error in
            completion(error == nil)
        })
    }
    
    
    //MARK: advertisements
    
    
    public func verifyAdvertisementAccount(password: String, email: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("advertisers").whereField("password", isEqualTo: password).whereField("email", isEqualTo: email.lowercased())
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                completion(false)
                return
            }
            guard let data = snapshot?.documents.compactMap({ $0.data() }) else {
                completion(false)
                return
            }
            if data.isEmpty {
                completion(false)
            } else {
                completion(true)
            }
            
        }
        
    }
    
    public func createAd(email: String, ad: Advertisement, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("ads").document(email)
        guard let data = ad.asDictionary() else {
            completion(false)
            return
        }
        ref.setData(data) {
            error in
            completion(error == nil)
        }
        
    }
    
    public func grabAllAds(completion: @escaping ([Advertisement]) -> Void) {
        let ref = database.collection("ads")
        ref.getDocuments(completion: { snapshot, error in
            if error == nil {
                guard let ads = snapshot?.documents.compactMap({ Advertisement(with: $0.data() )}) else {
                    completion([])
                    return
                }
                completion(ads)
            } else {
                print("error in getting ads")
                completion([])
               
            }
        })
        
    }
    
    public func grabAdForCompany(with email: String, completion: @escaping (Advertisement?) -> Void) {
        let ref = database.collection("ads").document(email)
        ref.getDocument(completion: { snapshot, error in
            if error == nil {
                guard let ad = snapshot?.data(), let advert = Advertisement(with: ad) else {
                    completion(nil)
                    return
                }
                completion(advert)
            } else {
                print("error getting ads")
            }
        })
    }
    
    
    //MARK: deletes
    
    
    
    public func deleteClipOrNormalPost(postId: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("posts").document(postId)
        ref.delete() { err in
            completion(err == nil)
        }
    }
    
    //MARK: block user
    
    public func blockUser(email: String, currentEmail: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(currentEmail).collection("blockedUsers").document("users")
        ref.getDocument(completion: {
            snapshot, error in
            guard error == nil else {
                print("error in getting blockUsers")
                completion(false)
                return
            }
            guard let data = snapshot?.data() else {
                let newStringArray: [String] = [email]
                let value = ["blocks" : newStringArray]
                ref.setData(value, completion: {
                    error in
                    completion(error == nil)
                })
                return
            }
            
            guard var blocks = data["blocks"] as? [String] else {
                completion(false)
                return
            }
            blocks.append(email)
            let newValue = ["blocks": blocks]
            ref.setData(newValue, completion: {
                error in
                completion(error == nil)
            })
        })
    }
    
    public func getBlockUsers(email: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users").document(email).collection("blockedUsers").document("users")
     
        ref.getDocument(completion: {
        snapshot, error in
        guard error == nil else {
            print("error in getting blockUsers")
            completion([])
            return
        }
        guard let data = snapshot?.data() else {
            print("empty completion")
            completion([])
            return
        }
        guard let blocks = data["blocks"] as? [String] else {
            print("mt completion")
            completion([])
            return
        }
        print(blocks)
        completion(blocks)
    })
        
    }
    
    public func removeBlockUser(email: String, currentEmail: String, completion: @escaping (Bool) -> Void) {
        let ref = database.collection("users").document(currentEmail).collection("blockedUsers").document("users")
        ref.getDocument(completion: {
            snapshot, error in
            guard error == nil else {
                print("error in getting blockUsers")
                completion(false)
                return
            }
            guard let data = snapshot?.data() else {
                completion(false)
                return
            }
            
            guard var blocks = data["blocks"] as? [String] else {
                completion(false)
                return
            }
           
            blocks.removeAll(where: { $0.contains(email)})
            let newValue = ["blocks": blocks]
            ref.setData(newValue, completion: {
                error in
                completion(error == nil)
            })
        })
        
    }
    
  
    
    
}




