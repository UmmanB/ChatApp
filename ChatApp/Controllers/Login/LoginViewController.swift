import UIKit
import FirebaseAuth

class LoginViewController: UIViewController
{
    private let titleLabel: UILabel = 
    {
        let label = UILabel()
        label.text = "Log in to Chatbox"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .customPurple
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = 
    {
        let label = UILabel()
        label.text = "Welcome back! Sign in using your email to continue"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .customGray
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = 
    {
        let label = UILabel()
        label.text = "Your email"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .customPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailField: UITextField = 
    {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let emailLineView: UIView =
    {
        let view = UIView()
        view.backgroundColor = .customLightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let passwordLabel: UILabel = 
    {
        let label = UILabel()
        label.text = "Password"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .customPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordField: UITextField = 
    {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let passwordLineView: UIView = 
    {
        let view = UIView()
        view.backgroundColor = .customLightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loginButton: UIButton = 
    {
        let button = UIButton()
        let backgroundImage = UIImage(named: "Rectangle 1159")
        button.setBackgroundImage(backgroundImage, for: .normal)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() 
    {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailField)
        view.addSubview(emailLineView)
        view.addSubview(passwordLabel)
        view.addSubview(passwordField)
        view.addSubview(passwordLineView)
        view.addSubview(loginButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() 
    {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 150),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            emailLineView.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 0),
            emailLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        NSLayoutConstraint.activate([
            passwordLabel.topAnchor.constraint(equalTo: emailLineView.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            passwordLineView.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 0),
            passwordLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordLineView.bottomAnchor, constant: 152),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    @objc private func loginButtonTapped()
    {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6
       
        else
        {
            alertUserLoginError()
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            guard let result = authResult, error == nil else
            {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged In User: \(user)")
        }
    }
    
    func alertUserLoginError()
    {
        let alert = UIAlertController(title: "Oops", message: "Please enter all information to log in.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() 
    {
        print("didTapRegister")
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool 
    {
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        
        else if textField == passwordField
        {
            loginButtonTapped()
        }
        
        return true
    }
}

