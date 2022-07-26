//
//  SearchResultsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol searchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewController(_ vc: searchresultsViewController, didSelectResultWith user: User)
}

class searchresultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var users = [User]()
    
    public weak var delegate: searchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        tableView.register(NoResultsTableViewCell.self, forCellReuseIdentifier: NoResultsTableViewCell.identifier)
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
    

    public func update(with results: [User]) {
        self.users = results
        
        if users.isEmpty {
            let noResult = User(username: "", email: "no results", region: nil)
            self.users.append(noResult)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.users[indexPath.row]
        if item.email == "no results" {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsTableViewCell.identifier, for: indexPath) as! NoResultsTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
            cell.configure(with: users[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.users[indexPath.row]
        if item.email == "no results" {
            return
        }
        delegate?.searchResultsViewController(self, didSelectResultWith: users[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}
