//
//  spotAnnotation.swift
//  scyneApp
//
//  Created by Jason bartley on 5/9/21.
//

import Foundation
import MapKit

class spotAnnotation: NSObject, MKAnnotation {
    let title: String?
    let model: Post
    let spotType: String
    let coordinate: CLLocationCoordinate2D
    
    static let identifier = "spotIdentifier"
    
    init(nickName: String, spottype: String, model: Post, coordinate: CLLocationCoordinate2D) {
        self.title = nickName
        self.spotType = spottype
        self.model = model
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return spotType
    }
    
    
    
    var markerTintColor: UIColor {
        switch spotType {
        case "skatepark":
            return .red
        case "plaza":
            return .green
        case "DIY":
            return .brown
        case "school":
            return .orange
        default:
            return .blue
        }
    }
    
    var imageName: String? {
        switch spotType {
        case "skatepark":
            return "house.fill"
        case "DIY":
            return "hammer"
        case "plaza":
            return "p.circle.fill"
        case "stairs":
            return "s.circle.fill"
        case "school":
            return "building.columns.fill"
        case "ledge":
            return "cube.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    
}
