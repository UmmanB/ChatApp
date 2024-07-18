import UIKit
import SnapKit
import FirebaseAuth
import JGProgressHUD

/// Controller that shows list of conversations
final class ConversationsViewController: UIViewController
{
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    
    private let tableView: UITableView =
    {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noConversationsLabel: UILabel =
    {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = .customPurple
        label.font = UIFont(name: "Poppins-Medium", size: 18)
        label.isHidden = true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupNavigationBar()
        tableView.backgroundColor = .white
        
        if let customImage = UIImage(named: "Search") 
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: customImage, style: .plain, target: self, action: #selector(didTapComposeButton))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.customPurple
        }
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupConstraints()
        setupTableView()
        startListeningForConversations()
        tableView.separatorColor = .customPurple
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.startListeningForConversations()
        })
    }
    
    deinit { if let observer = loginObserver { NotificationCenter.default.removeObserver(observer) }}
    
    private func setupNavigationBar()
    {
        let largeTitleAttributes: [NSAttributedString.Key: Any] =
        [
            .font: UIFont(name: "Poppins-Bold", size: 34)!,
            .foregroundColor: UIColor.customPurple
        ]
        
        let standardTitleAttributes: [NSAttributedString.Key: Any] = 
        [
            .font: UIFont(name: "Poppins-Bold", size: 18)!,
            .foregroundColor: UIColor.customPurple
        ]
        
        navigationController?.navigationBar.largeTitleTextAttributes = largeTitleAttributes
        navigationItem.title = "Conversations"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = standardTitleAttributes
        appearance.largeTitleTextAttributes = largeTitleAttributes
        
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func startListeningForConversations()
    {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        self.conversations.removeAll()
        
        if let observer = loginObserver { NotificationCenter.default.removeObserver(observer) }
       
        print("starting conversation fetch...")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] result in
            switch result
            {
            case .success(let conversations):
                print("successfully got conversation models")
                self?.conversations = conversations
                
                DispatchQueue.main.async { if conversations.isEmpty { self?.animateNoConversationsLabel(hidden: false) } else
                    {
                        self?.animateNoConversationsLabel(hidden: true)
                        self?.tableView.isHidden = false
                        self?.noConversationsLabel.isHidden = true
                        UIView.transition(with: self!.tableView, duration: 0.3, options: .transitionCrossDissolve, animations:
                                            { self?.tableView.reloadData()}, completion: nil)
                    }
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.animateNoConversationsLabel(hidden: false)
                print("failed to get conversations: \(error)")
            }
        }
    }
    
    private func animateNoConversationsLabel(hidden: Bool)
    {
        UIView.transition(with: noConversationsLabel, duration: 0.3, options: .transitionCrossDissolve, animations: { self.noConversationsLabel.isHidden = hidden }, completion: nil)
    }
    
    @objc private func didTapComposeButton()
    {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else { return }
            
            let currentConversations = strongSelf.conversations
            
            if let targetConversation = currentConversations.first(where: { $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email )})
            {
                let vc  = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {strongSelf.createNewConversation(result: result) }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: SearchResult)
    {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        
        // Check in database if conversation with these two users exists
        // If it does, reuse conversation id
        // Otherwise use existing code
        
        DatabaseManager.shared.conversationExists(with: email) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result
            {
            case .success(let conversationId):
                let vc  = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)

            case .failure(_):
                let vc  = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupConstraints()
    {
        noConversationsLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(view).offset(-20)
            make.height.equalTo(100)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        validateAuth()
        startListeningForConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) 
    {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func validateAuth()
    {
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    private func setupTableView()
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return conversations.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation)
    {
        let vc  = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 100 }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { return .delete }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            //begin delete
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) {success in if !success {}}
            tableView.endUpdates()
        }
    }
}
