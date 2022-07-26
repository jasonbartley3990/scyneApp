//
//  SpotIdSearchViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/7/21.
//

import UIKit

class SpotIdSearchViewController: UIViewController, UISearchResultsUpdating, SpotIdSearchResultsViewControllerDelegate {
    
    
    let searchVC = UISearchController(searchResultsController: scyneApp.SpotIdSearchResultsViewController())
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        (searchVC.searchResultsController as? SpotIdSearchResultsViewController)?.delegate = self
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = "Search For Spots"
        navigationItem.searchController = searchVC
            
            
    
       
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let vc = searchController.searchResultsController as? SpotIdSearchResultsViewController, let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        DatabaseManager.shared.findSpotId(with: query) { results in
            DispatchQueue.main.async {
                vc.update(with: results)
            }
        }
        
    }
    
    func SpotIdSearchResultsViewController(_ vc: SpotIdSearchResultsViewController, didSelectSpotWith spot: Post) {
        guard let spotIdent = spot.spotId else {return}
        let vc = ClipUploaderViewController(urls: [], spot: spotIdent)
        navigationController?.pushViewController(vc, animated: true)
        
    }
   

}
