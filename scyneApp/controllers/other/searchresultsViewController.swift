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
        tableView.isHidden = true
        tableView.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    

    public func update(with results: [User]) {
        self.users = results
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.isHidden = self.users.isEmpty
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
        //cell.textLabel?.text = users[indexPath.row].username
        cell.configure(with: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewController(self, didSelectResultWith: users[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}
