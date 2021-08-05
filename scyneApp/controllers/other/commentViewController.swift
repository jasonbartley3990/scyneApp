//
//  commentViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/6/21.
//

import UIKit
import FirebaseFirestore

class commentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        return table
    }()
    
    private let post: Post
    
    private var comments = [Comment]()
    
    private var lastComment: DocumentSnapshot?
    
    private var blockedUsers: [String] = []
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "comments"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        fetchComments()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapMakeComment))
        blockedUsers = infoManager.shared.blockUsers
       
    }
    
    private func fetchComments() {
        DatabaseManager.shared.getCommentsForPost(post: post, completion: {
            [weak self] comments, lastDoc in
            print("got here")
            print(comments)
            self?.lastComment = lastDoc
            var filteredComments = comments
            for (index, post) in filteredComments.enumerated() {
                guard let isBlocked = self?.blockedUsers.contains(post.posterEmail) else {return}
                if isBlocked {
                    filteredComments.remove(at: index)
                }
            }
            self?.comments = filteredComments
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }
    
    @objc func didTapMakeComment() {
        let vc = createCommentViewController(post: self.post)
        vc.completion  = { [weak self] in
            self?.fetchComments()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
            fatalError()
        }
        let commentMade = comments[indexPath.row]
        let vm = CommentViewModel(poster: commentMade.poster, posterEmail: commentMade.posterEmail, comment: commentMade.comment)
        cell.configure(with: vm)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedComment = comments[indexPath.row]
        
        let vc = commentDetailViewController(comment: selectedComment)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let tableViewHeight = tableView.contentSize.height
        if position > tableViewHeight - 100 - scrollView.frame.size.height {
            print("aye we lit")
            
            guard !DatabaseManager.shared.isPaginating else  {
                return
            }
            
            guard let lastCom = self.lastComment else {return}
            
            DatabaseManager.shared.continueGetCommentsForPost(post: self.post, lastDoc: lastCom, completion: {
                [weak self] comments, lastDoc in
                self?.lastComment = lastDoc
                guard let previousCom = self?.comments else {return}
                var filteredComments = comments
                for (index, post) in filteredComments.enumerated() {
                    guard let isBlocked = self?.blockedUsers.contains(post.posterEmail) else {return}
                    if isBlocked {
                        filteredComments.remove(at: index)
                    }
                }
                self?.comments = previousCom + filteredComments
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
            
        }
        }
    
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let comm = comments[indexPath.row].comment
    
                tableView.beginUpdates()
    
                DatabaseManager.shared.deletePostComment(comment: comm, post: self.post, completion: { [weak self] success in
                    if success {
                        self?.comments.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self?.tableView.deleteRows(at: [indexPath], with: .left)
                        }
                    }
                })
    
                tableView.endUpdates()
            }
        }
    
    

}
