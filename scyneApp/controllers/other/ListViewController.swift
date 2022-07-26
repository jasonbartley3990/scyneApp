//
//  ListViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import FirebaseFirestore

class ListViewController: UIViewController {
    
    enum ListType {
        case followers(user: User)
        case Following(user: User)
        case likers(username: [String])
        
        var title: String {
            switch self {
            case .followers:
                return "followers"
            case .Following:
                return "following"
            case .likers:
                return "liked by"
            }
        }
        
    }
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(ListUserTableViewCell.self, forCellReuseIdentifier: ListUserTableViewCell.identifier)
        return table
    }()
    
    private var blockedUsers: [String] = []
    
    let type: ListType
    
    init(type: ListType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        
       
    }
    
    private var viewModels: [ListUserTableViewCellViewModel] = []
    
    private var lastFollowerDocument: DocumentSnapshot?
    
    private var lastFollowingDocument: DocumentSnapshot?
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        title = type.title
        tableView.delegate = self
        tableView.dataSource = self
        configureViewModels()
        blockedUsers = infoManager.shared.blockUsers
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureViewModels() {
        switch type {
        case .likers(let usernames):
            viewModels = usernames.compactMap({
                ListUserTableViewCellViewModel(imageUrl: nil, username: $0)
            })
            tableView.reloadData()
        case .followers(let targetUser):
            
            DatabaseManager.shared.followers(for: targetUser.email) {
                [weak self] usernames, lastDocu in
                self?.lastFollowerDocument = lastDocu
                self?.viewModels = usernames.compactMap( { ListUserTableViewCellViewModel(imageUrl: nil, username: $0) })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        case .Following(let targetUser):
            DatabaseManager.shared.following(for: targetUser.email) {
                [weak self] usernames, lastDocu in
                self?.lastFollowingDocument = lastDocu
                self?.viewModels = usernames.compactMap( { ListUserTableViewCellViewModel(imageUrl: nil, username: $0) })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
    }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let tableViewHeight = tableView.contentSize.height
        if position > tableViewHeight - 100 - scrollView.frame.size.height {
            guard !DatabaseManager.shared.isPaginating else  {
                return
            }
            
            switch type {
            case .followers(let targetUser):
                guard let last = self.lastFollowerDocument else {return}
                
                DatabaseManager.shared.continueGettingFollowers(for: targetUser.email, lastDoc: last, completion: {
                    [weak self] usernames, lastDocu in
                    self?.lastFollowerDocument = lastDocu
                    let newViewModels = usernames.compactMap( { ListUserTableViewCellViewModel(imageUrl: nil, username: $0) })
                    guard let currentModels = self?.viewModels else {return}
                    self?.viewModels = currentModels + newViewModels
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    
                })
                
            case.Following(let targetUser):
                guard let last = self.lastFollowingDocument else {return}
                
                DatabaseManager.shared.continueGettingFollowing(for: targetUser.email, lastDoc: last, completion: {
                    [weak self] usernames, lastDocu in
                    self?.lastFollowingDocument = lastDocu
                    let newViewModels = usernames.compactMap( { ListUserTableViewCellViewModel(imageUrl: nil, username: $0) })
                    guard let currentModels = self?.viewModels else {return}
                    self?.viewModels = currentModels + newViewModels
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    
                })
            case .likers(_):
                break
            }
        }
            
    }
    
    private func userIsBlocked() {
        let ac = UIAlertController(title: "This user is blocked", message: "If you wish to see this profile unblock them", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
        
    }
    
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
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
