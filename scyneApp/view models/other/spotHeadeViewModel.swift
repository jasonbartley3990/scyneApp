//
//  spotHeadeViewModel.swift
//  scyneApp
//
//  Created by Jason bartley on 5/10/21.
//

import Foundation

struct SpotHeaderViewModel {
    let spotPictureUrl: [String]
    let spotNickname: String
    let spotUploader: String
    let address: String
    var isSaved: Bool
    let post: Post
    let numberOfPics: Int
    
}
