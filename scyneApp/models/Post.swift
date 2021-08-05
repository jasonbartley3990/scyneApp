//
//  Post.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation
import FirebaseFirestore

struct Post: Codable {
    let posterEmail: String
    let posterUsername: String
    let postType: String
    let region: String
    let postId: String
    let postedDateString: String
    let postedDateNum: Double
    let caption: String?
    let photoUrls : [String]
    let urlCount: Int
    var savers : [String]
    let spotType: String?
    let itemType: String?
    let askingPrice: String?
    let latitude: Double?
    let longitude: Double?
    let floorLong: Int?
    let nickname: String?
    let nicknameLowercase: String?
    let address: String?
    let spotId: String?
    let viewers: Int?
    let videoThumbnail: String?
    
    
    var date: Date {
        print(DateFormatter.formatter.date(from: postedDateString) ?? Date())
        return DateFormatter.formatter.date(from: postedDateString) ?? Date()
    }
    
    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else {return nil}
        return "\(username)/posts/\(postId).png"
    }
    
}
