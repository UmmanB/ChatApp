import UIKit
import SnapKit
import JGProgressHUD

final class NewConversationViewController: UIViewController 
{
    public var completion: ((SearchResult) -> (Void))?
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
    private lazy var searchBar: UISearchBar = 
    {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField
        {
            let placeholderLabel = textField.value(forKey: "placeholderLabel") as? UILabel
            placeholderLabel?.font = UIFont(name: "Poppins-Medium", size: 14)
            
            textField.font = UIFont(name: "Poppins-Medium", size: 14)
            textField.textColor = .black
        }
        return searchBar
    }()
    
    private lazy var tableView: UITableView =
    {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        return tableView
    }()
    
    private lazy var noResultsLabel: UILabel =
    {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .customPurple
        label.font = UIFont(name: "Poppins-Medium", size: 18)
        return label
    }()
    
    @objc func dismissSelf() { self.dismiss(animated: true, completion: nil) }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.separatorStyle = .none
        searchBar.becomeFirstResponder()
    }
    
    private func setupNavigationBar() 
    {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        let attributes: [NSAttributedString.Key: Any] = [ .font: UIFont(name: "Poppins-Medium", size: 14)!, .foregroundColor: UIColor.customPurple ]
        cancelButton.setTitleTextAttributes(attributes, for: .normal)
        cancelButton.setTitleTextAttributes(attributes, for: .highlighted)
        
        navigationItem.rightBarButtonItem = cancelButton
        navigationController?.navigationBar.topItem?.titleView = searchBar
    }
        
    private func setupSubviews()
    {
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
    }
    
    
    private func setupConstraints()
    {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
    }
        noResultsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(view.snp.width).multipliedBy(0.5)
            make.height.equalTo(200)
        }
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return results.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let model = results[indexPath.row ]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // start conversation
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 100 }
}

extension NewConversationViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) 
    {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: " ").isEmpty else { return }
   
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view )
        searchUsers(query: text)
    }
    
    func searchUsers(query: String)
    {
        // check if array has firebase results
        if hasFetched
        {
            // if it does: filter
            filterUsers(with: query)
        }
        else
        {
            // if not, fetch then filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result
                {
                case.success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            }
        }
    }
    
    func filterUsers(with term: String)
    {
        // update the UI: either show the results or show no results label
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else { return }
       
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        self.spinner.dismiss()
        
        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else { return false}
            
            guard let name = $0["name"]?.lowercased() else { return false}
           
            return name.hasPrefix(term.lowercased())
            
        }).compactMap({
            guard let email = $0["email"], let name = $0["name"] else { return nil }
            return SearchResult(name: name, email: email)
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI()
    {
        if results.isEmpty
        {
            animateNoResultsLabel(hidden: false)
            tableView.isHidden = true
        }
        
        else
        {
            animateNoResultsLabel(hidden: true)
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func animateNoResultsLabel(hidden: Bool) {
        UIView.transition(with: noResultsLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.noResultsLabel.isHidden = hidden
        }, completion: nil)
    }
}

