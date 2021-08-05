//
//  SearchViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//
import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    private let searchVC = UISearchController(searchResultsController: searchresultsViewController())
    
    private var blockedUsers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        (searchVC.searchResultsController as? searchresultsViewController)?.delegate = self
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = "search for users"
        navigationItem.searchController = searchVC
        blockedUsers = infoManager.shared.blockUsers
        
        // Do any additional setup after loading the view.
    }
    
    

    func updateSearchResults(for searchController: UISearchController) {
        guard let vc = searchController.searchResultsController as? searchresultsViewController, let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        DatabaseManager.shared.findUsers(with: query.lowercased()) { results in
            DispatchQueue.main.async {
                vc.update(with: results)
            }
        }
    }
    
    private func userIsBlocked() {
        let ac = UIAlertController(title: "this user is blocked", message: "if you wish to see this profile unblock them", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
}


extension SearchViewController: searchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: searchresultsViewController, didSelectResultWith user: User) {
        let isBlocked = blockedUsers.contains(user.email)
        if isBlocked {
            userIsBlocked()
            return
        }
        
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
