//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Umman on 03.07.24.
//

import AVKit
import UIKit
import SDWebImage
import MessageKit
import CoreLocation
import AVFoundation
import InputBarAccessoryView

final class ChatViewController: MessagesViewController
{
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail: String
    private var conversationId: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender?
    {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil}
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Me")
    }
    
    init(with email: String, id: String?)
    {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupBackButton()
        setupInputTextView()
        setupInputButton()
        setupMessageInputBar()
        
        messageInputBar.delegate = self
        messagesCollectionView.reloadData()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = .white
    }
    
    private func setupBackButton()
    {
        let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .customPurple
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupInputTextView()
    {
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.tintColor = .customGray
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.inputTextView.layer.masksToBounds = false
        messageInputBar.inputTextView.font = UIFont(name: "Poppins-Medium", size: 16)
    }
    
    private func setupInputButton()
    {
        let button = InputBarButtonItem()
        let customImage = UIImage(named: "Clip")
        button.setImage(customImage, for: .normal)
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.tintColor = .customClip
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func setupMessageInputBar()
    {
        messageInputBar.sendButton.setTitleColor(.customPurple, for: .normal)
        messageInputBar.sendButton.setTitleColor(.customGray, for: .highlighted)
        
        messageInputBar.backgroundColor = .clear
        messageInputBar.separatorLine.isHidden = true
        
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.backgroundView.layer.shadowColor = UIColor.darkGray.cgColor
        messageInputBar.backgroundView.layer.shadowOffset = CGSize(width: 2, height: 2)
        messageInputBar.backgroundView.layer.shadowOpacity = 1
        messageInputBar.backgroundView.layer.shadowRadius = 25
        messageInputBar.backgroundView.layer.cornerRadius = 30
        messageInputBar.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.inputTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messagesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            messageInputBar.backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            messageInputBar.backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            messageInputBar.backgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            messageInputBar.inputTextView.topAnchor.constraint(equalTo: messageInputBar.backgroundView.topAnchor, constant: 10),
            messageInputBar.inputTextView.leadingAnchor.constraint(equalTo: messageInputBar.backgroundView.leadingAnchor, constant: 40),
            messageInputBar.inputTextView.trailingAnchor.constraint(equalTo: messageInputBar.backgroundView.trailingAnchor, constant: -65),
            messageInputBar.inputTextView.bottomAnchor.constraint(equalTo: messageInputBar.backgroundView.bottomAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            messageInputBar.sendButton.leadingAnchor.constraint(equalTo: messageInputBar.inputTextView.trailingAnchor, constant: 10),
            messageInputBar.sendButton.trailingAnchor.constraint(equalTo: messageInputBar.backgroundView.trailingAnchor, constant: -15)
        ])
    }
    
    @objc private func backButtonTapped() { navigationController?.popViewController(animated: true) }
    
    private func presentInputActionSheet()
    {
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker()
    {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        tabBarController?.tabBar.isHidden = true
        let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(locationPickerBackButtonTapped))
        backButton.tintColor = .black
        vc.navigationItem.leftBarButtonItem = backButton
        
        vc.completion = { [weak self] selectedCoordinates in
            
            guard let strongSelf = self else { return }
            
            guard let messageId = strongSelf.createMessageId(),
                  let conversationId = strongSelf.conversationId,
                  let name = strongSelf.title,
                  let selfSender = strongSelf.selfSender else { return }
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            print("long=\(longitude) | lat= \(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                if success { print("sent location message") }
                else { print("failed to send location message") }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func locationPickerBackButtonTapped() { navigationController?.popViewController(animated: true) }
    
    private func presentPhotoInputActionSheet()
    {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach a photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet()
    {
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you like to attach a video from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool)
    {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result
            {
            case .success(let messages): print("success in getting messages: \(messages)")
                guard !messages.isEmpty else
                {
                    print("messsages are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async 
                {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom { self?.messagesCollectionView.scrollToLastItem(animated: true) }
                }
            case .failure(let error): print("failed to get messages: \(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) 
    {
        super.viewDidAppear(animated) 
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId { listenForMessages(id: conversationId, shouldScrollToBottom: true ) }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true, completion: nil) }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let name = self.title,
              let selfSender = selfSender else { return }
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData()
        {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            // Upload Image
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else { return }
                
                switch result
                {
                case.success(let urlString):
                    // Ready to send message
                    print("Uploaded Message Photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(named: "Black") else { return }
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                        if success { print("sent photo message") }
                        else { print("failed to send photo message") }
                    }
                case.failure(let error): print("message photo upload error: \(error)")
                }
            }
        }
        else if let videoUrl = info[.mediaURL] as? URL
        {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            // Upload Video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else { return }
                
                switch result
                {
                case.success(let urlString):
                    // Ready to send message
                    print("Uploaded Message Video: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(named: "Black") else { return }
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                        if success { print("sent video message") }
                        else { print("failed to send video message") }
                    }
                case.failure(let error): print("message video upload error: \(error)")
                }
            }
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate
{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {
        guard !text.replacingOccurrences(of: "", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMessageId() else { return }
        print("Sending: \(text)")
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        // Send Message
        if isNewConversation
        {
            // create convo in database
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
                guard let strongSelf = self else { return }
                
                if success
                {
                    print("message sent")
                    self?.isNewConversation = false
                    
                    let newConversationId = "conversation_\(message.messageId.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "#", with: "-").replacingOccurrences(of: "$", with: "-").replacingOccurrences(of: "[", with: "-").replacingOccurrences(of: "]", with: "-"))"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    DispatchQueue.main.async 
                    {
                        strongSelf.messageInputBar.inputTextView.text = ""
                        strongSelf.messageInputBar.reloadInputViews()
                    }
                }
                else { print("failed to send") }
            }
        }
        
        else
        {
            guard let conversationId = conversationId, let name = self.title else { return }
        
            // append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message) { [weak self] success in
                if success
                {
                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                }
                else { print("failed to send") }
            }
        }
    }
    
    private func createMessageId() -> String?
    {
        // date, otherUserEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
       
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created message id: \(newIdentifier)")
        return newIdentifier
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
{
    var currentSender: any MessageKit.SenderType
    {
        if let sender = selfSender { return sender }
        fatalError("Self sender is nil, email should be cached")
    }
     
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageKit.MessageType
    { return messages[indexPath.section] }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int { return messages.count }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
    {
        guard let message = message as? Message else { return }
        
        switch message.kind
        {
        case .photo(let media): guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default: break
        }
    }
    
    func backgroundColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor
    {
        let sender = message.sender
        if sender.senderId == self.selfSender?.senderId { return .customPurple } else { return .customBubble }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor
    {
        let sender = message.sender
        if sender.senderId == self.selfSender?.senderId { return .white } else { return .black }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
    {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId
        {
            // Show our image
            if let currentUserImageURL = self.senderPhotoURL
            {
                avatarView.sd_setImage(with: currentUserImageURL, placeholderImage: nil, options: [], completed: { _, _, _, _ in
                               UIView.transition(with: avatarView, duration: 0.6, options: .transitionCrossDissolve, animations: nil, completion: nil)})
            }
            else
            {
                // images/safeemail_profile_picture.png
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // Fetch url
                StorageManager.shared.downloadUrl(for: path) { [weak self] result in
                    switch result
                    {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async
                        {
                            avatarView.sd_setImage(with: url, placeholderImage: nil, options: [], completed: { _, _, _, _ in
                                UIView.transition(with: avatarView, duration: 0.6, options: .transitionCrossDissolve, animations: nil, completion: nil)})
                        }
                    case .failure(let error): print("\(error)")
                    }
                }
            }
        }
        else
        {
            // Other user image
            if let otherUserImageURL = self.otherUserPhotoURL
            {
                avatarView.sd_setImage(with: otherUserImageURL, placeholderImage: nil, options: [], completed: { _, _, _, _ in
                               UIView.transition(with: avatarView, duration: 0.6, options: .transitionCrossDissolve, animations: nil, completion: nil)})
            }
            else
            {
                // Fetch url
                let email = self.otherUserEmail
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // Fetch url
                StorageManager.shared.downloadUrl(for: path) { [weak self] result in
                    switch result
                    {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async
                        {
                            avatarView.sd_setImage(with: url, placeholderImage: nil, options: [], completed: { _, _, _, _ in
                                UIView.transition(with: avatarView, duration: 0.6, options: .transitionCrossDissolve, animations: nil, completion: nil)})
                        }
                    case .failure(let error): print("\(error)")
                        
                    }
                }
            }
        }
    }
}

extension ChatViewController: MessageCellDelegate
{
    func didTapMessage(in cell: MessageCollectionViewCell)
    {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        
        switch message.kind
        {
        case .location(let locationData):
            tabBarController?.tabBar.isHidden = true
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)
            vc.title = "Location"
            let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(locationPickerBackButtonTapped))
            backButton.tintColor = .black
            vc.navigationItem.leftBarButtonItem = backButton
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell)
    {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        
        switch message.kind
        {
        case .photo(let media): guard let imageUrl = media.url else { return }
            tabBarController?.tabBar.isHidden = true
            let vc  = PhotoViewerViewController(with: imageUrl)
            let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(photoViewerBackButtonTapped))
            backButton.tintColor = .white
            vc.navigationItem.leftBarButtonItem = backButton
            navigationController?.pushViewController(vc, animated: true)
            
        case .video(let media): guard let videoUrl = media.url else { return }
            tabBarController?.tabBar.isHidden = true
            let playerVC = AVPlayerViewController()
            playerVC.player = AVPlayer(url: videoUrl)
            let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(dismissVideoPlayer))
            backButton.tintColor = .white
            playerVC.navigationItem.leftBarButtonItem = backButton
            navigationController?.pushViewController(playerVC, animated: true)
        default: break
        }
    }
    
    @objc private func photoViewerBackButtonTapped()
    {
        tabBarController?.tabBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissVideoPlayer() 
    {
        tabBarController?.tabBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
}
