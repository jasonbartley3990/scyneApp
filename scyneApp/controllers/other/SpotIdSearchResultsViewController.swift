//
//  SpotIdSearchResultsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/7/21.
//

import UIKit

protocol SpotIdSearchResultsViewControllerDelegate: AnyObject {
    func SpotIdSearchResultsViewController(_ vc: SpotIdSearchResultsViewController, didSelectSpotWith spot: Post)
}

class SpotIdSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var spots = [Post]()
    
    public weak var delegate: SpotIdSearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(spotTableViewCell.self, forCellReuseIdentifier: spotTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    public func update(with results: [Post]) {
        self.spots = results
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.isHidden = self.spots.isEmpty
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        spots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: spotTableViewCell.identifier, for: indexPath) as! spotTableViewCell
        cell.configure(with: spots[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.SpotIdSearchResultsViewController(self, didSelectSpotWith: spots[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }


    

}
