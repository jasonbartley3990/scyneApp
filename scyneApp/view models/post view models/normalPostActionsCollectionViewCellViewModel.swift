//
//  normalPostActionsCollectionViewCellViewModel.swift
//  scyneApp
//
//  Created by Jason bartley on 6/8/21.
//

import Foundation

struct normalPostActionsCollectionViewCellViewModel {
    let isLiked: Bool
    let likeCount: Int
    let post: Post
    let likers: [String]
    let numberOfPhotos: Int
}

