//
//  settingsModels.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation
import UIKit

struct settingsSection {
    let title: String
    let options : [settingOption]
}

struct settingOption {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler: (() -> Void)
}
