//
//  TabBarViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//
import UIKit

class TabBarViewController: UITabBarController {
    
    private var needToSignIn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let email = UserDefaults.standard.string(forKey: "email"), let username = UserDefaults.standard.string(forKey: "username") else {
            AuthManager.shared.signOut(completion: {
                [weak self] success in
                if success {
                    self?.needToSignIn = true
                }})
            return}
        
        
        let currentUser = User(username: username, email: email, region: nil)
        
        
        let home = HomeViewController()
        let world = WorldViewController()
        let recycle = ResaleViewController()
        let spotLight = SpotLightViewController()
        let profile = ProfileViewController(user: currentUser)
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: world)
        let nav3 = UINavigationController(rootViewController: recycle)
        let nav4 = UINavigationController(rootViewController: spotLight)
        let nav5 = UINavigationController(rootViewController: profile)
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        nav4.navigationBar.tintColor = .label
        nav5.navigationBar.tintColor = .label
        
        nav1.tabBarItem = UITabBarItem(title: "HOME", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "SPOTS", image: UIImage(systemName: "globe"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "RESALE", image: UIImage(systemName: "repeat"), tag: 1)
        nav4.tabBarItem = UITabBarItem(title: "FULL LENGTHS", image: UIImage(systemName: "tv"), tag: 1)
        nav5.tabBarItem = UITabBarItem(title: "profile", image: UIImage(systemName: "person.circle"), tag: 1)
        
        self.setViewControllers([nav1, nav2, nav3, nav4, nav5], animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                        // correct the transparency bug for Navigation bars
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        //send them to sign up view controller
        
        if needToSignIn == true {
            needToSignIn = false
            let vc = SignInViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
}
