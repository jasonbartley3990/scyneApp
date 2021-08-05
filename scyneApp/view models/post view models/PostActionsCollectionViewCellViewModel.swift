//
//  PostActionsCollectionViewCellViewModel.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation

struct PostActionsCollectionViewCellViewModel {
    let isLiked: Bool
    let likeCount: Int
    let viewCount: Int
    let post: Post
    let likers: [String]
}
