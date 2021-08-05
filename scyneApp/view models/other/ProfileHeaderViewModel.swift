//
//  ProfileHeaderViewModel.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation

enum ProfileButtonType {
    case edit
    case follow(isFollowing: Bool)
}

struct ProfileHeaderViewModel {
    let profilePictureUrl: URL?
    var followerCount: Int
    var followingCount: Int
    let buttonType: ProfileButtonType
    var clipCount: Int
    let name: String?
    let bio: String?
    let webLink: String
}
