//
//  messageRoomListViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/13/21.
//

import UIKit
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let otherUsername: String
    let latestmessage: LatestMessage
    let sender: String
    let isRead: Bool
    let dateNum: String
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class messageRoomListViewController: UIViewController {
    
    private var conversations = [Conversation]()
    
    private var conversationsForDelete = [Conversation]()
    
    private var fetchedConversations = 0
    
    private var fetchedConversationsForDelete = 0
    
    private var fetchNumber = 0
    
    private var fetchedNumberForDelete = 0
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        table.isHidden = false
        return table
    }()
    
    private let noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "no conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let spinner = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        
        
        setUpTableView()
        startListeningForConversations()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationLabel.frame = CGRect(x: 10, y: (view.height - 50)/2, width: view.width - 20, height: 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startListeningForConversations()
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func startListeningForConversations() {
        
        let group = DispatchGroup()
        
        var userConvos: [String] = []
        var loadedConvos: [Conversation] = []
        var loadedConvosForDelete: [Conversation] = []

        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        group.enter()
        DatabaseManager.shared.getAllUserConversations(for: email, completion: { [weak self] convos in
            
            if convos.count > 95 {
                self?.fetchedNumberForDelete = convos.count
                group.leave()
                
                
                let dispatchGroupForDelete = DispatchGroup()
                var finishLoadsForDelete = 0 {
                    didSet {
                        print(finishLoadsForDelete)
                        self?.fetchedConversationsForDelete = finishLoadsForDelete
                        guard let fetchNum = self?.fetchedNumberForDelete else {return}
                        if finishLoadsForDelete > fetchNum {
                            print("made it")
                        } else {
                            dispatchGroupForDelete.leave()
                        }
                    }
                }
                
                guard self?.fetchedNumberForDelete != 0 else {return}
                
                
                for  _ in 1...convos.count {
                    dispatchGroupForDelete.enter()
                }
                
                for convo in convos {
                    DatabaseManager.shared.getUserConvoForDelete(group: convo, email: email, completion: { conversation in
                        loadedConvosForDelete.append(conversation)
                        finishLoadsForDelete += 1
                    })
                }
                
                dispatchGroupForDelete.notify(queue: .main, execute: {
                    self?.conversationsForDelete = loadedConvosForDelete.sorted(by: { first, second in
                        var date1: Double?
                        var date2: Double?
                        date1 = Double(first.dateNum)
                        date2 = Double(second.dateNum)
                        if let date1 = date1, let date2 = date2 {
                            return date1 > date2
                        }
                        return false
                    })
                    
                    guard var convoForDeleteNum = self?.conversationsForDelete.count else {return}
                    
                    while convoForDeleteNum > 75 {
                        let oldConvo = self?.conversationsForDelete.last
                        self?.conversationsForDelete.removeLast()
                        guard let convoIdent = oldConvo?.id else {return}
                        convoForDeleteNum -= 1
                        DatabaseManager.shared.deleteConversation(conversationId: convoIdent, completion: {
                            success in
                            if success {
                               print("success")
                            }
                        })
                        
                    }
                    
                    self?.startListeningForConversations()
                    return
                })
                
            } else {
            
                userConvos = convos
                group.leave()
                guard !userConvos.isEmpty else {
                    DispatchQueue.main.async {
                        self?.tableView.isHidden = true
                        self?.noConversationLabel.isHidden = false
                    }
                    return
                }
                
                self?.tableView.isHidden = false
                self?.noConversationLabel.isHidden = true
                
                group.notify(queue: .main, execute: {
                    
                    self?.fetchNumber = userConvos.count
                    
                    let dispatchGroup = DispatchGroup()
                    var finishLoads = 0 {
                        didSet {
                            print(finishLoads)
                            self?.fetchedConversations = finishLoads
                            guard let fetchedNum = self?.fetchNumber else {return}
                            if finishLoads > fetchedNum {
                                print("made it")
                            } else {
                                dispatchGroup.leave()
                            }
                        }
                    }
                    
                    guard self?.fetchNumber != 0 else {return}
                    guard let fetchNumListener = self?.fetchNumber else {return}
                    
                    for  _ in 1...fetchNumListener {
                        dispatchGroup.enter()
                    }
                    
                    for convo in userConvos {
                        DatabaseManager.shared.setUpListeners(group: convo, email: email, completion: { conversation in
                            loadedConvos.append(conversation)
                            finishLoads += 1
                            
                        })
                    }
                    
                    dispatchGroup.notify(queue: .main, execute: {
                        self?.conversations = loadedConvos.sorted(by: { first, second in
                            var date1: Double?
                            var date2: Double?
                            date1 = Double(first.dateNum)
                            date2 = Double(second.dateNum)
                            if let date1 = date1, let date2 = date2 {
                                return date1 > date2
                            }
                            return false
                        })
                        self?.tableView.reloadData()
                    })
                    
                })
            }
        })
    }
        
    
    
    @objc func didTapSearch() {
        let vc = SearchForNewChatViewController()
        navigationController?.pushViewController(vc, animated: true)
        vc.completion = { [weak self] otherUser in
            guard let email1 = UserDefaults.standard.string(forKey: "email") else {return}
            let email2 = otherUser.email
            
            DatabaseManager.shared.checkIfConversationExistsInDatabase(email1: email1, email2: email2, completion: { [weak self] convoId in

                guard let convoIdent = convoId else {
                    self?.createNewConversation(user: otherUser)
                    return
                }
                
                let vc = ChatViewController(with: otherUser.username, email: otherUser.username, id: convoIdent)
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
            })
        }
    }
    
    private func createNewConversation(user: User) {
        
        
        let vc = ChatViewController(with: user.username, email: user.email,id: nil)
        vc.title = user.username
        vc.isNewConversation = true
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension messageRoomListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        print("this is model CellForRow")
        print(model)
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        
        let model = conversations[indexPath.row]
        if model.sender != email {
            if model.isRead == false {
                DatabaseManager.shared.updateMessageRead(convo: model.id , email: email, completion: {
                    success in
                    if success {
                        NotificationCenter.default.post(name: Notification.Name("didRead"), object: nil)
                    } else {
                        print("failure")
                    }
                })
                
            }
        }
        
        let vc = ChatViewController(with: model.otherUsername, email: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let conversationIdent = conversations[indexPath.row].id
//
//            tableView.beginUpdates()
//
//            DatabaseManager.shared.deleteConversation(conversationId: conversationIdent, completion: { [weak self]success in
//                if success {
//                    self?.conversations.remove(at: indexPath.row)
//                    self?.tableView.deleteRows(at: [indexPath], with: .left)
//                }
//            })
//
//            tableView.endUpdates()
//
//
//        }
    //}
}




