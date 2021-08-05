//
//  AuthManager.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//


import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    let auth = Auth.auth()
    
    enum AuthError: Error {
        case newUserCreation
        case signInFailed
    }
    
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    public func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try auth.signOut()
            completion(true)
        } catch {
            print(error)
            completion(false)
        }
        
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        DatabaseManager.shared.findUser(with: email) {
            [weak self] user in
            guard let user = user else {
                completion(.failure(AuthError.signInFailed))
                return
            }
            
            self?.auth.signIn(withEmail: email, password: password) {
                result, error in
                guard result != nil, error == nil else {
                    completion(.failure(AuthError.signInFailed))
                    return
                }
                UserDefaults.standard.setValue(user.username, forKey: "username")
                UserDefaults.standard.setValue(user.email, forKey: "email")
                UserDefaults.standard.setValue(user.region, forKey: "region")
                completion(.success(user))
            }
            
        
        
        
    }
    }
    
    public func signUp(email: String, userName: String, password: String, profilePicture: Data?, region: String, completion: @escaping (Result<User, Error>) -> Void) {
        let newUser = User(username: userName, email: email, region: region)
        
        auth.createUser(withEmail: email, password: password) {
            result, error in
            guard result != nil, error == nil else {
                completion(.failure(AuthError.newUserCreation))
                return
            }
            DatabaseManager.shared.createUser(newuser: newUser) {
                success in
                if success {
                    StorageManager.shared.uploadProfilePicture(email: email, data: profilePicture) {
                        uploadSuccess in
                        if uploadSuccess {
                            completion(.success(newUser))
                        } else {
                            completion(.failure(AuthError.newUserCreation))
                        }
                    }
                }
                else {
                    completion(.failure(AuthError.newUserCreation))
                }
            }
        }
    }
    
    
    
}
