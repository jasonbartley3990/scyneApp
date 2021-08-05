//
//  spotModel.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation

struct SpotModel: Codable {
    let location: String
    let spotPhotoUrl: [String]
    let spotType: String
    let nickName: String
    let postedBy: String
    let latitude: Double
    let longitude: Double
    let spotId: String
    var savers: [String]
    let spotInfo: String
    let isSaved: Bool
}
