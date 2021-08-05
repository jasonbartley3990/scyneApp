//
//  fullLength.swift
//  scyneApp
//
//  Created by Jason bartley on 5/20/21.
//

import Foundation

struct FullLength: Codable {
    let poster: String
    let posterEmail: String
    let videoId: String
    let videoName: String
    let videoNameLowercased: String
    let thumbnailString: String
    let videoUrlString: String
    var likers: [String]
    let region: String
    var viewers: Int
    let postedDate: String
    let postedDateNum: Double
    let caption: String
    let isAccepted: Bool
}
