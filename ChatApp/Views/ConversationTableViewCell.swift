//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Umman on 05.07.24.
//

import UIKit
import SnapKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell
{
    static let identifier = "ConversationTableViewCell"
    
    private let outerBorderView: UIView =
    {
        let view = UIView()
        view.layer.cornerRadius = 45
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.customPurple.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let innerBorderView: UIView =
    {
        let view = UIView()
        view.layer.cornerRadius = 43
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 41
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userNameLabel: UILabel =
    {
        let label = UILabel()
        label.font = UIFont(name: "Poppins-Medium", size: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel =
    {
        let label = UILabel()
        label.font = UIFont(name: "Poppins-Regular", size: 16)
        label.textColor = .customGray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(outerBorderView)
        outerBorderView.addSubview(innerBorderView)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() 
    {
        super.layoutSubviews()
        outerBorderView.layer.cornerRadius = 45
        innerBorderView.layer.cornerRadius = 43
        userImageView.layer.cornerRadius = 41
    }
    
    private func setupConstraints()
    {
        outerBorderView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.centerY.equalTo(contentView)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        
        innerBorderView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(outerBorderView)
            make.width.equalTo(86)
            make.height.equalTo(86)
        }
        
        userImageView.snp.makeConstraints { make in
            make.center.equalTo(innerBorderView)
            make.width.height.equalTo(82)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(outerBorderView.snp.trailing).offset(20)
            make.top.equalTo(outerBorderView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
        }
        
        userMessageLabel.snp.makeConstraints { make in
            make.leading.equalTo(outerBorderView.snp.trailing).offset(20)
            make.bottom.equalTo(outerBorderView).offset(-20)
            make.trailing.equalTo(contentView).offset(-20)
        }
    }
    
    public func configure(with model: Conversation)
    {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
        
        userImageView.sd_cancelCurrentImageLoad()
        userImageView.sd_setImage(with: nil, placeholderImage: nil, options: [], context: nil)
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            guard let self = self else { return }
            switch result
            {
            case .success(let url):
                DispatchQueue.global().async 
                {
                    if let data = try? Data(contentsOf: url)
                    {
                        if let image = UIImage(data: data)
                        { DispatchQueue.main.async { UIView.transition(with: self.userImageView, duration: 0.3, options: .transitionCrossDissolve, animations:{ self.userImageView.image = image }, completion: nil) }
                        }
                    }
                }
            case .failure(let error):  print("Failed to get image URL: \(error)")
            }
        }
    }
}
