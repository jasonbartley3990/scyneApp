//
//  StorageManager.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    let storage = Storage.storage().reference()
    
    public func uploadProfilePicture(email: String, data: Data?, completion: @escaping (Bool) -> Void) {
        guard let data = data else {return}
        storage.child("\(email)/profile_picture.png").putData(data, metadata: nil) {
            _, error in
            completion(error == nil)
        }
    }
    
    public func uploadPost(data: Data?, id: String, completion: @escaping (URL?) -> Void) {
        guard let data = data else {return}
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let ref = storage.child("\(username)/posts/\(id).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
        }
    }
    }
    
    public func uploadItem(data: Data?, id: String, completion: @escaping (URL?) -> Void) {
        guard let data = data else {return}
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let ref = storage.child("\(username)/items/\(id).png")
        ref.putData(data, metadata: nil) {
            _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
        
        
    }
    
    public func uploadSpot(data: Data?, id: String, completion: @escaping (URL?) -> Void) {
        guard let data = data else {return}
        let ref = storage.child("spots/\(id).png")
        ref.putData(data, metadata: nil) {
            _, error in
            ref.downloadURL {
                url, _ in
                completion(url)
            }
        }
    }
    
    public func downloadUrl(for post: Post, completion: @escaping (URL?) -> Void) {
        guard let ref = post.storageReference else {
            return completion(nil)
        }
        storage.child(ref).downloadURL {
            url, _ in
            completion(url)
        }
    }
    
    public func profilePictureUrl(for email: String, completion: @escaping (URL?) -> Void) {
        storage.child("\(email)/profile_picture.png").downloadURL {
            url, _ in
            completion(url)
        }
    }
    
    public func profilePictureUrlUsername(forUsername: String, completion: @escaping (URL?) -> Void) {
        DatabaseManager.shared.findUser(username: forUsername, completion: {
            user in
            guard let user = user else {
                completion(nil)
                return
            }
            StorageManager.shared.profilePictureUrl(for: user.email, completion: {
                url in
                guard let url = url else {
                    completion(nil)
                    return
                }
                completion(url)
            })
        })
    }
    
    public func uploadMessagePhoto(with data: Data, convoId: String, filename: String, completion: @escaping (URL?) -> Void) {
        let ref = storage.child("\(convoId)/\(filename).png")
        ref.putData(data, metadata: nil, completion: {
            _, error in
            guard error == nil else {
                completion(nil)
                return
            }
            ref.downloadURL { url, _ in
                completion(url)
            }
        })
        
    }
    
    public func uploadMessageVideo(with url: URL, convoId: String, filename: String, completion: @escaping (URL?) -> Void) {
        let ref = storage.child("\(convoId)/\(filename).mov")
        
        if let videoData = NSData(contentsOf: url) as Data? {
            ref.putData(videoData, metadata: nil, completion: {
                _, error in
                guard error == nil else {
                    print("there is an error")
                    completion(nil)
                    return}
                ref.downloadURL { url, _ in
                    completion(url)
                }
            })
        } else {
            completion(nil)
        }
    }
    
    public func uploadClipUrl(with url: URL, postId: String, email: String, completion: @escaping (URL?) -> Void) {
        let ref = storage.child("\(email)/\(postId).mov")
        
        if let videoData  = NSData(contentsOf: url) as Data? {
            ref.putData(videoData, metadata: nil, completion: {
                _, error in
                guard error == nil else {
                    print("there was an error")
                    completion(nil)
                    return }
                ref.downloadURL { url, error in
                    completion(url)
                }
            })
        } else {
            completion(nil)
        }
    }
    
    public func uploadClipThumbnail(with data: Data, postId: String, email: String, completion: @escaping (URL?) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let ref = storage.child("\(username)/posts/\(postId)thumbnail.png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
        
    }
    
    
    public func uploadFullLength(with url: URL, videoId: String, completion: @escaping (URL?) -> Void) {
        let ref = storage.child("FullVideos/\(videoId).mov")
        
        if let videoData = NSData(contentsOf: url) as Data? {
            ref.putData(videoData, metadata: nil, completion: {
                _, error in
                guard error == nil else {
                    print("there was an error")
                    return
                }
                ref.downloadURL { url, _ in
                    completion(url)
                }
            })
        } else {
            completion(nil)
        }
    }
    
    public func uploadFullLengthThumbnail(with data: Data, filename: String, completion: @escaping (URL?) -> Void) {
        let ref = storage.child("FullVideoThumbnails/\(filename).png")
        ref.putData(data, metadata: nil, completion: {
            _, error in
            guard error == nil else {
                completion(nil)
                print("error")
                return
            }
            ref.downloadURL { url, _ in
                completion(url)
            }
        })
    }
    
    public func fetchFullLengthThumbNail(for video: String, completion: @escaping (URL?) -> Void) {
        print(video)
        storage.child("FullVideoThumbnails/\(video).png").downloadURL {
            url, error in
            completion(url)
        }
    }
    
    public func uploadAdVideo(for url: URL, id: String, completion: @escaping (URL?) -> Void) {
        let ref = storage.child("Ads/\(id).mov")
        
        if let videoData  = NSData(contentsOf: url) as Data? {
            ref.putData(videoData, metadata: nil, completion: {
                _, error in
                guard error == nil else {
                    print("there was an error")
                    completion(nil)
                    return }
                ref.downloadURL { url, error in
                    completion(url)
                }
            })
        } else {
            completion(nil)
        }
        
    }
    
    public func uploadAdPhoto(with data: Data, postId: String, completion: @escaping (URL?) -> Void) {
        
        let ref = storage.child("Ads/\(postId).png")
        
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
        
        
    }
    
    
    
    public func uploadCompanyLogo(with data: Data, logoId: String, email: String, completion: @escaping (URL?) -> Void) {
        
        let ref = storage.child("Logos/\(logoId).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
        
        
    }
    
}

