//
//  BlockedUsesViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 7/16/21.
//

import UIKit

class BlockedUsesViewController: UIViewController {
    
    private var blockedUsers: [String] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = false
        tableView.register(blockUserTableViewCell.self, forCellReuseIdentifier: blockUserTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        title = "blocked users"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        DatabaseManager.shared.getBlockUsers(email: currentEmail, completion: {
            [weak self] users in
            self?.blockedUsers = users
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            
        })
        
    }
    
    

    

}

extension BlockedUsesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: blockUserTableViewCell.identifier, for: indexPath) as! blockUserTableViewCell
        cell.configure(with: blockedUsers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "unblock this user", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "unblock", style: .default, handler: {
            [weak self] _ in
            guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
            guard let currentBlockUser = self?.blockedUsers[indexPath.row] else {return}
            DatabaseManager.shared.removeBlockUser(email: currentBlockUser , currentEmail: currentEmail, completion: {
                [weak self] success in
                NotificationCenter.default.post(name: Notification.Name("userDidChangeBlock"), object: nil)
            })
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    
}
