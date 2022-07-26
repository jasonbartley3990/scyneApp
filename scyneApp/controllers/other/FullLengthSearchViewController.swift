//
//  FullLengthViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import AVKit

class FullLengthSearchViewController: UIViewController, UISearchResultsUpdating {
    
    private let searchVC = UISearchController(searchResultsController: scyneApp.FullLengthSearchResultsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        (searchVC.searchResultsController as? FullLengthSearchResultsViewController)?.delegate = self
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = "Search For Videos"
        navigationItem.searchController = searchVC
    }
    
    

    func updateSearchResults(for searchController: UISearchController) {
        guard let vc = searchController.searchResultsController as? FullLengthSearchResultsViewController, let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        DatabaseManager.shared.findFullLengths(with: query) { results in
            DispatchQueue.main.async {
                vc.update(with: results)
            }
        }
    }
}


extension FullLengthSearchViewController: FullLengthSearchResultsViewControllerDelegate {
    func FullLengthSearchResultsViewController(_ vc: FullLengthSearchResultsViewController, didSelectVideoWith video: FullLength) {
        guard let vidurl = URL(string: video.videoUrlString) else {return}

        let player = AVPlayer(url: vidurl)
        let vcPlayer = AVPlayerViewController()
        vcPlayer.player = player
        vcPlayer.player?.playImmediately(atRate: 1.0)
        self.present(vcPlayer, animated: true, completion: nil)
        
        DatabaseManager.shared.incrementFullLengthVideoCount(video: video.videoId)
    }
}

    
