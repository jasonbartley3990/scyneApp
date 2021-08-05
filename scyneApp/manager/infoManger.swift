//
//  infoManger.swift
//  scyneApp
//
//  Created by Jason bartley on 7/15/21.
//

import Foundation

final class infoManager {
    static let shared = infoManager()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChangeBlock), name: Notification.Name("userDidChangeBlock"), object: nil)
        
    }
    
    public var blockUsers: [String] = []
    
    @objc private func userDidChangeBlock() {
        print("was blocked and called")
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        DatabaseManager.shared.getBlockUsers(email: currentEmail, completion: {
            [weak self] users in
            self?.blockUsers = users
        })
        
    }
}

