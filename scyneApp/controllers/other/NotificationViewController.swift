//
//  NotificationViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/25/21.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        return table
    }()
    
    private let noFollowsLabel: UILabel = {
        let label = UILabel()
        label.text = "no follows"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var notifications = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "FOLLOWS"
        view.addSubview(tableView)
        view.addSubview(noFollowsLabel)
        tableView.delegate = self
        tableView.dataSource = self
        fetchFollows()
       
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        noFollowsLabel.frame = CGRect(x: 10, y: (view.height - 50)/2, width: view.width - 20, height: 50)
        
    }
    
    
    private func fetchFollows() {
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        DatabaseManager.shared.getFollowNotification(email: currentEmail, completion: {
            [weak self] users in
            if users.count == 0 {
                DispatchQueue.main.async {
                    self?.tableView.isHidden = true
                    self?.noFollowsLabel.isHidden = false
                }
            }
            self?.notifications = users.reversed()
            if users.count > 150 {
                
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell else {
            fatalError()
        }
        let notif = notifications[indexPath.row]
        cell.configure(with: notif)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPerson = notifications[indexPath.row]
        
        DatabaseManager.shared.findUser(username: selectedPerson, completion: {
            [weak self] user in
            guard let person = user else {return}
            
            let vc = ProfileViewController(user: person)
            self?.navigationController?.pushViewController(vc, animated: true)
            
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
