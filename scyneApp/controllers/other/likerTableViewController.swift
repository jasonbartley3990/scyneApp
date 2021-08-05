//
//  likerTableViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/14/21.
//

import UIKit

class likerTableViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(ListUserTableViewCell.self, forCellReuseIdentifier: ListUserTableViewCell.identifier)
        return table
    }()
    
    private var viewModels: [ListUserTableViewCellViewModel] = []
    
    private var likers = [String]()
    
    private var likeCount: Int
    
    private var likerUsernames = [String]()
    
    private var blockedUsers: [String] = []
    
    init(likers: [String], likeCount: Int) {
        self.likers = likers
        self.likeCount = likeCount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        title = "\(likeCount) likes"
        tableView.delegate = self
        tableView.dataSource = self
        findUsernames()
        configureViewModels()
        blockedUsers = infoManager.shared.blockUsers
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func findUsernames() {
        let group = DispatchGroup()
        
        for liker in likers {
            group.enter()
            DatabaseManager.shared.findUser(with: liker, completion: {
                [weak self] user in
                guard let userModel = user else {
                    group.leave()
                    return
                }
                let username = userModel.username
                self?.likerUsernames.append(username)
                group.leave()
            })
        }
        
        group.notify(queue: .main, execute: {
            self.configureViewModels()
        })
    }
    
    func configureViewModels() {
        self.viewModels = self.likerUsernames.compactMap( { ListUserTableViewCellViewModel(imageUrl: nil, username: $0) })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    private func userIsBlocked() {
        let ac = UIAlertController(title: "this user is blocked", message: "if you wish to see this profile unblock them", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(ac, animated: true)
    }

}

extension likerTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListUserTableViewCell.identifier, for: indexPath) as? ListUserTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let username = viewModels[indexPath.row].username
        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            if let user = user {
                guard let isBlocked = self?.blockedUsers.contains(user.email) else {return}
                if isBlocked {
                    self?.userIsBlocked()
                    return
                }
                
                DispatchQueue.main.async {
                    let vc = ProfileViewController(user: user)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
