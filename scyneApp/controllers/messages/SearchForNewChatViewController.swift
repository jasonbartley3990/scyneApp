//
//  SearchForNewChatViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/13/21.
//

import UIKit
import JGProgressHUD

class SearchForNewChatViewController: UIViewController {
    
    public var completion: ((User) -> (Void))?
    
    private let searchVC = UISearchController(searchResultsController: searchresultsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        (searchVC.searchResultsController as? searchresultsViewController)?.delegate = self
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = "Search For Users..."
        navigationItem.searchController = searchVC
    }
}

extension SearchForNewChatViewController: searchResultsViewControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let vc = searchController.searchResultsController as? searchresultsViewController, let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        DatabaseManager.shared.findUsers(with: query) { results in
            DispatchQueue.main.async {
                vc.update(with: results)
            }
        }
    }

    func searchResultsViewController(_ vc: searchresultsViewController, didSelectResultWith user: User) {
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(user)
        })
    }
}

    


