//
//  urlOpener.swift
//  scyneApp
//
//  Created by Jason bartley on 6/23/21.
//

import Foundation
import UIKit

final class urlOpener {
    static let shared = urlOpener()
    
    public func verifyUrl (urlString: String?) -> Bool {
       if let urlString = urlString {
           if let url = NSURL(string: urlString) {
               return UIApplication.shared.canOpenURL(url as URL)
           }
       }
       return false
   }
    
}
