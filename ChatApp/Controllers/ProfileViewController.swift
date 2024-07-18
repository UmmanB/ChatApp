import UIKit
import SnapKit
import SDWebImage
import FirebaseAuth
import FBSDKLoginKit

final class ProfileViewController: UIViewController
{
    let headerView = UIView()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let logoutButton = UIButton()
    let imageView = UIImageView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) 
    {
        super.viewWillAppear(animated)
        updateUserInfo()
    }

    func setupUI()
    {
        view.addSubview(headerView)
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 95
        headerView.layer.masksToBounds = true
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(200)
            make.centerX.equalTo(view.snp.centerX)
            make.width.height.equalTo(190)
        }

        let outerBorderView = UIView()
        outerBorderView.backgroundColor = .customPurple
        outerBorderView.layer.borderWidth = 4
        outerBorderView.layer.borderColor = UIColor.customPurple.cgColor
        outerBorderView.layer.cornerRadius = 95
        outerBorderView.layer.masksToBounds = true
        headerView.addSubview(outerBorderView)
        outerBorderView.snp.makeConstraints { make in
            make.edges.equalTo(headerView)
        }

        let innerBorderView = UIView()
        innerBorderView.backgroundColor = .white
        innerBorderView.layer.borderWidth = 5
        innerBorderView.layer.borderColor = UIColor.white.cgColor
        innerBorderView.layer.cornerRadius = 93
        innerBorderView.layer.masksToBounds = true
        outerBorderView.addSubview(innerBorderView)
        innerBorderView.snp.makeConstraints { make in
            make.center.equalTo(outerBorderView)
            make.width.height.equalTo(186)
        }

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 93
        imageView.layer.masksToBounds = true
        innerBorderView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(innerBorderView)
        }
        
        imageView.image = nil
        
        DispatchQueue.main.async { self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2 }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        view.addSubview(nameLabel)
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont(name: "Poppins-Bold", size: 18)
        nameLabel.text = UserDefaults.standard.value(forKey: "name") as? String ?? "No Name"
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        view.addSubview(emailLabel)
        emailLabel.textAlignment = .center
        emailLabel.font = UIFont(name: "Poppins-Light", size: 16)
        emailLabel.textColor = .customGray
        emailLabel.text = UserDefaults.standard.value(forKey: "email") as? String ?? "No Email"
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        view.addSubview(logoutButton)
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 18)
        let backgroundImage = UIImage(named: "Rectangle 1159")
        logoutButton.layer.cornerRadius = 20
        logoutButton.layer.masksToBounds = true
        logoutButton.setBackgroundImage(backgroundImage, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
       
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(130)
            make.height.equalTo(40)
        }
}
    
    func updateUserInfo() 
    {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        // Fetch and display name and email
        let savedName = UserDefaults.standard.value(forKey: "name") as? String ?? "No Name"
        print("Retrieved Name: \(savedName)")
        nameLabel.text = savedName
        emailLabel.text = email
        
        // Fetch profile picture
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename

        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result
            {
            case .success(let url):
                DispatchQueue.main.async
                {
                    strongSelf.imageView.sd_imageIndicator = SDWebImageActivityIndicator.medium
                    strongSelf.imageView.sd_setImage(with: url) { image, _, _, _ in
                        strongSelf.imageView.sd_imageIndicator = nil
                        
                        guard let image = image else { return }
                        
                        UIView.transition(with: strongSelf.imageView, duration: 1, options: .transitionCrossDissolve, animations:
                                            { strongSelf.imageView.image = image }, completion: nil)
                    }
                }
            case .failure(let error): print("Failed to get download url: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func logoutTapped() 
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "name")
            strongSelf.updateUserInfo()
            
            FBSDKLoginKit.LoginManager().logOut()
            do
            {
                try FirebaseAuth.Auth.auth().signOut()
                
                UIView.transition(with: strongSelf.imageView, duration: 1.0, options: .transitionCrossDissolve, animations:
                                    { strongSelf.imageView.image = nil }, completion: nil)
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            
            catch { print("Failed to log out") }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    @objc func imageViewTapped()
    {
        if let email = UserDefaults.standard.value(forKey: "email") as? String
        {
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            let filename = safeEmail + "_profile_picture.png"
            let path = "images/" + filename
            StorageManager.shared.downloadUrl(for: path) { result in
                switch result
                {
                case .success(let url):
                    let fullImageViewController = FullImageViewController(imageUrl: url)
                    fullImageViewController.modalPresentationStyle = .fullScreen
                    self.present(fullImageViewController, animated: true, completion: nil)
                case .failure(let error): print("Failed to get download url: \(error)")
                }
            }
        }
    }
}

class FullImageViewController: UIViewController
{
    var imageUrl: URL?

    init(imageUrl: URL) 
    {
        self.imageUrl = imageUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let imageUrl = imageUrl else { return }
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.sd_setImage(with: imageUrl, completed: nil)
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullImageViewController))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissFullImageViewController() { dismiss(animated: true, completion: nil) }
}
