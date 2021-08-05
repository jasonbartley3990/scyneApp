//
//  advertisement.swift
//  scyneApp
//
//  Created by Jason bartley on 6/10/21.
//

import Foundation

struct Advertisement: Codable {
    let company: String
    let adType: String
    let productLink: String
    let companyLink: String
    let productLinkLabel: String
    let Urls: [String]
    let urlCount: Int
    let caption: String
    let companyPhoto: String
    
}
