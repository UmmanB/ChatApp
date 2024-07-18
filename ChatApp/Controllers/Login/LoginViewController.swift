import UIKit
import SnapKit
import FirebaseAuth
import FacebookLogin
import JGProgressHUD

final class LoginViewController: UIViewController
{
    private let spinner = JGProgressHUD(style: .dark)
    
    private lazy var titleLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Log in"
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Bold", size: 18)
        label.textColor = .customPurple
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var subtitleLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Welcome back! Sign in using your Facebook account or email to continue"
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Light", size: 14)
        label.textColor = .gray
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var facebookCustomButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "FacebookPNG"), for: .normal)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(loginWithFacebook), for: .touchUpInside)
        return button
    }()
    
    private lazy var lineViewLeft: UIView =
    {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var orLabel: UILabel =
    {
        let label = UILabel()
        label.text = "or"
        label.font = UIFont(name: "Poppins-Regular", size: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var lineViewRight: UIView =
    {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var emailLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Your email"
        label.font = UIFont(name: "Poppins-Medium", size: 14)
        label.textColor = .customPurple
        return label
    }()
    
    private lazy var emailField: UITextField =
    {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.font = UIFont(name: "Poppins-Medium", size: 14)
        field.leftViewMode = .always
        return field
    }()
    
    private lazy var emailLineView: UIView =
    {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var passwordLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont(name: "Poppins-Medium", size: 14)
        label.textColor = .customPurple
        return label
    }()
    
    private lazy var passwordField: UITextField =
    {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.font = UIFont(name: "Poppins-Medium", size: 14)
        field.isSecureTextEntry = true
        return field
    }()
    
    private lazy var passwordLineView: UIView =
    {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var loginButton: UIButton =
    {
        let button = UIButton()
        let backgroundImage = UIImage(named: "Rectangle 1159")
        button.setBackgroundImage(backgroundImage, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 18)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var registerLabel: UILabel = 
    {
        let label = UILabel()
        label.text = "Don't have an account? Create a new one"
        label.textColor = .customGray
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Regular", size: 14)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRegister)))
        return label
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        setupConstraints()
    }
    
    private func setupConstraints()
    {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(facebookCustomButton)
        view.addSubview(lineViewLeft)
        view.addSubview(orLabel)
        view.addSubview(lineViewRight)
        view.addSubview(emailLabel)
        view.addSubview(emailField)
        view.addSubview(emailLineView)
        view.addSubview(passwordLabel)
        view.addSubview(passwordField)
        view.addSubview(passwordLineView)
        view.addSubview(loginButton)
        view.addSubview(registerLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(40)
        }
            
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(40)
        }
        
        facebookCustomButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        lineViewLeft.snp.makeConstraints { make in
            make.centerY.equalTo(orLabel)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalTo(orLabel.snp.leading).offset(-10)
            make.height.equalTo(1)
        }
        
        orLabel.snp.makeConstraints { make in
            make.top.equalTo(facebookCustomButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(20)
        }
        
        lineViewRight.snp.makeConstraints { make in
            make.centerY.equalTo(orLabel)
            make.trailing.equalToSuperview().offset(-24)
            make.leading.equalTo(orLabel.snp.trailing).offset(10)
            make.height.equalTo(1)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(lineViewLeft.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(20)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(30)
        }
        
        emailLineView.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(0)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLineView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(20)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(30)
        }
        
        passwordLineView.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(0)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordLineView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(50)
        }
        
        registerLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(10)
            make.leading.trailing.equalTo(loginButton)
            make.height.equalTo(50)
        }
    }

    override func viewWillAppear(_ animated: Bool) 
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) 
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: Notification)
    {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        let keyboardHeight = keyboardFrame.height - safeAreaBottomInset
        let textFieldBottomY = registerLabel.frame.maxY + 20
        let offset = textFieldBottomY - (view.frame.height - keyboardHeight)
        
        if offset > 0
        {
            UIView.animate(withDuration: 0.3)
            {
                self.view.frame.origin.y = -offset
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide()
    {
        UIView.animate(withDuration: 0.1)
        {
            self.view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func loginButtonTapped()
    {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else
        {
            alertUserLoginError("Please enter all information to log in.")
            return
        }
        
        guard password.count >= 6 else
        {
            alertUserLoginError("Password must be at least 6 characters long.")
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
        
            DispatchQueue.main.async { strongSelf.spinner.dismiss() }
            
            if let error = error {
                        print("Failed to log in user with email: \(email), error: \(error.localizedDescription)")
                        strongSelf.presentLoginErrorAlert()
                        return
                    }
            
            guard let result = authResult, error == nil else
            {
                print("Failed to log in user with email: \(email)")
                strongSelf.presentLoginErrorAlert()
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result
                {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let userName = userData["name"] as? String else { return }
                  
                    DispatchQueue.main.async
                    {
                        UserDefaults.standard.set(userName, forKey: "name")
                        UserDefaults.standard.set(email, forKey: "email")
                        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                    }
                    
                case .failure(let error): print("Failed to read data with error \(error)")
                }
            }
            print("Logged In User: \(user)")
            
        }
    }
    
    private func presentLoginErrorAlert() {
        let alert = UIAlertController(title: "Login Error", message: "Failed to log in. Please check your email and password and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func alertUserLoginError(_ message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister()
    {
        print("didTapRegister")
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginWithFacebook() 
    {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
            guard let strongSelf = self else { return }

            if let error = error 
            {
                print("Facebook login failed with error: \(error.localizedDescription)")
                return
            }
            
            guard let result = result, !result.isCancelled else 
            {
                print("Facebook login was cancelled")
                return
            }
            
            // Successfully logged in with Facebook
            let accessToken = result.token?.tokenString
            
            let facebookRequest = GraphRequest(graphPath: "me", parameters: ["fields": "email, name, picture.type(large)"], tokenString: accessToken, version: nil, httpMethod: .get)
            
            facebookRequest.start { _, result, error in
                guard let result = result as? [String: Any], error == nil else 
                {
                    print("Failed to make Facebook graph request")
                    return
                }
                
                print(result)
                
                guard let userName = result["name"] as? String,
                      let email = result["email"] as? String,
                      let picture = result["picture"] as? [String: Any],
                      let data = picture["data"] as? [String: Any],
                      let pictureUrl = data["url"] as? String else {
                    print("Failed to get email and name from Facebook result")
                    return
                }
                
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(userName, forKey: "name")
                
                DatabaseManager.shared.userExists(with: email) { exists in
                    if !exists
                    {
                        let chatUser = ChatAppUser(name: userName, emailAddress: email)
                        DatabaseManager.shared.insertUser(with: chatUser) { success in
                            if success
                            {
                                guard let url = URL(string: pictureUrl) else
                                {
                                    print("Failed to get URL from Facebook picture data")
                                    return
                                }
                                
                                print("Downloading data from Facebook image")
                                
                                URLSession.shared.dataTask(with: url) { data, _, error in
                                    guard let data = data, error == nil else
                                    {
                                        print("Failed to get data from Facebook: \(error!.localizedDescription)")
                                        return
                                    }
                                    
                                    print("Got data from Facebook, uploading...")
                                    
                                    guard let selectedImage = UIImage(data: data) else 
                                    {
                                        print("Failed to convert data to UIImage")
                                        return
                                    }
                                    
                                    let filename = chatUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: selectedImage, fileName: filename) { result in
                                        switch result
                                        {
                                        case .success(let downloadUrl):
                                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                            print(downloadUrl)
                                        case .failure(let error):
                                            print("Storage manager error: \(error)")
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken!)
                
                FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error 
                    {
                        print("Firebase login failed with error: \(error.localizedDescription)")
                        return
                    }
                    // Successfully logged in with Firebase
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailField { passwordField.becomeFirstResponder() }
        else if textField == passwordField { loginButtonTapped() }
        return true
    }
}
