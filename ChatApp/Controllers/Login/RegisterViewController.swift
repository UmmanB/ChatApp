import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController
{
    private let titleLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Sign up with Email"
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
        label.text = "Get chatting with friends and family today by signing up for our chat app!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .customGray
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = 
    {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.customPurple.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Your name"
    
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .customPurple
  
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameField: UITextField =
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
    
    private let nameLineView: UIView =
    {
        let view = UIView()
        view.backgroundColor = .customLightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    private let registerButton: UIButton = 
    {
        let button = UIButton()
        let backgroundImage = UIImage(named: "Rectangle 1159")
        button.setBackgroundImage(backgroundImage, for: .normal)
        button.setTitle("Create an account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Create an account"
        view.backgroundColor = .white
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
         
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(nameField)
        view.addSubview(nameLineView)
        view.addSubview(emailLabel)
        view.addSubview(emailField)
        view.addSubview(emailLineView)
        view.addSubview(passwordLabel)
        view.addSubview(passwordField)
        view.addSubview(passwordLineView)
        view.addSubview(registerButton)
        
        setupConstraints()
        
        imageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic))
        
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() 
    {
        super.viewDidLayoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
    }

    @objc private func didTapProfilePic()
    {
        presentPhotoActionSheet()
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
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
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
            imageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nameField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            nameLineView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 0),
            nameLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nameLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: nameLineView.bottomAnchor, constant: 20),
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
            registerButton.topAnchor.constraint(equalTo: passwordLineView.bottomAnchor, constant: 50),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    @objc private func registerButtonTapped()
    {
        print("registerButtonTapped")
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        nameField.resignFirstResponder()
        
        guard let name = nameField.text, let email = emailField.text, let password = passwordField.text, !name.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6
        
        else
        {
            alertUserLoginError()
            return 
        }
                
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let result = authResult, error == nil else
            {
                print("Error creating else")
                return
            }
            
            let user = result.user
            print("Created User: \(user)")
           
        }
    }
    
    func alertUserLoginError()
    {
        let alert = UIAlertController(title: "Oops", message: "Please enter all information to create an account.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister()
    {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        
        else if textField == passwordField
        {
            registerButtonTapped()
        }
        
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func presentPhotoActionSheet()
    {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in self?.presentCamera()}))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in self?.presentPhotoPicker()}))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        else
        {
            return
        }
        
         self.imageView.image = selectedImage
        
        picker.dismiss(animated: true, completion: nil)
        print(info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}
