//
//  HapticsManager.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation
import UIKit
import CoreHaptics

final class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    public func buttonHaptic() {
        DispatchQueue.main.async {
            let selectionFeedbackgenerator = UISelectionFeedbackGenerator()
            selectionFeedbackgenerator.prepare()
            selectionFeedbackgenerator.selectionChanged()
        }
    }
    
    
    
}
