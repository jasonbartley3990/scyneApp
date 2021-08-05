//
//  ChatViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/13/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVKit
import AVFoundation
import MobileCoreServices

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedString"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct sender: SenderType {
    var photoUrl: String
    var senderId: String
    var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    
    public let otherUserName: String
    
    public let otherUserEmail: String
    
    private var conversationId: String?
    
    private var messages = [Message]()
    
    private var senderPhotoUrl: URL?
    
    private var otherUserPhotoUrl: URL?
    
    private var selfSender: sender? {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        guard let username = UserDefaults.standard.string(forKey: "username") else {return nil}
        let sendr = sender(photoUrl: "", senderId: email, displayName: username)
        return sendr
    }
    
    
    init(with name: String, email: String, id: String?) {
        self.otherUserName = name
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        
        if let convoId = conversationId {
            listenForMessages(id: convoId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setUpInputBar()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageInputBar.inputTextView.becomeFirstResponder()
        messagesCollectionView.scrollToLastItem()
    }
    
    private func setUpInputBar() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "attach media", message: "what would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "choose photo from library", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: " camera", style: .default, handler:{ [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            }
        } ))
        actionSheet.addAction(UIAlertAction(title: "choose video from library", style: .default, handler: {[weak self] _ in
            
            DispatchQueue.main.async { [weak self] in
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.mediaTypes = ["public.movie"]
                picker.allowsEditing = true
                picker.videoQuality = .typeMedium
                self?.present(picker, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { _ in
            
            
        }))
        present(actionSheet, animated: true)
    }
    
    public func createMessageID() -> String? {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else { return nil }
        let otherUserEmail = self.otherUserEmail
        let randomInt = Int.random(in: 0...9999)
        
        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(randomInt)"
        return newIdentifier
        }
    
    private func createFilename() -> String? {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return nil}
        let randomInt = Int.random(in: 0...1000)
        let dateString = String.date(from: Date())
        return "\(currentUsername)_\(dateString)_\(randomInt)"
    }
    
    
    private func listenForMessages(id: String) {
        
        DatabaseManager.shared.setUpListenerForCovo(with: id, completion: {
            [weak self] success in

            if success {
                DatabaseManager.shared.getAllMessagesForConvo(with: id, completion: {
                    [weak self] messages in
                    guard let strongSelf = self else {return}
                    
                    DispatchQueue.main.async {
                        strongSelf.messages = messages
                        if messages.count > 100 {
                            DatabaseManager.shared.deleteHalfOfMessages(convo: id, completion: {
                                success in
                                print("success")
                            })
                        }
                        strongSelf.messagesCollectionView.reloadData()
                        strongSelf.messagesCollectionView.scrollToLastItem()
                    }
                })

            } else {
                print("something went wrong")

            }
        })
        
        }
    
}




extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {return}
            DispatchQueue.main.async {
                imageView.sd_setImage(with: imageUrl, completed: nil)
            }
            
        default:
            break
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        
        if sender.senderId == selfSender?.senderId {
            if let currentUserPhotoUrl = self.senderPhotoUrl {
                DispatchQueue.main.async {
                    avatarView.sd_setImage(with: currentUserPhotoUrl, completed: nil)
                }
            } else {
                StorageManager.shared.profilePictureUrl(for: currentEmail , completion: { [weak self] url in
                    guard let url = url else {return}
                    self?.senderPhotoUrl = url
                    DispatchQueue.main.async {
                        avatarView.sd_setImage(with: url, completed: nil)
                    }
                })
            }
        } else {
            if let otherUserPhotoUrl = self.otherUserPhotoUrl {
                DispatchQueue.main.async {
                    avatarView.sd_setImage(with: otherUserPhotoUrl, completed: nil)
                }
            } else {
                let email = self.otherUserEmail
                StorageManager.shared.profilePictureUrl(for: email, completion: { [weak self] url in
                    self?.otherUserPhotoUrl = url
                    DispatchQueue.main.async {
                        avatarView.sd_setImage(with: url, completed: nil)
                    }
                    
                })
            }
            
        }
        
        
    }
}


extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        guard let selfSenderVar = self.selfSender else {
            print("self sender returned")
            return}
        guard let messageId = createMessageID() else {
            print("failed message id")
            return}
        
        //send message
        if isNewConversation {
            let message = Message(sender: selfSenderVar, messageId: messageId, sentDate: Date(), kind: .text(text))
            
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, otherUsername: otherUserName , firstMessage: message, chatId: messageId, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    self?.conversationId = messageId
                    guard let id = self?.conversationId else {return}
                    self?.listenForMessages(id: id)
                    
                    DispatchQueue.main.async {
                        self?.messageInputBar.inputTextView.text = nil
                        self?.messagesCollectionView.reloadData()
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                    
                } else {
                    print("failed to send message")
                }
                
            })
        } else {
            guard let convoId = self.conversationId else {return}
            guard let username = UserDefaults.standard.string(forKey: "username") else {return}
            let message = Message(sender: selfSenderVar, messageId: messageId, sentDate: Date(), kind: .text(text))
            
            self.messageInputBar.inputTextView.text = nil
            
            DatabaseManager.shared.sendMessage(to: convoId, newMessage: message, name: username, otherUserUsername: otherUserName, otherUserEmail: otherUserEmail, completion: { [weak self] success in
               
                if success {
                    print("success")
                } else {
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: "opps something went wrong", message: "please try to send message again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                        self?.present(ac, animated: true)
                    }
                   
                }
            })
        }
    }
    

    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {return}
        print(mediaType)
        
        guard let convoId = self.conversationId else {
            print("mayo")
            return}
        
        
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let imageData = image.pngData() else {return}
            
            guard let filename = createFilename() else {
                return}
            
            //upload image
            StorageManager.shared.uploadMessagePhoto(with: imageData, convoId: convoId, filename: filename, completion: { [weak self] url in
                print("image uploaded")
                guard let strongSelf = self else {return}
                guard let imageUrl = url  else {return}
                guard imageUrl != nil else {return}
                
                
                guard let username = UserDefaults.standard.string(forKey: "username") else {return}
                guard let messageId = strongSelf.createMessageID() else {return}
                guard let selfSend = strongSelf.selfSender else {return}
                
                guard let placeHolder = UIImage(systemName: "photo") else {return}
                let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: .zero)
                
                let message = Message(sender: selfSend, messageId: messageId, sentDate: Date(), kind: .photo(media))
                
                
                DatabaseManager.shared.sendMessage(to: convoId, newMessage: message, name: username, otherUserUsername: strongSelf.otherUserName, otherUserEmail: strongSelf.otherUserEmail, completion: {
                    [weak self] success in
                    
                    if success {
                        DatabaseManager.shared.getAllMessagesForConvo(with: convoId, completion: {
                            [weak self] messages in
                            guard let strongSelf = self else {return}
                            
                            DispatchQueue.main.async {
                                strongSelf.messages = messages
                                strongSelf.messagesCollectionView.reloadData()
                                strongSelf.messagesCollectionView.scrollToLastItem()
                                
                            }
                            
                        })
                    } else {
                        print("failed to send message")
                    }
                })
                
            })
            
        
        } else if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            guard let filename = createFilename() else {
                return}
            print(videoUrl)
            
            //upload video
            
            StorageManager.shared.uploadMessageVideo(with: videoUrl, convoId: convoId, filename: filename, completion: { [weak self] url in
                print("video uploaded")
                guard let strongSelf = self else {return}
                guard let videoUrl = url  else {return}
                guard videoUrl != nil else {return}
                
                
                
                guard let username = UserDefaults.standard.string(forKey: "username") else {return}
                guard let messageId = strongSelf.createMessageID() else {return}
                guard let selfSend = strongSelf.selfSender else {return}
                
                guard let placeHolder = UIImage(systemName: "video") else {return}
                let media = Media(url: videoUrl, image: nil, placeholderImage: placeHolder, size: .zero)
                
                let message = Message(sender: selfSend, messageId: messageId, sentDate: Date(), kind: .video(media))
                
                
                DatabaseManager.shared.sendMessage(to: convoId, newMessage: message, name: username, otherUserUsername: strongSelf.otherUserName, otherUserEmail: strongSelf.otherUserEmail, completion: {
                    success in
                    
                    if success {
                        print("success")
                    } else {
                        print("failed to send message")
                    }
                })
                
            })
        }

        
}
}
        
        


extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {return}
            let vc = messagePhotoViewerViewController(url: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {return}
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            vc.player?.playImmediately(atRate: 1.0)
            present(vc, animated: true)
        default:
            break
        }
    }
}


