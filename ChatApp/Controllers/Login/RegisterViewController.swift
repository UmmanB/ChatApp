import UIKit
import FirebaseAuth
import JGProgressHUD

final class RegisterViewController: UIViewController
{
    private let spinner = JGProgressHUD(style: .dark)
   
    private lazy var titleLabel: UILabel = 
    {
        let label = UILabel()
        label.text = "Sign up with Email"
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
        label.text = "Get chatting with friends and family today by signing up for our chat app!"
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Light", size: 14)
        label.textColor = .customGray
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var imageView: UIImageView = 
    {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.customPurple.cgColor
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic)))
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = 
    {
        let label = UILabel()
        label.text = "Your name"
        label.font = UIFont(name: "Poppins-Medium", size: 14)
        label.textColor = .customPurple
        return label
    }()
    
    private lazy var nameField: UITextField = 
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
    
    private lazy var nameLineView: UIView = 
    {
        let view = UIView()
        view.backgroundColor = .customLightGray
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
        view.backgroundColor = .customLightGray
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
        field.font = UIFont(name: "Poppins-Medium", size: 14)
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        return field
    }()
    
    private lazy var passwordLineView: UIView = 
    {
        let view = UIView()
        view.backgroundColor = .customLightGray
        return view
    }()
    
    private lazy var registerButton: UIButton = 
    {
        let button = UIButton()
        let backgroundImage = UIImage(named: "Rectangle 1159")
        button.setBackgroundImage(backgroundImage, for: .normal)
        button.setTitle("Create an account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 16)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var backButtonLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Already have an account? Log In"
        label.textColor = .customGray
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Regular", size: 14)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonTapped)))
        return label
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
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
        view.addSubview(backButtonLabel)
        setupConstraints()
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func backButtonTapped() { navigationController?.popViewController(animated: true) }
    
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
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(40)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(view).multipliedBy(0.6)
            make.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(view).multipliedBy(0.2)
            make.height.equalTo(imageView.snp.width)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.leading.equalTo(view).offset(24)
            make.trailing.equalTo(view).offset(-24)
            make.height.equalTo(20)
        }
        
        nameField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(nameLabel)
            make.height.equalTo(30)
        }
        
        nameLineView.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(0)
            make.leading.trailing.equalTo(nameField)
            make.height.equalTo(1)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLineView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nameLabel)
            make.height.equalTo(20)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(nameLabel)
            make.height.equalTo(30)
        }
        
        emailLineView.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(0)
            make.leading.trailing.equalTo(nameField)
            make.height.equalTo(1)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLineView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nameLabel)
            make.height.equalTo(20)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(nameLabel)
            make.height.equalTo(30)
        }
        
        passwordLineView.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(0)
            make.leading.trailing.equalTo(nameField)
            make.height.equalTo(1)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(passwordLineView.snp.bottom).offset(40)
            make.leading.trailing.equalTo(nameLabel)
            make.height.equalTo(50)
        }
        
        backButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(10)
            make.leading.trailing.equalTo(nameLabel)
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
        let textFieldBottomY = backButtonLabel.frame.maxY + 20
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
    
    @objc private func registerButtonTapped()
    {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        nameField.resignFirstResponder()
            
        guard let name = nameField.text, let email = emailField.text, let password = passwordField.text else
        {
            alertUserLoginError()
            return
        }
        
        if name.isEmpty || email.isEmpty || password.isEmpty 
        {
            alertUserLoginError(message: "Please enter all information to create an account.")
            return
        }
        
        if password.count < 6
        {
            alertUserLoginError(message: "Password must be at least 6 characters long.")
            return
        }
        
        if imageView.image == UIImage(systemName: "person.circle.fill")
        {
            alertUserLoginError(message: "Please select a profile picture.")
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            
            guard let strongSelf = self else { return }
            DispatchQueue.main.async { strongSelf.spinner.dismiss() }
           
            guard !exists else
            {
                // user already exists
                strongSelf.alertUserLoginError(message: "A user account for that email address already exists.")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                guard authResult != nil, error == nil else
                {
                    print("Error creating user")
                    return
                }
                
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(name, forKey: "name")
                
                let chatUser = ChatAppUser(name: name, emailAddress: email)
                
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    if success
                    {
                        guard let image = strongSelf.imageView.image, let data = image.pngData()
                        else { return }
        
                        let filename = chatUser.profilePictureFileName
                        
                        guard let selectedImage = UIImage(data: data) else 
                        {
                            print("Failed to convert data to UIImage")
                            return
                        }

                        StorageManager.shared.uploadProfilePicture(with: selectedImage, fileName: filename) { result in
                            switch result
                            {
                            case.success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case.failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        }
                    }
                }
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create an account.")
    {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
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
        if textField == emailField { passwordField.becomeFirstResponder() }
        else if textField == passwordField { registerButtonTapped() }
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
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        self.imageView.image = selectedImage
                
        // Upload the image data to Firebase Storage
        let filename = "profile_picture.png"
        StorageManager.shared.uploadProfilePicture(with: selectedImage, fileName: filename) { result in
            switch result
            {
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                print("Uploaded profile picture URL: \(downloadUrl)")
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        }
    }
}


